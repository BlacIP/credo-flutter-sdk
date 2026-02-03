import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:credo_flutter_sdk/credo_flutter_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Credo Payment SDK Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PaymentExamplePage(),
    );
  }
}

class PaymentExamplePage extends StatefulWidget {
  const PaymentExamplePage({super.key});

  @override
  State<PaymentExamplePage> createState() => _PaymentExamplePageState();
}

class _PaymentExamplePageState extends State<PaymentExamplePage> {
  final _emailController = TextEditingController(text: 'test@example.com');
  final _amountController = TextEditingController(text: '10000');

  late final CredoPaymentGateway _credo;
  bool _isLoading = false;
  String? _result;

  @override
  void initState() {
    super.initState();
    // Initialize SDK with your public API key
    _credo = CredoPaymentGateway(
      apiKey:
          '0PUB0123v80AzP7kLEP2EQUGjG82Fz17', // Replace with your public API key
      environment: CredoEnvironment.sandbox,
    );
  }

  Future<void> _startCheckout({required bool useLaunchHelper}) async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final request = InitializePaymentRequest(
        email: _emailController.text,
        amount: int.parse(_amountController.text),
        currency: Currency.ngn,
        callbackUrl: 'https://your-app.com/callback',
      );

      final response = await _credo.initializePayment(request);

      // ignore: avoid_print
      print('DEBUG: response.isSuccessful: ${response.isSuccessful}');
      // ignore: avoid_print
      print('DEBUG: response.status: ${response.status}');
      // ignore: avoid_print
      print('DEBUG: response.authorizationUrl: ${response.authorizationUrl}');

      if (!response.isSuccessful) {
        setState(() {
          _result = 'Failed to initialize payment.\n'
              'Status: ${response.status}\n'
              'Message: ${response.message}\n'
              'URL: ${response.authorizationUrl ?? "MISSING"}';
          _isLoading = false;
        });
        return;
      }

      if (response.authorizationUrl == null) {
        setState(() {
          _result = 'Initialization succeeded but no authorizationUrl '
              'was returned.';
          _isLoading = false;
        });
        return;
      }

      if (!mounted) return;

      // ignore: avoid_print
      print('DEBUG: Navigating to payment page');

      if (useLaunchHelper) {
        final result = await CredoCheckout.launch(
          context: context,
          authorizationUrl: response.authorizationUrl!,
          callbackUrl: 'https://your-app.com/callback',
        );

        if (!mounted) return;

        setState(() {
          if (result.isSuccessful) {
            _result = 'Payment completed (launch helper)!\n'
                'Reference: ${result.reference}\n\n'
                'Send this reference to your backend for verification.';
          } else if (result.isPending) {
            _result = result.message ??
                'Checkout opened externally. Verify on backend after return.';
          } else if (result.status == CredoCheckoutStatus.cancelled) {
            _result = 'Payment cancelled';
          } else {
            _result = 'Payment failed: ${result.error ?? "Unknown error"}';
          }
          _isLoading = false;
        });
        return;
      }

      final isMobilePlatform = !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS);
      if (!isMobilePlatform) {
        setState(() {
          _result =
              'Custom WebView is available on mobile only. Use the launch helper '
              'for web/desktop.';
          _isLoading = false;
        });
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CredoPaymentWebView(
            authorizationUrl: response.authorizationUrl!,
            callbackUrl: 'https://your-app.com/callback',
            onSuccess: (reference) {
              Navigator.pop(context);
              setState(() {
                _result = 'Payment completed (custom WebView)!\n'
                    'Reference: $reference\n\n'
                    'Send this reference to your backend for verification.';
                _isLoading = false;
              });
            },
            onError: (error) {
              Navigator.pop(context);
              setState(() {
                _result = 'Payment failed: $error';
                _isLoading = false;
              });
            },
            onCancelled: () {
              Navigator.pop(context);
              setState(() {
                _result = 'Payment cancelled';
                _isLoading = false;
              });
            },
            showAppBar: false,
          ),
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: Caught exception in _startCheckout: $e');
      setState(() {
        _result = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Credo Payment SDK Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test Cards Info
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Cards (Sandbox)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Card 1: 4012000033330026'),
                    const Text('Expiry: 09/27, CVV: 556'),
                    const SizedBox(height: 4),
                    const Text('Card 2: 5555555555554444'),
                    const Text('Expiry: 09/27, CVV: 556'),
                    const Text('(Do not fill 3DS form)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Payment Form
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount (in kobo)',
                border: OutlineInputBorder(),
                helperText: '10000 = ₦100.00',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Text(
              'Choose Checkout Mode',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _startCheckout(useLaunchHelper: true),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Quick Launch'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _startCheckout(useLaunchHelper: false),
                    child: const Text('Custom WebView'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Result Display
            if (_result != null)
              Card(
                color: _result!.toLowerCase().contains('completed') ||
                        _result!.toLowerCase().contains('success')
                    ? Colors.green.shade50
                    : _result!.toLowerCase().contains('failed') ||
                            _result!.toLowerCase().contains('error')
                        ? Colors.red.shade50
                        : Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _result!,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
