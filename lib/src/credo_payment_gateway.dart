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

  /// Initializes a new payment transaction.
  ///
  /// This is the first step in the payment flow. It returns an [InitializePaymentResponse]
  /// which includes the `authorizationUrl` needed to open the checkout WebView.
  Future<InitializePaymentResponse> initializePayment(
    InitializePaymentRequest request,
  ) =>
      _paymentService.initializePayment(request);

  /// Verifies a payment transaction via your secure backend servant (RECOMMENDED).
  ///
  /// For production, you should never store your Secret Key in the mobile app.
  /// Use this method to hit your server endpoint, which will proxy the
  /// request to Credo using your Secret Key and return the status.
  ///
  /// * [backendUrl]: The full endpoint URL of your verification service.
  /// * [transRef]: The transaction reference obtained after initialization.
  /// * [headers]: Optional headers (e.g., Auth tokens) for your backend.
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

  /// Verifies a payment transaction directly with Credo (NOT RECOMMENDED for production).
  ///
  /// **WARNING**: This requires a Secret Key which should NEVER be embedded
  /// in a client-side application. Only use this for rapid prototyping
  /// in a sandbox environment.
  Future<VerifyPaymentResponse> verifyPaymentDirectly(String transRef) =>
      _paymentService.verifyPaymentDirectly(
        VerifyPaymentRequest(transRef: transRef),
      );
}
