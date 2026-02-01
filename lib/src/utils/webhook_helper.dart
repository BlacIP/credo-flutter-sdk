import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Helper for handling Credo Webhooks (intended for BACKEND use)
class WebhookHelper {
  /// Verifies the webhook signature using the MERCHANT TOKEN
  ///
  /// IMPORTANT: This should ONLY be used on your secure backend.
  /// NEVER place your Merchant Token in a mobile app.
  ///
  /// [signature] is the value of the 'credo-signature' header.
  /// [merchantToken] is your Credo Merchant Token.
  /// [transRef] is the Credo transaction reference from the payload.
  /// [businessRef] is your unique transaction reference from the payload.
  static bool verifySignature({
    required String signature,
    required String merchantToken,
    required String transRef,
    required String businessRef,
  }) {
    if (signature.isEmpty || merchantToken.isEmpty) return false;

    // Concat: merchant-token + transRef + businessRef
    final payload = '$merchantToken$transRef$businessRef';
    final bytes = utf8.encode(payload);
    final digest = sha256.convert(bytes);

    return digest.toString().toLowerCase() == signature.toLowerCase();
  }
}
