import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:math' as math;
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
  VirtualAccount? _virtualAccount;
  String? _initializedReference;

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
      _virtualAccount = null;
      _initializedReference = null;
    });

    try {
      final request = InitializePaymentRequest(
        email: _emailController.text,
        amount: int.parse(_amountController.text),
        currency: Currency.ngn,
        // [NOTE]: Omit callbackUrl to use Credo's default receipt page
        // callbackUrl: 'https://your-app.com/callback',
        initializeAccount: true, // Enable virtual account for transfer test
      );

      final response = await _credo.initializePayment(request);

      // ignore: avoid_print
      print('DEBUG: response.isSuccessful: ${response.isSuccessful}');
      // ignore: avoid_print
      print('DEBUG: response.status: ${response.status}');
      // ignore: avoid_print
      print('DEBUG: response.authorizationUrl: ${response.authorizationUrl}');

      if (response.isSuccessful) {
        setState(() {
          _virtualAccount = response.account;
          _initializedReference = response.reference;
        });

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
                    'Click "Verify Payment" after completing the flow.';
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
                    _onPaymentComplete(reference);
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
        } else if (response.account != null) {
          setState(() {
            _result = 'Virtual Account Generated Successfully!\n'
                'Bank: ${response.account!.bankName}\n'
                'Account: ${response.account!.accountNumber}\n'
                'Name: ${response.account!.accountName}\n\n'
                'Use the "Simulate Transfer" button below to test.';
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

  Future<void> _simulateBankTransfer() async {
    if (_virtualAccount == null || _initializedReference == null) return;

    setState(() => _isLoading = true);

    try {
      final koboAmount = int.parse(_amountController.text);
      final nairaAmount = koboAmount / 100.0;

      // Use the exact amount required by the account (includes fees) if available
      final totalAmount = _virtualAccount?.amount ?? nairaAmount;

      String generateUUID() {
        final randomValues =
            List<int>.generate(16, (i) => math.Random().nextInt(256));
        randomValues[6] = (randomValues[6] & 0x0f) | 0x40;
        randomValues[8] = (randomValues[8] & 0x3f) | 0x80;
        String hex(int value) => value.toRadixString(16).padLeft(2, '0');
        return '${hex(randomValues[0])}${hex(randomValues[1])}${hex(randomValues[2])}${hex(randomValues[3])}-'
            '${hex(randomValues[4])}${hex(randomValues[5])}-'
            '${hex(randomValues[6])}${hex(randomValues[7])}-'
            '${hex(randomValues[8])}${hex(randomValues[9])}-'
            '${hex(randomValues[10])}${hex(randomValues[11])}${hex(randomValues[12])}'
            '${hex(randomValues[13])}${hex(randomValues[14])}${hex(randomValues[15])}';
      }

      final sessionId = generateUUID();
      final settlementId = generateUUID();
      final now = DateTime.now().toUtc();
      // Format: YYYY-MM-DDTHH:mm:ssZ (image docs shows this format)
      final dateStr = '${now.toIso8601String().split('.').first}Z';

      // Most simulations expect the feeAmount to be the difference
      final feeAmount = totalAmount - nairaAmount;

      final payload = {
        "sessionId": sessionId,
        "accountNumber": _virtualAccount!.accountNumber,
        "tranRemarks": "SDK Simulation: $_initializedReference",
        "transactionAmount": totalAmount,
        "settledAmount": nairaAmount,
        "feeAmount": feeAmount > 0 ? feeAmount : 0,
        "vatAmount": 0,
        "currency": "NGN",
        "settlementId": settlementId, // Unique as per docs
        "sourceAccountNumber": "1017432705",
        "sourceAccountName": "M B C COMPUTER AND ACCESSORIES",
        "sourceBankName": "MONIEPOINT MICROFINANCE BANK",
        "channelId": "1",
        "tranDateTime": dateStr,
      };

      // ignore: avoid_print
      print('DEBUG: Sending Simulation Payload: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse(
            'https://api.credodemo.com/transaction/providus/settlement/notification'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Auth-Signature':
              'be09bee831cf262226b426e39bd1092af84dc63076d4174fac78a2261f9a3d6e59744983b8326b69cdf2963fe314dfc89635cfa37a40596508dd6eaa0b9402c7',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _onPaymentComplete(_initializedReference!);
      } else {
        setState(() {
          _result =
              'Simulation failed (${response.statusCode}): ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: Simulation Exception: $e');
      setState(() {
        _result = 'Simulation Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyPayment(String reference) async {
    setState(() => _isLoading = true);
    try {
      // [TESTING ONLY]: We use verifyPaymentDirectly for the sandbox example.
      // In production, use credo.verifyPaymentViaBackend(yourBackendUrl, reference).
      final response = await _credo.verifyPaymentDirectly(reference);

      setState(() {
        _result = '''
Payment Status: ${response.status?.text ?? 'Unknown'}
-------------------------
Reference: ${response.transRef}
Amount: ${response.transAmount}
Date: ${response.transactionDate}

[PRO TIP]: In production, always use 
verifyPaymentViaBackend() to keep 
your Secret Key off the device.
        ''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _result = 'Verification failed: $e\n\n'
            'Note: Direct verification with a Public Key \n'
            'is often restricted. Use a Secret Key \n'
            'on your backend for production.';
        _isLoading = false;
      });
    }
  }

  void _onPaymentComplete(String reference) {
    setState(() {
      _result = '''
Payment Initialized/Simulated!
-------------------------
Reference: $reference
        
Click "Manual Verify" to check status.
(Note: Sandbox might return 401 if 
Public Key is restricted for Verify)
      ''';
      _isLoading = false;
    });
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
            if (_virtualAccount != null)
              ElevatedButton(
                onPressed: _isLoading ? null : _simulateBankTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Simulate Bank Transfer'),
              ),
            const SizedBox(height: 16),
            if (_initializedReference != null)
              OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () => _verifyPayment(_initializedReference!),
                child: const Text('Manual Verify Payment Status'),
              ),
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
