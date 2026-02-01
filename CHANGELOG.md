# Changelog

## [1.0.0] - 2026-02-01

### Added
- Core SDK for Credo Payment Gateway.
- Cross-platform support for Payment Initialization (Web, Mobile, Desktop).
- `CredoPaymentWebView` widget for secure in-app checkout.
- `verifyPaymentViaBackend` for security-first transaction validation.
- `WebhookHelper` for SHA256 signature verification (Merchant Token + Refs).
- Type-safe models for Requests, Responses, and Webhooks.
- Comprehensive `TransactionStatus` and `Currency` enums.
- Detailed error normalization with `CredoApiException`.

### Changed
- Refactored SDK to enforce **Secure-by-Design** principles.
- Removed client-side Secret Key requirements.
- Updated Webhook signature algorithm to SHA256 Concatenation.
- Improved Sandbox Simulation payload accuracy (Bank Transfer fees).

### Security
- Moved Transaction Verification to a server-mediated pattern (`verifyPaymentViaBackend`).
- Explicitly deprecated direct client-side verification with Secret Keys.
