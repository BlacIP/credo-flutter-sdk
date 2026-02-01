import '../enums/enums.dart';

/// Request to initialize a payment transaction
class InitializePaymentRequest {
  /// Creates an initialize payment request
  const InitializePaymentRequest({
    required this.email,
    required this.amount,
    this.reference,
    this.currency = Currency.ngn,
    this.metadata,
    this.callbackUrl,
    this.serviceCode,
    this.customerFirstName,
    this.customerLastName,
    this.customerPhoneNumber,
    this.bearer = 0,
    this.narration,
    this.initializeAccount = false,
    this.pauseSettlement = false,
    this.pauseSettlementDate,
    this.splitConfiguration,
    this.channels,
  });

  /// Customer email address (required)
  final String email;

  /// Amount in lowest currency unit, e.g., kobo for NGN (required)
  final int amount;

  /// Unique transaction reference (optional, auto-generated if not provided)
  final String? reference;

  /// Currency code (default: NGN)
  final Currency currency;

  /// Custom metadata object
  final Map<String, dynamic>? metadata;

  /// Callback URL after payment
  final String? callbackUrl;

  /// Service code for the transaction
  final String? serviceCode;

  /// Customer first name
  final String? customerFirstName;

  /// Customer last name
  final String? customerLastName;

  /// Customer phone number
  final String? customerPhoneNumber;

  /// Who bears the transaction charge (0 = customer, 1 = merchant)
  final int bearer;

  /// Transaction description
  final String? narration;

  /// Initialize virtual account for bank transfer
  final bool initializeAccount;

  /// Pause settlement (0 = no, 1 = yes)
  final bool pauseSettlement;

  /// Date to resume settlement (YYYY-MM-DD)
  final String? pauseSettlementDate;

  /// Split configuration for transaction
  final List<Map<String, dynamic>>? splitConfiguration;

  /// Payment channels to enable
  final List<PaymentChannel>? channels;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'email': email,
      'amount': amount,
      'currency': currency.code,
    };

    if (reference != null) json['reference'] = reference;
    if (metadata != null) json['metadata'] = metadata;
    if (callbackUrl != null) json['callbackUrl'] = callbackUrl;
    if (serviceCode != null) json['serviceCode'] = serviceCode;
    if (customerFirstName != null)
      json['customerFirstName'] = customerFirstName;
    if (customerLastName != null) json['customerLastName'] = customerLastName;
    if (customerPhoneNumber != null)
      json['customerPhoneNumber'] = customerPhoneNumber;
    json['bearer'] = bearer;
    if (narration != null) json['narration'] = narration;
    json['initializeAccount'] = initializeAccount ? 1 : 0;
    json['pauseSettlement'] = pauseSettlement ? 1 : 0;
    if (pauseSettlementDate != null)
      json['pauseSettlementDate'] = pauseSettlementDate;
    if (splitConfiguration != null)
      json['splitConfiguration'] = splitConfiguration;
    if (channels != null) {
      json['channels'] = channels!.map((c) => c.value).toList();
    }

    return json;
  }
}

/// Request to verify a payment transaction
class VerifyPaymentRequest {
  /// Creates a verify payment request
  const VerifyPaymentRequest({
    required this.transRef,
  });

  /// Transaction reference to verify
  final String transRef;
}
