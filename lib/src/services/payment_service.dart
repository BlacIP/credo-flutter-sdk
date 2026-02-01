import '../client/api_endpoints.dart';
import '../client/credo_api_client.dart';
import '../models/requests/requests.dart';
import '../models/responses/responses.dart';

/// Service for payment operations
class PaymentService {
  /// Creates a payment service
  const PaymentService(this._apiClient);

  final CredoApiClient _apiClient;

  Future<InitializePaymentResponse> initializePayment(
    InitializePaymentRequest request,
  ) async {
    final response = await _apiClient.post(
      ApiEndpoints.initializePayment,
      request.toJson(),
    );

    return InitializePaymentResponse.fromJson(response);
  }

  /// Verify a payment transaction via your secure backend (RECOMMENDED)
  ///
  /// This method calls your backend endpoint, which should then call Credo
  /// using your SECRET KEY. This keeps your credentials secure.
  ///
  /// [backendUrl] is your server endpoint that handles verification.
  /// The SDK will append the transRef as a query parameter or path segment
  /// based on your implementation. By default, it sends it as a query param.
  Future<VerifyPaymentResponse> verifyPaymentViaBackend(
    String backendUrl,
    String transRef, {
    Map<String, String>? headers,
  }) async {
    final separator = backendUrl.contains('?') ? '&' : '?';
    final url = Uri.parse('$backendUrl${separator}transRef=$transRef');

    final response = await _apiClient.externalGet(url, headers: headers);
    return VerifyPaymentResponse.fromJson(response);
  }

  /// Verify a payment transaction directly with Credo (NOT RECOMMENDED for production)
  ///
  /// WARNING: This requires a SECRET KEY which should NEVER be placed
  /// in a mobile app. Use only for rapid prototyping or sandbox testing.
  Future<VerifyPaymentResponse> verifyPaymentDirectly(
    VerifyPaymentRequest request,
  ) async {
    final response = await _apiClient.get(
      ApiEndpoints.verifyPayment(request.transRef),
    );

    return VerifyPaymentResponse.fromJson(response);
  }
}
