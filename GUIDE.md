# Credo Flutter SDK - Integration Guide

This guide walks you through a complete integration of Credo hosted checkout
in a Flutter app. It focuses on the **workflow**, not API reference details.

For full API details, see `DOCUMENTATION.md`.

---

## 1) Install the SDK

```bash
flutter pub add credo_flutter_sdk
```

Import:
```dart
import 'package:credo_flutter_sdk/credo_flutter_sdk.dart';
```

---

## 2) Initialize the SDK client

```dart
final credo = CredoPaymentGateway(
  apiKey: 'pk_domain_xxxxxx',
  environment: CredoEnvironment.sandbox,
);
```

---

## 3) Initialize a payment

```dart
final response = await credo.initializePayment(
  InitializePaymentRequest(
    email: 'customer@email.com',
    amount: 10000, // NGN 100.00
    callbackUrl: 'https://your-app.com/callback',
  ),
);
```

Make sure the `callbackUrl` here matches the one you will pass into the
checkout UI.

---

## 4) Launch the checkout UI

You have two options:

### Option A (Quick): `CredoCheckout.launch(...)`
```dart
final result = await CredoCheckout.launch(
  context: context,
  authorizationUrl: response.authorizationUrl!,
  callbackUrl: 'https://your-app.com/callback',
);

if (result.isSuccessful) {
  // Send result.reference to your backend for verification
} else if (result.isPending) {
  // Checkout opened externally (web/desktop). Verify on backend after return.
}
```

### Option B (Custom UI): `CredoPaymentWebView`
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CredoPaymentWebView(
      authorizationUrl: response.authorizationUrl!,
      callbackUrl: 'https://your-app.com/callback',
      onSuccess: (reference) => handleSuccess(reference),
      onError: (error) => handleError(error),
      onCancelled: () => handleCancel(),
      showAppBar: false, // Optional
    ),
  ),
);
```

---

## 5) Verify on your backend (Required)

After `onSuccess`, send the transaction reference to your backend. Your backend
must verify the payment using your **Secret Key**:

```
GET /transaction/{transRef}/verify
Authorization: <SECRET_KEY>
```

Use the verification response as the **source of truth** before fulfilling
an order.

---

## 6) Web/Desktop flow (Optional)

For Flutter Web or desktop apps, you may prefer opening the checkout URL in the
system browser using `CredoCheckout.launch(...)`, which will return a
`pending` result after opening the browser. After the user completes payment,
your app should verify the reference on the backend when the user returns.

---

## Sandbox Testing

Use sandbox keys and test cards. Example cards:

- `4012 0000 3333 0026` (standard test card)
- `5555 5555 5555 4444` (skip 3DS form)

---

## Common Issues

- **Callback not detected**: Ensure `callbackUrl` matches in initialization and
  WebView/launch.
- **401 Unauthorized**: Confirm you are using a **Public Key** in the app.
- **No authorizationUrl**: Initialization failed; inspect response status/message.

---

## Production Checklist

- Use **Live Public Key** in the app.
- Verify **all transactions on backend** using Secret Key.
- Store transaction reference and authorizationUrl for recovery.
- Configure webhooks (server-side) if needed.
