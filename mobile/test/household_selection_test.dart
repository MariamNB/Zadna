import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zadna/core/api/api_client.dart';
import 'package:zadna/data/repositories/auth_repository.dart';

class _Adapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  bool rejectSelection = false;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<dynamic>? cancelFuture) async {
    requests.add(options);
    final payload = base64Url
        .encode(utf8.encode(jsonEncode({
          'sub': 'user',
          'household_id': 'personal',
        })))
        .replaceAll('=', '');
    final data = options.path.startsWith('/auth/')
        ? {
            'access_token': 'header.$payload.signature',
            'token_type': 'bearer',
            'expires_in': 900,
            'refresh_token': 'new-refresh'
          }
        : {'id': options.headers['X-Household-ID']};
    return ResponseBody.fromString(
        jsonEncode(data), rejectSelection ? 404 : 200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType]
        });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({
        'access_token': 'current-token',
        'refresh_token': 'current-refresh',
        'user_id': 'user',
        'household_id': 'personal',
      }));

  test('selection validates the new household and subsequent requests use it',
      () async {
    final adapter = _Adapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final client = ApiClient(dio: dio);
    final repository = AuthRepository(client);
    await repository.selectHousehold('shared');
    expect(adapter.requests.first.headers['X-Household-ID'], 'shared');
    expect(await client.getHouseholdId(), 'shared');
    await dio.get('/inventory-items');
    expect(adapter.requests.last.headers['X-Household-ID'], 'shared');
    await repository.refreshToken();
    expect(await client.getHouseholdId(), 'shared');
    expect(
        adapter.requests.last.headers.containsKey('X-Household-ID'), isFalse);
    dio.close();
  });

  test('a rejected switch does not change the active household', () async {
    final adapter = _Adapter()..rejectSelection = true;
    final dio = Dio()..httpClientAdapter = adapter;
    final client = ApiClient(dio: dio);
    await expectLater(AuthRepository(client).selectHousehold('uninvited'),
        throwsA(isA<DioException>()));
    expect(await client.getHouseholdId(), 'personal');
    dio.close();
  });

  test(
      'new login resets the active household instead of leaking a prior selection',
      () async {
    final adapter = _Adapter();
    final dio = Dio()..httpClientAdapter = adapter;
    final client = ApiClient(dio: dio);
    await client.setHouseholdId('shared');
    await AuthRepository(client)
        .login(email: 'user@example.com', password: 'password');
    expect(await client.getHouseholdId(), 'personal');
    dio.close();
  });
}
