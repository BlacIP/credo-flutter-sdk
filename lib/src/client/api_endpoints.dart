/// API endpoint constants
class ApiEndpoints {
  /// Private constructor
  ApiEndpoints._();

  /// Initialize payment transaction
  static const String initializePayment = '/transaction/initialize';

  /// Verify payment transaction
  static String verifyPayment(String transRef) =>
      '/transaction/$transRef/verify';
}
