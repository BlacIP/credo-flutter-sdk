# Testing Guide for Credo Flutter SDK

## 🧪 Rapid Testing (Sandbox)

The fastest way to test the integration is to run the example app:

```bash
cd example
flutter run
```

### 1. Update your Public Key
In `example/lib/main.dart`, replace the placeholder with your **Sandbox Public Key**:

```dart
_credo = CredoPaymentGateway(
  apiKey: '0PUB...', // Your Sandbox Public Key
  environment: CredoEnvironment.sandbox,
);
```

### 2. Sandbox Test Cards
Use these cards when the checkout WebView opens:

| Scenario | Card Number | Expiry | CVV |
| :--- | :--- | :--- | :--- |
| **Successful Payment** | `4012 0000 3333 0026` | `09/27` | `556` |
| **Skip 3DS Form** | `5555 5555 5555 4444` | `09/27` | `556` |

---

## 📱 Core Flow Testing

### 1. Payment Initialization
Verify that `credo.initializePayment()` returns a valid `authorizationUrl` and `reference`. If it fails:
- Check that your `amount` is > 0.
- Ensure your `apiKey` has the correct permissions for the environment.

### 2. WebView Interaction
- **Mobile**: Confirm the `CredoPaymentWebView` opens correctly and detects the success URL to trigger `onSuccess`.
- **Web/Desktop**: Ensure `url_launcher` opens a new tab and your app sends the reference to your backend for verification when the user returns.

---

## 🛡️ Backend Verification

After `onSuccess`, send the transaction reference to your backend and verify
with your Secret Key. This SDK does not perform verification on-device.

---

## 💡 Troubleshooting Checklist
- [ ] **401 Unauthorized**: Ensure you are using a **Public Key** in the app.
- [ ] **Empty WebView**: Verify your `callbackUrl` is valid.
