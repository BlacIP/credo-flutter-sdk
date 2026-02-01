# Credo Flutter SDK

Official Flutter SDK for integrating [Credo Payment Gateway](https://credocentral.com) into your Flutter applications. Accept payments via cards, bank transfers, USSD, and more with a focus on ease of use and security.

[![pub package](https://img.shields.io/pub/v/credo_flutter_sdk.svg)](https://pub.dev/packages/credo_flutter_sdk)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

✅ **Payment Initialization** - Cross-platform support for initializing payments (Web, Mobile, Desktop).  
✅ **Secure WebView** - Dedicated widget for handling the checkout flow and 3DS verification.  
✅ **Automatic Callbacks** - Listen for completion events and extract transaction references.  
✅ **Backend-Mediated Verification** - Securely verify transactions via your server.  
✅ **Webhook Security** - Robust SHA256 signature verification for backend security.  
✅ **Type-Safe Status** - Comprehensive enums for all Credo transaction states.

---

## 🛡️ Security Best Practices

> [!IMPORTANT]
> **Never store your Secret Key or Merchant Token in your Flutter application.**  
> Doing so allows attackers to decompile your app, steal your credentials, and spoof payments.

1.  **Public Key Only**: Only use your **Public API Key** inside your Flutter project.
2.  **Verify on Backend**: Use `verifyPaymentViaBackend()` to check transaction status through your secure server.
3.  **Validate Webhooks**: Use `WebhookHelper.verifySignature()` on your server to confirm that incoming payment notifications are authentically from Credo.

---

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  credo_flutter_sdk: ^1.0.0
```

## Quick Start

### 1. Initialize the SDK

```dart
import 'package:credo_flutter_sdk/credo_flutter_sdk.dart';

final credo = CredoPaymentGateway(
  apiKey: 'YOUR_PUBLIC_API_KEY',
  environment: CredoEnvironment.sandbox, // or production
);
```

### 2. Initialize a Payment

```dart
final request = InitializePaymentRequest(
  email: 'customer@example.com',
  amount: 10000, // Amount in kobo (₦100.00)
  currency: Currency.ngn,
);

final response = await credo.initializePayment(request);
```

### 3. Open Checkout WebView

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CredoPaymentWebView(
      authorizationUrl: response.authorizationUrl!,
      callbackUrl: 'https://your-callback-url.com',
      onSuccess: (reference) {
        Navigator.pop(context);
        handlePaymentSuccess(reference);
      },
      onError: (error) => print('Error: $error'),
      onCancelled: () => print('User cancelled'),
    ),
  ),
);
```

### 4. Verify Transaction (Secure Flow)

Verify the payment through your server to avoid exposing your Secret Key:

```dart
// The SDK hits your endpoint, which should then call Credo with your Secret Key
final result = await credo.verifyPaymentViaBackend(
  'https://your-api.com/verify', // Your backend URL
  reference,
);

if (result.isSuccessful) {
  print('Verified Status: ${result.status?.text}');
}
```

---

## 🛠️ Webhook Security (Backend Only)

When Credo notifies your server of a payment, verify the signature using the `WebhookHelper` (intended for Dart server-side use or as a logic reference):

```dart
final isValid = WebhookHelper.verifySignature(
  signature: headers['credo-signature'],
  merchantToken: 'YOUR_MERCHANT_TOKEN',
  transRef: payload['transref'],
  businessRef: payload['reference'],
);
```

## Support

- **Documentation**: [https://docs.credocentral.com](https://docs.credocentral.com)
- **Email**: support@credocentral.com

## License

MIT License. See [LICENSE](LICENSE) for details.
