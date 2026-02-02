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
- **Web/Desktop**: Ensure `url_launcher` opens a new tab and you provide a manual "Verify" button for when the user returns.

---

## 🛡️ Security & Verification Testing

### 1. Direct Verification (Dev Only)
Use `verifyPaymentDirectly()` **only** during development to quickly check status:

```dart
final response = await credo.verifyPaymentDirectly(reference);
expect(response.isSuccessful, true);
```

### 2. Backend-Mediated Verification (Production Mock)
Test your production flow by mocking your backend endpoint:

```dart
// Mock endpoint: https://mock.api/verify?transRef=REF
final response = await credo.verifyPaymentViaBackend(
  'https://mock.api/verify',
  reference,
);
```

---

## 🛠️ Webhook Simulation
To test webhooks on your backend:
1. Initialize a payment with a `reference`.
2. Use the **Simulate Bank Transfer** button in the example app.
3. Verify that your backend receives a POST request with a valid `credo-signature`.

### Signature Verification Test
Verify your algorithm matches Credo's expectation:
`SHA256(merchantToken + transRef + businessRef)`

---

## 💡 Troubleshooting Checklist
- [ ] **Rejected (Simulation)**: Check that `feeAmount` is included in your simulation call.
- [ ] **401 Unauthorized**: Ensure you are using a **Public Key** in the app.
- [ ] **Empty WebView**: Verify your `callbackUrl` is valid.
