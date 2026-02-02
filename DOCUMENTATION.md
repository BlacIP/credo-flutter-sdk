# Credo Flutter SDK - Integration Guide

The Credo Flutter SDK provides methods that allow developers to build a secure and convenient payment flow for their Flutter applications. Integration is a simple two-step process:

1.  **Initiate the transaction**: Get an authorization URL from the SDK (Client) or API (Server).
2.  **Complete it on the SDK**: Use the `CredoPaymentWebView` to handle the checkout.

> [!NOTE]
> The benefit of this flow is that you keep your **Secret Key** away from the client side, which is a secure standard practice.

---

## � Project Requirements

The Credo Flutter SDK adopts modern patterns which limit the older versions of OSs we support. Ensure your project meets these requirements:

- **Flutter**: `>= 3.0.0`
- **iOS**: `>= 13.0`
- **Android**: `Min SDK 21` and `Compile SDK 34`

> [!IMPORTANT]
> **Android Activity Requirement**  
> Ensure your `MainActivity` in the `android` folder extends `FlutterActivity` or `FlutterFragmentActivity` for optimal WebView performance.

---

## 🚀 Getting Started

To add the Credo Flutter SDK to your project, run the command below in your terminal:

```bash
flutter pub add credo_flutter_sdk
```

This command adds `credo_flutter_sdk` to your package's dependencies in the `pubspec.yaml` file and installs it. To use the library, import it in your `.dart` file:

```dart
import 'package:credo_flutter_sdk/credo_flutter_sdk.dart';
```

---

## 🛡️ Secret Key Safeguarding

> [!CAUTION]
> **Do not make API requests that require your Secret Key directly from your mobile app.**  
> Your Secret Key should only be used on your secure server. Use your **Public Key** for SDK initialization.

---

## � CredoPaymentGateway Class

The `CredoPaymentGateway` class provides methods for managing payments. 

### Initialization
```dart
final credo = CredoPaymentGateway(
  apiKey: 'pk_domain_xxxxxx',
  environment: CredoEnvironment.sandbox,
);
```

### `initializePayment()`
This method prepares a transaction. It returns an `InitializePaymentResponse` containing the `authorizationUrl`.

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `request` | `InitializePaymentRequest` | Yes | Object containing amount, email, and config. |

**Method Usage:**
```dart
try {
  final response = await credo.initializePayment(
    InitializePaymentRequest(
      email: 'customer@email.com',
      amount: 5000, // ₦50.00
    ),
  );
  
  if (response.isSuccessful) {
    // Navigate to WebView
  }
} catch (e) {
  print('Initialization failed: $e');
}
```

---

## � UI Components

### `CredoPaymentWebView`
This widget loads the payment UI.

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `authorizationUrl` | `String` | Yes | The URL from initialization. |
| `onSuccess` | `Function(String)`| Yes | Callback with transaction reference. |
| `onCancelled` | `VoidCallback` | No | Callback when user closes WebView manually. |

---

## ✅ Transaction Verification

### `verifyPaymentViaBackend()`
**[RECOMMENDED]** Use this to verify transactions securely via your server.

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `backendUrl` | `String` | Yes | Your server's verification endpoint. |
| `transRef` | `String` | Yes | The reference from `onSuccess`. |
| `headers` | `Map<String, String>`| No | Auth headers for your backend. |

**Method Usage:**
```dart
final result = await credo.verifyPaymentViaBackend(
  'https://your-api.com/verify',
  reference,
);

if (result.status == TransactionStatus.successful) {
  print('Transaction confirmed!');
}
```

---

## ⚠️ Error Handling

| Exception | Description |
| :--- | :--- |
| `CredoApiException` | API rejected request. Check `statusCode` and `errors`. |
| `CredoNetworkException` | Internet connectivity or TLS error. |
| `CredoValidationException`| Missing required fields in your request model. |
| `CredoWebViewException` | Error loading the checkout page. |

---

## 🔐 Webhooks

Credo sends server-to-server notifications called Webhooks.

**Endpoint Signature Verification:**
Confirm the authenticity of notifications using the `credo-signature` header.

Algorithm: `sha256(merchantToken + transRef + businessRef)`
