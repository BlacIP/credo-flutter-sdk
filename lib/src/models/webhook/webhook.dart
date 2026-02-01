/// Webhook payload from Credo
class WebhookPayload {
  /// Creates a webhook payload
  const WebhookPayload({
    required this.event,
    required this.transref,
    required this.reference,
    required this.debitedamount,
    required this.transamount,
    required this.transfeeamount,
    required this.settlementamount,
    required this.customerId,
    required this.transactionDate,
    required this.currencyCode,
    required this.status,
    required this.crn,
    required this.paymentMethod,
    required this.narration,
    required this.customer,
    this.metadata,
  });

  /// Event type (e.g., "transaction.successful")
  final String event;

  /// Transaction reference
  final String transref;

  /// Business reference
  final String reference;

  /// Debited amount
  final String debitedamount;

  /// Transaction amount
  final String transamount;

  /// Transaction fee amount
  final String transfeeamount;

  /// Settlement amount
  final String settlementamount;

  /// Customer ID
  final String customerId;

  /// Transaction date
  final String transactionDate;

  /// Currency code
  final String currencyCode;

  /// Transaction status
  final int status;

  /// Customer Reference Number
  final String crn;

  /// Payment method
  final String paymentMethod;

  /// Narration
  final String narration;

  /// Customer information
  final WebhookCustomer customer;

  /// Metadata array
  final List<WebhookMetadata>? metadata;

  /// Create from JSON
  factory WebhookPayload.fromJson(Map<String, dynamic> json) {
    return WebhookPayload(
      event: json['event'] as String,
      transref: json['transref'] as String,
      reference: json['reference'] as String,
      debitedamount: json['debitedamount'] as String,
      transamount: json['transamount'] as String,
      transfeeamount: json['transfeeamount'] as String,
      settlementamount: json['settlementamount'] as String,
      customerId: json['customerId'] as String,
      transactionDate: json['transactionDate'] as String,
      currencyCode: json['currencyCode'] as String,
      status: json['status'] as int,
      crn: json['crn'] as String,
      paymentMethod: json['paymentMethod'] as String,
      narration: json['narration'] as String,
      customer:
          WebhookCustomer.fromJson(json['customer'] as Map<String, dynamic>),
      metadata: json['metadata'] != null
          ? (json['metadata'] as List)
              .map((e) => WebhookMetadata.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'event': event,
        'transref': transref,
        'reference': reference,
        'debitedamount': debitedamount,
        'transamount': transamount,
        'transfeeamount': transfeeamount,
        'settlementamount': settlementamount,
        'customerId': customerId,
        'transactionDate': transactionDate,
        'currencyCode': currencyCode,
        'status': status,
        'crn': crn,
        'paymentMethod': paymentMethod,
        'narration': narration,
        'customer': customer.toJson(),
        if (metadata != null)
          'metadata': metadata!.map((e) => e.toJson()).toList(),
      };
}

/// Customer information in webhook
class WebhookCustomer {
  /// Creates webhook customer
  const WebhookCustomer({
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNo,
  });

  /// Customer email
  final String email;

  /// Customer first name
  final String? firstName;

  /// Customer last name
  final String? lastName;

  /// Customer phone number
  final String? phoneNo;

  /// Create from JSON
  factory WebhookCustomer.fromJson(Map<String, dynamic> json) {
    return WebhookCustomer(
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNo: json['phoneNo'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'email': email,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phoneNo != null) 'phoneNo': phoneNo,
      };
}

/// Metadata in webhook
class WebhookMetadata {
  /// Creates webhook metadata
  const WebhookMetadata({
    required this.insightTag,
    required this.insightValue,
  });

  /// Insight tag
  final String insightTag;

  /// Insight value
  final String insightValue;

  /// Create from JSON
  factory WebhookMetadata.fromJson(Map<String, dynamic> json) {
    return WebhookMetadata(
      insightTag: json['insightTag'] as String,
      insightValue: json['insightValue'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'insightTag': insightTag,
        'insightValue': insightValue,
      };
}
