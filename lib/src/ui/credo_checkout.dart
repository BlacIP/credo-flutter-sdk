import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'credo_payment_webview.dart';

/// Checkout result status for Credo hosted payment flow.
enum CredoCheckoutStatus {
  /// Payment completed successfully.
  success,

  /// User cancelled the checkout.
  cancelled,

  /// Checkout opened externally; completion is pending.
  pending,

  /// Checkout failed or returned an error.
  failed,
}

/// Result returned after completing a checkout flow.
class CredoCheckoutResult {
  /// Creates a checkout result.
  const CredoCheckoutResult({
    required this.status,
    this.reference,
    this.message,
    this.error,
  });

  /// Convenience constructor for successful result.
  const CredoCheckoutResult.success(String ref)
      : status = CredoCheckoutStatus.success,
        reference = ref,
        message = null,
        error = null;

  /// Convenience constructor for cancelled result.
  const CredoCheckoutResult.cancelled()
      : status = CredoCheckoutStatus.cancelled,
        reference = null,
        message = null,
        error = null;

  /// Convenience constructor for pending result.
  const CredoCheckoutResult.pending([String? info])
      : status = CredoCheckoutStatus.pending,
        reference = null,
        message = info,
        error = null;

  /// Convenience constructor for failed result.
  const CredoCheckoutResult.failed(String message)
      : status = CredoCheckoutStatus.failed,
        reference = null,
        message = null,
        error = message;

  /// Result status.
  final CredoCheckoutStatus status;

  /// Transaction reference (present when [status] is success).
  final String? reference;

  /// Optional message (used for informational results like [pending]).
  final String? message;

  /// Error message (present when [status] is failed).
  final String? error;

  /// Whether the checkout completed successfully.
  bool get isSuccessful => status == CredoCheckoutStatus.success;

  /// Whether the checkout is pending completion.
  bool get isPending => status == CredoCheckoutStatus.pending;
}

/// High-level checkout helper that launches the hosted payment flow.
class CredoCheckout {
  /// Launches the Credo hosted checkout flow.
  static Future<CredoCheckoutResult> launch({
    required BuildContext context,
    required String authorizationUrl,
    required String callbackUrl,
    PreferredSizeWidget? appBar,
    bool showAppBar = true,
    Widget? loadingWidget,
    RouteSettings? routeSettings,
    bool useExternalBrowserOnWeb = true,
    bool useExternalBrowserOnDesktop = true,
    LaunchMode externalLaunchMode = LaunchMode.externalApplication,
  }) async {
    if (_shouldUseExternalBrowser(
      useExternalBrowserOnWeb: useExternalBrowserOnWeb,
      useExternalBrowserOnDesktop: useExternalBrowserOnDesktop,
    )) {
      final uri = Uri.tryParse(authorizationUrl);
      if (uri == null) {
        return const CredoCheckoutResult.failed(
          'Invalid authorizationUrl provided.',
        );
      }

      bool launched;
      try {
        launched = await launchUrl(uri, mode: externalLaunchMode);
      } catch (_) {
        return const CredoCheckoutResult.failed(
          'Failed to launch external browser.',
        );
      }

      if (!launched) {
        return const CredoCheckoutResult.failed(
          'Could not open checkout in an external browser.',
        );
      }

      return const CredoCheckoutResult.pending(
        'Checkout opened in external browser. Verify on backend after return.',
      );
    }

    if (kIsWeb) {
      return const CredoCheckoutResult.failed(
        'Web checkout requires external browser launch.',
      );
    }

    final result = await Navigator.of(context).push<CredoCheckoutResult>(
      MaterialPageRoute(
        settings: routeSettings,
        builder: (context) => CredoPaymentWebView(
          authorizationUrl: authorizationUrl,
          callbackUrl: callbackUrl,
          onSuccess: (reference) {
            Navigator.of(context).pop(
              CredoCheckoutResult.success(reference),
            );
          },
          onError: (error) {
            Navigator.of(context).pop(
              CredoCheckoutResult.failed(error),
            );
          },
          onCancelled: () {
            Navigator.of(context).pop(
              const CredoCheckoutResult.cancelled(),
            );
          },
          appBar: appBar,
          showAppBar: showAppBar,
          loadingWidget: loadingWidget,
        ),
      ),
    );

    return result ?? const CredoCheckoutResult.cancelled();
  }

  static bool _shouldUseExternalBrowser({
    required bool useExternalBrowserOnWeb,
    required bool useExternalBrowserOnDesktop,
  }) {
    if (kIsWeb) return useExternalBrowserOnWeb;

    final isMobile = defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    return !isMobile && useExternalBrowserOnDesktop;
  }
}
