/// Base class for all exceptions thrown by the Credo SDK.
///
/// Catch this type to handle any error originating from the Credo library.
class CredoException implements Exception {
  /// Creates a [CredoException].
  const CredoException(this.message, [this.details]);

  /// A descriptive message explaining the error.
  final String message;

  /// Optional additional details or the original underlying error.
  final dynamic details;

  @override
  String toString() =>
      'CredoException: $message${details != null ? ' - $details' : ''}';
}

/// Exception thrown when a Credo API request returns a non-success status code.
///
/// Use [statusCode] and [errors] to debug specifically why the API rejected the request.
class CredoApiException extends CredoException {
  /// Creates a [CredoApiException].
  const CredoApiException(
    String message, {
    this.statusCode,
    this.errors,
    dynamic details,
  }) : super(message, details);

  /// The HTTP status code returned by the server (e.g. 400, 401, 500).
  final int? statusCode;

  /// A list of specific validation or logic errors returned by the Credo API.
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

/// Exception thrown when a network-level failure occurs (e.g. no internet).
class CredoNetworkException extends CredoException {
  /// Creates a [CredoNetworkException].
  const CredoNetworkException(super.message, [super.details]);

  @override
  String toString() => 'CredoNetworkException: $message';
}

/// Exception thrown when request parameters fail local validation.
class CredoValidationException extends CredoException {
  /// Creates a [CredoValidationException].
  const CredoValidationException(super.message, [super.details]);

  @override
  String toString() => 'CredoValidationException: $message';
}

/// Exception thrown when an error occurs within the checkout WebView.
class CredoWebViewException extends CredoException {
  /// Creates a [CredoWebViewException].
  const CredoWebViewException(super.message, [super.details]);

  @override
  String toString() => 'CredoWebViewException: $message';
}
