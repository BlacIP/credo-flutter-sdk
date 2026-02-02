import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// WebView widget for Credo payment authorization
class CredoPaymentWebView extends StatefulWidget {
  /// Creates a Credo payment WebView
  const CredoPaymentWebView({
    required this.authorizationUrl,
    required this.callbackUrl,
    required this.onSuccess,
    required this.onError,
    required this.onCancelled,
    this.appBar,
    this.showAppBar = true,
    this.loadingWidget,
    super.key,
  });

  /// Authorization URL from payment initialization
  final String authorizationUrl;

  /// Callback URL to detect payment completion
  final String callbackUrl;

  /// Called when payment is successful
  final void Function(String reference) onSuccess;

  /// Called when payment fails
  final void Function(String error) onError;

  /// Called when payment is cancelled
  final VoidCallback onCancelled;

  /// Optional custom AppBar for the checkout screen
  final PreferredSizeWidget? appBar;

  /// Whether to show an AppBar (ignored if [appBar] is provided)
  final bool showAppBar;

  /// Optional loading widget shown while the page is loading
  final Widget? loadingWidget;

  @override
  State<CredoPaymentWebView> createState() => _CredoPaymentWebViewState();
}

class _CredoPaymentWebViewState extends State<CredoPaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();
    // ignore: avoid_print
    print(
        'DEBUG: CredoPaymentWebView.initState for: ${widget.authorizationUrl}');
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            _checkUrl(url);
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            if (!_hasCompleted) {
              widget
                  .onError('Failed to load payment page: ${error.description}');
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authorizationUrl));
  }

  void _checkUrl(String url) {
    if (_hasCompleted) return;

    // Check if URL matches callback URL
    if (url.startsWith(widget.callbackUrl)) {
      _hasCompleted = true;

      try {
        final uri = Uri.parse(url);
        final reference = uri.queryParameters['reference'];
        final status = uri.queryParameters['status'];

        if (reference != null && status == 'successful') {
          widget.onSuccess(reference);
        } else if (status == 'cancelled') {
          widget.onCancelled();
        } else {
          widget.onError('Payment failed or was cancelled');
        }
      } catch (e) {
        widget.onError('Failed to parse payment result: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedAppBar = widget.appBar ??
        (widget.showAppBar
            ? AppBar(
                title: const Text('Complete Payment'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    if (!_hasCompleted) {
                      widget.onCancelled();
                    }
                  },
                ),
              )
            : null);

    final loadingOverlay =
        widget.loadingWidget ?? const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: resolvedAppBar,
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Positioned.fill(
              child: loadingOverlay,
            ),
        ],
      ),
    );
  }
}
