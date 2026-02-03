import 'package:credo_flutter_sdk/credo_flutter_sdk.dart';
import 'package:credo_flutter_sdk/src/client/credo_api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('throws validation error for invalid email', () async {
    final client = MockClient((request) async {
      return http.Response('{"status":200,"message":"ok","data":{}}', 200);
    });

    final apiClient = CredoApiClient(
      apiKey: 'pk_test',
      httpClient: client,
    );
    final service = PaymentService(apiClient);

    expect(
      () => service.initializePayment(
        const InitializePaymentRequest(
          email: 'invalid-email',
          amount: 1000,
        ),
      ),
      throwsA(isA<CredoValidationException>()),
    );
  });

  test('throws validation error for invalid callbackUrl', () async {
    final client = MockClient((request) async {
      return http.Response('{"status":200,"message":"ok","data":{}}', 200);
    });

    final apiClient = CredoApiClient(
      apiKey: 'pk_test',
      httpClient: client,
    );
    final service = PaymentService(apiClient);

    expect(
      () => service.initializePayment(
        const InitializePaymentRequest(
          email: 'test@example.com',
          amount: 1000,
          callbackUrl: 'not-a-url',
        ),
      ),
      throwsA(isA<CredoValidationException>()),
    );
  });
}
