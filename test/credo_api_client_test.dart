import 'dart:convert';

import 'package:credo_flutter_sdk/src/client/credo_api_client.dart';
import 'package:credo_flutter_sdk/src/exceptions/credo_exception.dart';
import 'package:credo_flutter_sdk/src/models/enums/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('returns parsed json for successful response', () async {
    final client = MockClient((request) async {
      return http.Response(
        jsonEncode({'status': 200, 'message': 'ok', 'data': {}}),
        200,
      );
    });

    final apiClient = CredoApiClient(
      apiKey: 'pk_test',
      environment: CredoEnvironment.sandbox,
      httpClient: client,
    );

    final response = await apiClient.get('/transaction/test');
    expect(response['status'], 200);
  });

  test('throws CredoApiException for non-json error responses', () async {
    final client = MockClient((request) async {
      return http.Response('<html>Server error</html>', 500);
    });

    final apiClient = CredoApiClient(
      apiKey: 'pk_test',
      environment: CredoEnvironment.sandbox,
      httpClient: client,
    );

    expect(
      () => apiClient.get('/transaction/test'),
      throwsA(isA<CredoApiException>()),
    );
  });
}
