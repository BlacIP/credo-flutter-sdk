import 'package:http/http.dart' as http;
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
    http.Client? httpClient,
    Duration timeout = const Duration(seconds: 30),
    String? userAgent,
  })  : _apiClient = CredoApiClient(
          apiKey: apiKey,
          environment: environment,
          httpClient: httpClient,
          timeout: timeout,
          userAgent: userAgent,
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
    InitializePaymentRequest request, {
    String? idempotencyKey,
  }) =>
      _paymentService.initializePayment(
        request,
        idempotencyKey: idempotencyKey,
      );

  /// Close the underlying HTTP client (if owned by the SDK).
  void close() => _apiClient.close();
}
