import 'dart:convert';
import 'package:http/http.dart' as http;
import '../exceptions/credo_exception.dart';
import '../models/enums/enums.dart';

/// HTTP client for Credo API
class CredoApiClient {
  /// Creates a Credo API client
  CredoApiClient({
    required String apiKey,
    CredoEnvironment environment = CredoEnvironment.sandbox,
    http.Client? httpClient,
    Duration timeout = const Duration(seconds: 30),
    String? userAgent,
  })  : _apiKey = apiKey,
        _environment = environment,
        _client = httpClient ?? http.Client(),
        _ownsClient = httpClient == null,
        _timeout = timeout,
        _userAgent = userAgent;

  final String _apiKey;
  final CredoEnvironment _environment;
  final http.Client _client;
  final bool _ownsClient;
  final Duration _timeout;
  final String? _userAgent;

  /// Get base URL for current environment
  String get baseUrl => _environment.baseUrl;

  /// Get common headers
  Map<String, String> _headers({String? idempotencyKey}) {
    final headers = <String, String>{
      'Authorization': _apiKey, // Standard raw key
      'api-public-key': _apiKey, // Required for verification/others
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_userAgent != null && _userAgent!.trim().isNotEmpty) {
      headers['User-Agent'] = _userAgent!;
    }
    if (idempotencyKey != null && idempotencyKey.trim().isNotEmpty) {
      headers['Idempotency-Key'] = idempotencyKey;
    }
    return headers;
  }

  /// Make a POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? idempotencyKey,
  }
  ) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');

      // Add api-public-key to the request body for ALL POST requests
      // This ensures compatibility across Initialize, Direct Charge, and Settlement
      final requestBody = {
        'api-public-key': _apiKey,
        ...body,
      };

      final response = await _client
          .post(
        url,
        headers: _headers(idempotencyKey: idempotencyKey),
        body: jsonEncode(requestBody),
      )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is CredoException) rethrow;
      throw CredoNetworkException(
        'Network request failed',
        e.toString(),
      );
    }
  }

  /// Make a GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final separator = endpoint.contains('?') ? '&' : '?';
      final url =
          Uri.parse('$baseUrl$endpoint$separator' 'api-public-key=$_apiKey');

      final response = await _client
          .get(
        url,
        headers: _headers(),
      )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      if (e is CredoException) rethrow;
      throw CredoNetworkException(
        'Network request failed',
        e.toString(),
      );
    }
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.body.isEmpty) {
      throw CredoApiException(
        'Empty response body',
        statusCode: response.statusCode,
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      if (response.statusCode >= 400) {
        throw CredoApiException(
          response.body,
          statusCode: response.statusCode,
          details: response.body,
        );
      }
      throw CredoApiException(
        'Invalid response format',
        statusCode: response.statusCode,
        details: response.body,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw CredoApiException(
        'Unexpected response format',
        statusCode: response.statusCode,
        details: response.body,
      );
    }

    final data = decoded;

    // Check for API errors
    if (response.statusCode >= 400) {
      final errors = data['error'] != null
          ? (data['error'] is List
              ? List<String>.from(data['error'] as List)
              : [data['error'].toString()])
          : null;

      throw CredoApiException(
        data['message'] as String? ?? 'Request failed',
        statusCode: response.statusCode,
        errors: errors,
      );
    }

    // Check for error field in successful response
    final errorField = data['error'];
    if (errorField != null &&
        ((errorField is String && errorField.isNotEmpty) ||
            (errorField is List && errorField.isNotEmpty) ||
            (errorField is Map && errorField.isNotEmpty))) {
      final errorMessage =
          errorField is List ? errorField.join(', ') : errorField.toString();

      throw CredoApiException(
        errorMessage,
        statusCode: response.statusCode,
      );
    }

    return data;
  }

  /// Close the underlying HTTP client (if owned).
  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
