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
    this.billNumber,
    this.billInformation,
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

  /// Bill number associated with the transaction (if applicable).
  final String? billNumber;

  /// Additional bill information (if applicable).
  final BillInformation? billInformation;

  /// Time taken for the API to process the request (in milliseconds).
  final double? execTime;

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
          ? execTimeValue.toDouble()
          : double.tryParse(execTimeValue?.toString() ?? '');

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
        billNumber: (data['billNumber'] ?? data['bill_number'])?.toString(),
        billInformation: data['billInformation'] != null &&
                data['billInformation'] is Map<String, dynamic>
            ? BillInformation.fromJson(
                data['billInformation'] as Map<String, dynamic>,
              )
            : null,
        execTime: execTime,
        error: json['error'] != null
            ? (json['error'] is List
                ? List<String>.from(json['error'] as List)
                : [json['error'].toString()])
            : null,
      );
    } catch (e) {
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
    this.expiryDate,
  });

  /// The unique bank account number.
  final String accountNumber;

  /// The name of the bank providing the virtual account.
  final String bankName;

  /// The intended name for the account.
  final String accountName;

  /// The precise amount the customer should transfer, including any fees.
  final double? amount;

  /// The date/time when the virtual account expires (if provided).
  final String? expiryDate;

  /// Parsed expiry date as [DateTime] (if [expiryDate] is ISO 8601).
  DateTime? get expiryDateTime =>
      expiryDate != null ? DateTime.tryParse(expiryDate!) : null;

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
      expiryDate: (json['expiryDate'] ?? json['expiry_date'])?.toString(),
    );
  }
}

/// Additional bill information.
class BillInformation {
  /// Creates bill information.
  const BillInformation({
    this.amountDue,
    this.payerName,
    this.agencyName,
  });

  /// Outstanding amount due (if provided).
  final double? amountDue;

  /// Name of the payer.
  final String? payerName;

  /// Name of the agency responsible for the bill.
  final String? agencyName;

  /// Create from JSON.
  factory BillInformation.fromJson(Map<String, dynamic> json) {
    final amountDueValue = json['amountDue'] ?? json['amount_due'];
    final amountDue = amountDueValue is num
        ? amountDueValue.toDouble()
        : double.tryParse(amountDueValue?.toString() ?? '');

    return BillInformation(
      amountDue: amountDue,
      payerName: json['payerName']?.toString(),
      agencyName: json['agencyName']?.toString(),
    );
  }
}
