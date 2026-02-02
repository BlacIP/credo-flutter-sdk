import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Future<void> _initializePayment() async {
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

      if (response.isSuccessful) {
        if (response.authorizationUrl != null) {
          // [BEST PRACTICE]: Save the response.authorizationUrl and response.reference
          // to your local storage or backend. If the customer returns to your app
          // before completing the payment, reuse this URL instead of initializing
          // a new transaction to avoid duplicates.

          if (!mounted) return;

          // ignore: avoid_print
          print('DEBUG: Navigating to payment page');

          if (const bool.fromEnvironment('dart.library.js_util') ||
              identical(0, 0.0)) {
            // ignore: avoid_print
            print('DEBUG: Web platform detected, using url_launcher');
            final uri = Uri.parse(response.authorizationUrl!);
            // We use launchUrl without canLaunchUrl for web as it's more reliable
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              setState(() {
                _result = 'Payment page opened in new tab.\n'
                    'Complete payment, then your app should verify on the backend.';
                _isLoading = false;
              });
            } catch (e) {
              // ignore: avoid_print
              print('DEBUG: launchUrl failed: $e');
              setState(() {
                _result = 'Could not launch payment URL: $e';
                _isLoading = false;
              });
            }
          } else {
            // ignore: avoid_print
            print('DEBUG: Mobile platform detected, using WebView');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CredoPaymentWebView(
                  authorizationUrl: response.authorizationUrl!,
                  callbackUrl: 'https://your-app.com/callback',
                  onSuccess: (reference) {
                    Navigator.pop(context);
                    setState(() {
                      _result = 'Payment completed!\n'
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
                ),
              ),
            );
          }
        } else {
          setState(() {
            _result = 'Initialization succeeded but no authorizationUrl '
                'was returned.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _result = 'Failed to initialize payment.\n'
              'Status: ${response.status}\n'
              'Message: ${response.message}\n'
              'URL: ${response.authorizationUrl ?? "MISSING"}';
          _isLoading = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: Caught exception in _initializePayment: $e');
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
            ElevatedButton(
              onPressed: _isLoading ? null : _initializePayment,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Initialize Payment'),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),

            // Result Display
            if (_result != null)
              Card(
                color: _result!.contains('Successful')
                    ? Colors.green.shade50
                    : _result!.contains('failed') || _result!.contains('Error')
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
