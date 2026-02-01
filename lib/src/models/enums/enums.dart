/// Environment for Credo API
enum CredoEnvironment {
  /// Production environment
  production('https://api.credocentral.com'),

  /// Sandbox/Test environment
  sandbox('https://api.credodemo.com');

  const CredoEnvironment(this.baseUrl);

  /// Base URL for the environment
  final String baseUrl;
}

/// Currency codes supported by Credo
enum Currency {
  /// Nigerian Naira
  ngn('NGN'),

  /// US Dollar
  usd('USD');

  const Currency(this.code);

  /// Currency code
  final String code;
}

/// Payment channels available
enum PaymentChannel {
  /// Card payment
  card('Card'),

  /// Bank transfer
  bank('bank'),

  /// USSD payment
  ussd('USSD'),

  /// QR code payment
  qr('QR'),

  /// Mobile money
  mobileMoney('mobile_money'),

  /// Bank transfer
  bankTransfer('bank_transfer');

  const PaymentChannel(this.value);

  /// Channel value
  final String value;
}

/// Transaction status codes
enum TransactionStatus {
  /// Successful transaction
  successful(0, 'Successful'),

  /// Successful transaction that has been refunded
  refunded(1, 'Refunded'),

  /// Successful transaction that is queued for a refund
  refund(2, 'Refund'),

  /// Failed transaction
  failed(3, 'Failed'),

  /// Successful transaction that is being queued for settlement
  settle(4, 'Settle'),

  /// Successful transaction that has been settled
  settled(5, 'Settled'),

  /// Flagged transaction that requires human review
  review(6, 'Review'),

  /// The declination of a transaction that failed the fraud check
  declined(7, 'Declined'),

  /// Customer cancelled the payment
  cancelledByCustomer(9, 'Cancelled'),

  /// Merchant cancelled the payment
  cancelledByMerchant(10, 'Cancelled'),

  /// Account number generated, expecting credit notification from the bank
  attempted(12, 'Attempted'),

  /// Customer has attempted to make a payment
  attemptedPayment(13, 'Attempted'),

  /// The payment URL was successfully loaded on the customer's browser
  initialised(14, 'Initialised'),

  /// The merchant had just sent the payment request and the gateway had returned the payment URL
  initialising(15, 'Initialising');

  const TransactionStatus(this.code, this.text);

  /// Status code
  final int code;

  /// Status text
  final String text;

  /// Get status from code
  static TransactionStatus fromCode(int code) {
    return TransactionStatus.values.firstWhere(
      (status) => status.code == code,
      orElse: () => TransactionStatus.failed,
    );
  }
}
