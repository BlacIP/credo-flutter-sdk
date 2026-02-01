/// Base class for all Credo exceptions
class CredoException implements Exception {
  /// Creates a Credo exception
  const CredoException(this.message, [this.details]);

  /// Error message
  final String message;

  /// Additional error details
  final dynamic details;

  @override
  String toString() =>
      'CredoException: $message${details != null ? ' - $details' : ''}';
}

/// Exception thrown when API request fails
class CredoApiException extends CredoException {
  /// Creates an API exception
  const CredoApiException(
    String message, {
    this.statusCode,
    this.errors,
    dynamic details,
  }) : super(message, details);

  /// HTTP status code
  final int? statusCode;

  /// Error list from API
  final List<String>? errors;

  @override
  String toString() {
    final buffer = StringBuffer('CredoApiException: $message');
    if (statusCode != null) buffer.write(' (Status: $statusCode)');
    if (errors != null && errors!.isNotEmpty) {
      buffer.write('\nErrors: ${errors!.join(', ')}');
    }
    return buffer.toString();
  }
}

/// Exception thrown when network request fails
class CredoNetworkException extends CredoException {
  /// Creates a network exception
  const CredoNetworkException(super.message, [super.details]);

  @override
  String toString() => 'CredoNetworkException: $message';
}

/// Exception thrown when validation fails
class CredoValidationException extends CredoException {
  /// Creates a validation exception
  const CredoValidationException(super.message, [super.details]);

  @override
  String toString() => 'CredoValidationException: $message';
}

/// Exception thrown when WebView operation fails
class CredoWebViewException extends CredoException {
  /// Creates a WebView exception
  const CredoWebViewException(super.message, [super.details]);

  @override
  String toString() => 'CredoWebViewException: $message';
}
