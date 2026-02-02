import '../enums/enums.dart';

/// Response model returned after initializing a payment transaction.
///
/// Contains the authorization URL for UI redirection and transaction identifiers.
class InitializePaymentResponse {
  /// Creates an [InitializePaymentResponse].
  const InitializePaymentResponse({
    required this.status,
    required this.message,
    this.authorizationUrl,
    this.reference,
    this.credoReference,
    this.crn,
    this.account,
    this.execTime,
    this.error,
  });

  /// The numeric status code returned by the API.
  /// Typically `200` or `201` for success.
  final int status;

  /// A human-readable message describing the result of the initialization.
  final String message;

  /// The secure URL used to redirect the customer to the Credo payment page.
  final String? authorizationUrl;

  /// Your unique transaction reference.
  final String? reference;

  /// Credo's internal reference for this transaction.
  final String? credoReference;

  /// Customer Reference Number (CRN).
  final String? crn;

  /// Detailed virtual account information if `initializeAccount` was requested.
  final VirtualAccount? account;

  /// Time taken for the API to process the request (in milliseconds).
  final int? execTime;

  /// A list of error strings if the request failed validation.
  final List<String>? error;

  /// Check if response is successful
  bool get isSuccessful => status == 200 || status == 201 || status == 0;

  /// Create from JSON
  /// Create from JSON
  factory InitializePaymentResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Determine if data is nested or at root
      final data = json['data'] != null && json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : json;

      // Resilient status parsing
      final statusValue = json['status'] ?? data['status'];
      final status = statusValue is int
          ? statusValue
          : (int.tryParse(statusValue?.toString() ?? '') ?? 0);

      // Resilient message parsing
      final message = json['message']?.toString() ??
          (data['message']?.toString() ??
              (json['status_message']?.toString() ?? ''));

      // Look for execTime in both root and data
      final execTimeValue = json['execTime'] ??
          (json['exec_time'] ?? (data['execTime'] ?? data['exec_time']));
      final execTime = execTimeValue is num
          ? execTimeValue.toInt()
          : (int.tryParse(execTimeValue?.toString() ?? ''));

      return InitializePaymentResponse(
        status: status,
        message: message,
        authorizationUrl: (data['authorizationUrl'] ??
                data['checkoutUrl'] ??
                data['paymentUrl'] ??
                data['paymentLink'])
            ?.toString(),
        reference: (data['reference'] ?? data['transRef'])?.toString(),
        credoReference:
            (data['credoReference'] ?? data['credo_reference'])?.toString(),
        crn: (data['crn'] ?? data['customer_reference_number'])?.toString(),
        account: data['account'] != null &&
                data['account'] is Map<String, dynamic>
            ? VirtualAccount.fromJson(data['account'] as Map<String, dynamic>)
            : null,
        execTime: execTime,
        error: json['error'] != null
            ? (json['error'] is List
                ? List<String>.from(json['error'] as List)
                : [json['error'].toString()])
            : null,
      );
    } catch (e, stack) {
      // ignore: avoid_print
      print('CRITICAL: InitializePaymentResponse.fromJson failed: $e\n$stack');
      rethrow;
    }
  }
}

/// Virtual account details
class VirtualAccount {
  /// Creates virtual account
  const VirtualAccount({
    required this.accountNumber,
    required this.bankName,
    required this.accountName,
    this.amount,
  });

  /// The unique bank account number.
  final String accountNumber;

  /// The name of the bank providing the virtual account.
  final String bankName;

  /// The intended name for the account.
  final String accountName;

  /// The precise amount the customer should transfer, including any fees.
  final double? amount;

  /// Create from JSON
  /// Create from JSON
  factory VirtualAccount.fromJson(Map<String, dynamic> json) {
    return VirtualAccount(
      accountNumber:
          (json['accountNumber'] ?? (json['account_number'] ?? '')).toString(),
      bankName: (json['bankName'] ?? (json['bank_name'] ?? '')).toString(),
      accountName:
          (json['accountName'] ?? (json['account_name'] ?? '')).toString(),
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? ''),
    );
  }
}

/// Response from payment verification
class VerifyPaymentResponse {
  /// Creates a verify payment response
  const VerifyPaymentResponse({
    this.status,
    this.responseStatus,
    this.message,
    this.transRef,
    this.businessRef,
    this.debitedAmount,
    this.transAmount,
    this.transFeeAmount,
    this.settlementAmount,
    this.customerId,
    this.transactionDate,
    this.currencyCode,
    this.paymentMethod,
    this.narration,
  });

  /// Transaction status enum
  final TransactionStatus? status;

  /// Root response status code (e.g., 200)
  final int? responseStatus;

  /// Response message
  final String? message;

  /// Transaction reference
  final String? transRef;

  /// Business reference
  final String? businessRef;

  /// Debited amount
  final String? debitedAmount;

  /// Transaction amount
  final String? transAmount;

  /// Transaction fee amount
  final String? transFeeAmount;

  /// Settlement amount
  final String? settlementAmount;

  /// Customer ID
  final String? customerId;

  /// Transaction date
  final String? transactionDate;

  /// Currency code
  final String? currencyCode;

  /// Payment method
  final String? paymentMethod;

  /// Narration
  final String? narration;

  /// Check if transaction was successful
  bool get isSuccessful => responseStatus == 200;

  /// Create from JSON
  factory VerifyPaymentResponse.fromJson(Map<String, dynamic> json) {
    // Support both root level and nested 'data' object
    final data = json['data'] != null && json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return VerifyPaymentResponse(
      status: data['status'] != null
          ? (data['status'] is int
              ? TransactionStatus.fromCode(data['status'] as int)
              : (int.tryParse(data['status'].toString()) != null
                  ? TransactionStatus.fromCode(
                      int.parse(data['status'].toString()))
                  : null))
          : null,
      responseStatus: json['status'] as int?,
      message: json['message'] as String?,
      transRef: data['transRef'] as String?,
      businessRef: data['businessRef'] as String?,
      debitedAmount: data['debitedAmount']?.toString(),
      transAmount: data['transAmount']?.toString(),
      transFeeAmount: data['transFeeAmount']?.toString(),
      settlementAmount: data['settlementAmount']?.toString(),
      customerId: data['customerId']?.toString(),
      transactionDate: data['transactionDate'] as String?,
      currencyCode: data['currencyCode'] as String?,
      paymentMethod: data['paymentMethod'] as String?,
      narration: data['narration'] as String?,
    );
  }
}
