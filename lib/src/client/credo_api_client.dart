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
  })  : _apiKey = apiKey,
        _environment = environment;

  final String _apiKey;
  final CredoEnvironment _environment;

  /// Get base URL for current environment
  String get baseUrl => _environment.baseUrl;

  /// Get common headers
  Map<String, String> get _headers {
    return {
      'Authorization': _apiKey, // Standard raw key
      'api-public-key': _apiKey, // Required for verification/others
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Make a POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');

      // Add api-public-key to the request body for ALL POST requests
      // This ensures compatibility across Initialize, Direct Charge, and Settlement
      final requestBody = {
        'api-public-key': _apiKey,
        ...body,
      };

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(requestBody),
      );

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

      final response = await http.get(
        url,
        headers: _headers,
      );

      return _handleResponse(response);
    } catch (e) {
      if (e is CredoException) rethrow;
      throw CredoNetworkException(
        'Network request failed',
        e.toString(),
      );
    }
  }

  /// Make a GET request to an external URL (e.g., your backend)
  Future<Map<String, dynamic>> externalGet(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.get(
        url,
        headers: headers,
      );

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
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

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
    } on FormatException {
      throw CredoApiException(
        'Invalid response format',
        statusCode: response.statusCode,
        details: response.body,
      );
    }
  }
}
