import '../client/api_endpoints.dart';
import '../client/credo_api_client.dart';
import '../exceptions/credo_exception.dart';
import '../models/requests/requests.dart';
import '../models/responses/responses.dart';

/// Service for payment operations
class PaymentService {
  /// Creates a payment service
  const PaymentService(this._apiClient);

  final CredoApiClient _apiClient;

  Future<InitializePaymentResponse> initializePayment(
    InitializePaymentRequest request, {
    String? idempotencyKey,
  }) async {
    _validateInitializeRequest(request);
    final response = await _apiClient.post(
      ApiEndpoints.initializePayment,
      request.toJson(),
      idempotencyKey: idempotencyKey,
    );

    return InitializePaymentResponse.fromJson(response);
  }

  void _validateInitializeRequest(InitializePaymentRequest request) {
    final email = request.email.trim();
    if (email.isEmpty || !email.contains('@')) {
      throw const CredoValidationException('Invalid customer email address.');
    }

    if (request.amount <= 0) {
      throw const CredoValidationException('Amount must be greater than zero.');
    }

    if (request.reference != null && request.reference!.trim().isEmpty) {
      throw const CredoValidationException(
        'Reference cannot be an empty string.',
      );
    }

    if (request.callbackUrl != null) {
      final uri = Uri.tryParse(request.callbackUrl!);
      if (uri == null || !uri.hasScheme) {
        throw const CredoValidationException('Invalid callbackUrl provided.');
      }
    }

    if (request.channels != null && request.channels!.isEmpty) {
      throw const CredoValidationException(
        'Channels cannot be an empty list when provided.',
      );
    }

    if (request.pauseSettlement &&
        (request.pauseSettlementDate == null ||
            request.pauseSettlementDate!.trim().isEmpty)) {
      throw const CredoValidationException(
        'pauseSettlementDate is required when pauseSettlement is true.',
      );
    }

    if (request.pauseSettlementDate != null) {
      final isValidDate =
          RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(request.pauseSettlementDate!);
      if (!isValidDate) {
        throw const CredoValidationException(
          'pauseSettlementDate must be in YYYY-MM-DD format.',
        );
      }
    }
  }
}
