# Credo Flutter SDK

The official Flutter SDK for integrating [Credo Payment Gateway](https://credocentral.com) into your Flutter applications. The Credo Flutter SDK provides methods that allow developers to build a secure and convenient payment flow.

Integration is a simple two-step process:
1.  **Initiate the transaction** on the SDK (Client) or API (Server).
2.  **Complete it** on the SDK using the `CredoPaymentWebView`.

---

## 🛠 Project Requirements

- **Flutter**: `>= 3.0.0`
- **iOS**: `>= 13.0`
- **Android**: `Min SDK 21`

---

## 🚀 Getting Started

To add the Credo Flutter SDK to your project, run the command below:

```bash
flutter pub add credo_flutter_sdk
```

This command adds `credo_flutter_sdk` to your `pubspec.yaml`. To use the library, import it:

```dart
import 'package:credo_flutter_sdk/credo_flutter_sdk.dart';
```

---

## 🛡️ Secret Key Safeguarding

> [!CAUTION]
> **Do not make API requests that require your Secret Key directly from your mobile app.**  
> Your Secret Key should only be used on your secure server. Use your **Public Key** for SDK initialization.

---

## ⚡ Quick Start

### 1. Initialize the Gateway
```dart
final credo = CredoPaymentGateway(
  apiKey: 'pk_domain_xxxxxx',
  environment: CredoEnvironment.sandbox,
);
```

### 2. Initialize Payment
```dart
final response = await credo.initializePayment(
  InitializePaymentRequest(
    email: 'user@example.com',
    amount: 10000, // ₦100.00
  ),
);
```

### 3. Launch Checkout
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CredoPaymentWebView(
      authorizationUrl: response.authorizationUrl!,
      callbackUrl: 'https://your-app.com/callback',
      onSuccess: (ref) => handleSuccess(ref),
      onError: (error) => handleError(error),
      onCancelled: () => handleCancel(),
    ),
  ),
);
```
> After successful payment, send the reference to your backend for verification.

---

## 📖 Documentation
- Developer reference: `DOCUMENTATION.md`
- Integration walkthrough: `GUIDE.md`

## Support
Contact [support@credocentral.com](mailto:support@credocentral.com) for technical assistance.

## License
MIT License. See [LICENSE](LICENSE).
