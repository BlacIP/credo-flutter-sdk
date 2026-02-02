import '../enums/enums.dart';

/// Request model for initializing a payment transaction.
///
/// Use this to configure the payment checkout experience, including
/// customer details, amounts, and enabled payment channels.
class InitializePaymentRequest {
  /// Creates an [InitializePaymentRequest].
  ///
  /// * [email] is the customer's identifying email address.
  /// * [amount] is the transaction value in kobo (e.g. 10000 = ₦100.00).
  /// * [currency] defaults to [Currency.ngn].
  /// * [bearer] sets who pays transaction fees (0: Customer, 1: Merchant).
  /// * [initializeAccount] if true, generates a virtual account for bank transfer simulation.
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

  /// The customer's email address. Required for transaction tracking.
  final String email;

  /// The transaction amount in the lowest currency unit (e.g. kobo for NGN).
  /// For example, `10000` represents ₦100.00.
  final int amount;

  /// A unique reference for this transaction.
  /// If null, Credo will generate one automatically.
  final String? reference;

  /// The currency code for the transaction. Defaults to [Currency.ngn].
  final Currency currency;

  /// Custom metadata to save extra information with the transaction.
  /// Useful for linking order IDs or internal database keys.
  final Map<String, dynamic>? metadata;

  /// The URL to which Credo will redirect the customer after payment.
  final String? callbackUrl;

  /// The Credo service code for this transaction.
  final String? serviceCode;

  /// Customer's first name.
  final String? customerFirstName;

  /// Customer's last name.
  final String? customerLastName;

  /// Customer's phone number.
  final String? customerPhoneNumber;

  /// Specifies who bears the transaction fees.
  /// * `0`: Customer bears the cost.
  /// * `1`: Merchant bears the cost.
  final int bearer;

  /// A brief description of the transaction which appears on receipts.
  final String? narration;

  /// Whether to initialize a dedicated virtual account for this transaction.
  /// Required if you want to test Bank Transfer simulation.
  final bool initializeAccount;

  /// Whether to pause settlement for this specific transaction.
  final bool pauseSettlement;

  /// If [pauseSettlement] is true, the date to resume settlement (YYYY-MM-DD).
  final String? pauseSettlementDate;

  /// Configuration for splitting the transaction amount among sub-accounts.
  final List<Map<String, dynamic>>? splitConfiguration;

  /// A list of specific payment channels to enable for this transaction.
  /// If null, all active channels on your dashboard will be available.
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
