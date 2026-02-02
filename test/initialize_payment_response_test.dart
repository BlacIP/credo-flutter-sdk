import 'package:flutter_test/flutter_test.dart';
import 'package:credo_flutter_sdk/credo_flutter_sdk.dart';

void main() {
  test('parses execTime, bill info, and virtual account fields', () {
    final json = {
      'status': 200,
      'message': 'Successfully processed',
      'data': {
        'authorizationUrl': 'https://pay.credodemo.com/abc',
        'reference': 'ref_123',
        'credoReference': 'credo_456',
        'crn': '0000298483',
        'execTime': 4.64,
        'billNumber': 'BILL-1',
        'billInformation': {
          'amountDue': 1500.5,
          'payerName': 'Jane Doe',
          'agencyName': 'LIRS',
        },
        'account': {
          'accountNumber': '0123456789',
          'bankName': 'GTB',
          'accountName': 'Jane Doe',
          'amount': 1500.5,
          'expiryDate': '2025-02-06T08:19:39.766Z',
        },
      },
      'error': [],
    };

    final response = InitializePaymentResponse.fromJson(json);
    expect(response.isSuccessful, true);
    expect(response.execTime, 4.64);
    expect(response.billNumber, 'BILL-1');
    expect(response.billInformation?.payerName, 'Jane Doe');
    expect(response.billInformation?.amountDue, 1500.5);
    expect(response.account?.expiryDateTime, isNotNull);
  });
}
