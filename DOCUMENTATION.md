# Credo Flutter SDK - Developer Documentation

This document is the **developer reference** for the Flutter SDK. It focuses on
public classes, parameters, and behavior.

For a step-by-step integration walkthrough, see `GUIDE.md`.

---

## Overview

The Credo Flutter SDK is a **hosted-checkout SDK**. It opens Credo's checkout
page in a WebView and provides callbacks for success, failure, and cancellation.

**Security boundary**:
- The SDK uses **Public Keys** only.
- **Verification must happen on your backend** with your Secret Key.

---

## Requirements

- **Flutter**: `>= 3.0.0`
- **iOS**: `>= 13.0`
- **Android**: `Min SDK 21`, `Compile SDK 34`

> Android Activity requirement: ensure your `MainActivity` extends
> `FlutterActivity` or `FlutterFragmentActivity` for WebView compatibility.

---

## Installation

```bash
flutter pub add credo_flutter_sdk
```

Import:
```dart
import 'package:credo_flutter_sdk/credo_flutter_sdk.dart';
```

---

## Core API

### `CredoPaymentGateway`

Create the SDK client:
```dart
final credo = CredoPaymentGateway(
  apiKey: 'pk_domain_xxxxxx',
  environment: CredoEnvironment.sandbox,
);
```

Optional configuration:
- `httpClient`: provide a custom `http.Client` (useful for testing).
- `timeout`: request timeout (default: 30 seconds).
- `userAgent`: optional User-Agent header.

If you pass a custom `httpClient`, you are responsible for closing it. Otherwise
you can call `credo.close()` to dispose the internal client.

#### `initializePayment(InitializePaymentRequest request, {String? idempotencyKey})`
Initializes a transaction and returns an `InitializePaymentResponse` that
contains the `authorizationUrl` to load in the checkout UI.

> If you plan to use the SDK WebView, ensure `callbackUrl` in the request matches
> the `callbackUrl` passed to the WebView.

`idempotencyKey` (optional) is sent as the `Idempotency-Key` header.

---

## Request Models

### `InitializePaymentRequest`

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `email` | `String` | Yes | Customer email address. |
| `amount` | `int` | Yes | Amount in lowest currency unit (e.g., kobo). |
| `reference` | `String?` | No | Unique transaction reference. |
| `currency` | `Currency` | No | Defaults to `Currency.ngn`. |
| `metadata` | `Map<String, dynamic>?` | No | Custom metadata. |
| `callbackUrl` | `String?` | No | Redirect URL after payment. |
| `serviceCode` | `String?` | No | Credo service code. |
| `customerFirstName` | `String?` | No | Customer first name. |
| `customerLastName` | `String?` | No | Customer last name. |
| `customerPhoneNumber` | `String?` | No | Customer phone number. |
| `bearer` | `int` | No | `0` = customer, `1` = merchant. |
| `narration` | `String?` | No | Transaction narration. |
| `initializeAccount` | `bool` | No | Enable virtual account generation. |
| `pauseSettlement` | `bool` | No | Pause settlement for transaction. |
| `pauseSettlementDate` | `String?` | No | Resume date (YYYY-MM-DD). |
| `splitConfiguration` | `List<Map<String, dynamic>>?` | No | Split config list. |
| `channels` | `List<PaymentChannel>?` | No | Allowed payment channels. |

---

## Response Models

### `InitializePaymentResponse`

| Field | Type | Description |
| :--- | :--- | :--- |
| `status` | `int` | Status code from API. |
| `message` | `String` | Response message. |
| `authorizationUrl` | `String?` | URL to open in checkout. |
| `reference` | `String?` | Your transaction reference. |
| `credoReference` | `String?` | Credo reference. |
| `crn` | `String?` | Credo Reference Number. |
| `account` | `VirtualAccount?` | Virtual account details (if enabled). |
| `billNumber` | `String?` | Bill number associated with the transaction. |
| `billInformation` | `BillInformation?` | Additional bill information (if provided). |
| `execTime` | `double?` | Processing time in ms. |
| `error` | `List<String>?` | Error list (if any). |

`isSuccessful` is true for status `200`, `201`, or `0`.

### `VirtualAccount`

| Field | Type | Description |
| :--- | :--- | :--- |
| `accountNumber` | `String` | Virtual account number. |
| `bankName` | `String` | Bank name. |
| `accountName` | `String` | Account name. |
| `amount` | `double?` | Expected transfer amount (if provided). |
| `expiryDate` | `String?` | Virtual account expiry date/time (if provided). |

### `BillInformation`

| Field | Type | Description |
| :--- | :--- | :--- |
| `amountDue` | `double?` | Outstanding amount due (if provided). |
| `payerName` | `String?` | Name of the payer. |
| `agencyName` | `String?` | Name of the agency responsible for the bill. |

---

## Enums

### `CredoEnvironment`
- `production` → `https://api.credocentral.com`
- `sandbox` → `https://api.credodemo.com`

### `Currency`
- `ngn` → `NGN`
- `usd` → `USD`

### `PaymentChannel`
- `card`, `bank`, `ussd`, `qr`, `mobileMoney`, `bankTransfer`

### `TransactionStatus`
Codes:
`0` Successful, `1` Refunded, `2` Refund, `3` Failed, `4` Settle,
`5` Settled, `6` Review, `7` Declined, `9` Cancelled (customer),
`10` Cancelled (merchant), `12` Attempted (bank transfer created),
`13` Attempted (payment attempt), `14` Initialised, `15` Initialising.

> Note: statuses 14 and 15 may not appear in transaction history yet.

---

## UI Components

### `CredoPaymentWebView`
Low-level checkout widget with full control over UI.

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `authorizationUrl` | `String` | Yes | URL from initialization. |
| `callbackUrl` | `String` | Yes | Must match initialization callback. |
| `onSuccess` | `Function(String)` | Yes | Called with transaction reference. |
| `onError` | `Function(String)` | Yes | Called on load or payment failure. |
| `onCancelled` | `VoidCallback` | Yes | Called when user closes WebView. |
| `appBar` | `PreferredSizeWidget` | No | Custom AppBar. |
| `showAppBar` | `bool` | No | Show default AppBar (default: true). |
| `loadingWidget` | `Widget` | No | Custom loading widget. |

### `CredoCheckout.launch(...)`
High-level helper that opens the checkout and returns a result.

| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `context` | `BuildContext` | Yes | Build context for route push. |
| `authorizationUrl` | `String` | Yes | URL from initialization. |
| `callbackUrl` | `String` | Yes | Must match initialization callback. |
| `appBar` | `PreferredSizeWidget` | No | Custom AppBar. |
| `showAppBar` | `bool` | No | Show default AppBar (default: true). |
| `loadingWidget` | `Widget` | No | Custom loading widget. |
| `routeSettings` | `RouteSettings` | No | Optional route settings. |
| `useExternalBrowserOnWeb` | `bool` | No | Open checkout in external browser on web (default: true). |
| `useExternalBrowserOnDesktop` | `bool` | No | Open checkout in external browser on desktop (default: true). |
| `externalLaunchMode` | `LaunchMode` | No | `url_launcher` launch mode for external browser. |

#### `CredoCheckoutResult`
Returned from `launch()`:
- `status` → `CredoCheckoutStatus.success | cancelled | pending | failed`
- `reference` → transaction reference on success
- `message` → informational message (used for pending)
- `error` → failure message on error

---

## Exceptions

| Exception | Meaning |
| :--- | :--- |
| `CredoApiException` | API rejected request (check statusCode/errors). |
| `CredoNetworkException` | Network or connectivity failure. |
| `CredoValidationException` | Invalid parameters (if used by caller). |
| `CredoWebViewException` | WebView/checkout error. |

---

## Backend Verification (Required)

Verification is **backend-only**. Your backend should call:
`GET /transaction/{transRef}/verify` with your **Secret Key** and return the
status to the app.

---

## Web/Desktop Note

For Flutter Web/desktop apps, you may choose to open the `authorizationUrl`
in an external browser using `url_launcher` and then verify on return.
