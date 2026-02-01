import 'client/credo_api_client.dart';
import 'models/enums/enums.dart';
import 'models/requests/requests.dart';
import 'models/responses/responses.dart';
import 'services/payment_service.dart';

/// Main SDK class for Credo Payment Gateway
class CredoPaymentGateway {
  /// Creates a Credo Payment Gateway instance
  CredoPaymentGateway({
    required String apiKey,
    CredoEnvironment environment = CredoEnvironment.sandbox,
  })  : _apiClient = CredoApiClient(
          apiKey: apiKey,
          environment: environment,
        ),
        _environment = environment {
    _paymentService = PaymentService(_apiClient);
  }

  final CredoApiClient _apiClient;
  final CredoEnvironment _environment;
  late final PaymentService _paymentService;

  /// Get payment service
  PaymentService get payment => _paymentService;

  /// Get current environment
  CredoEnvironment get environment => _environment;

  Future<InitializePaymentResponse> initializePayment(
    InitializePaymentRequest request,
  ) =>
      _paymentService.initializePayment(request);

  /// Verify a payment transaction via your secure backend (RECOMMENDED)
  ///
  /// This keeps your Secret Key off the mobile device.
  Future<VerifyPaymentResponse> verifyPaymentViaBackend(
    String backendUrl,
    String transRef, {
    Map<String, String>? headers,
  }) =>
      _paymentService.verifyPaymentViaBackend(
        backendUrl,
        transRef,
        headers: headers,
      );

  /// Verify a payment transaction directly (NOT RECOMMENDED for production)
  ///
  /// ONLY use this for sandbox testing. Never use with Secret Keys in production.
  Future<VerifyPaymentResponse> verifyPaymentDirectly(String transRef) =>
      _paymentService.verifyPaymentDirectly(
        VerifyPaymentRequest(transRef: transRef),
      );
}
