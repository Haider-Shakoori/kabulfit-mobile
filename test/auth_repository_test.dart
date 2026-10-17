import 'package:flutter_test/flutter_test.dart';
import 'package:kabulfit_mobile/core/device/device_identity.dart';
import 'package:kabulfit_mobile/core/network/api_client.dart';
import 'package:kabulfit_mobile/core/security/token_store.dart';
import 'package:kabulfit_mobile/features/auth/data/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockDeviceIdentity extends Mock implements DeviceIdentity {}

class _MemoryTokenStore implements TokenStore {
  String? token;

  @override
  Future<void> clear() async => token = null;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String value) async => token = value;
}

void main() {
  late _MockApiClient client;
  late _MockDeviceIdentity device;
  late _MemoryTokenStore tokens;
  late AuthRepository repository;

  setUp(() {
    client = _MockApiClient();
    device = _MockDeviceIdentity();
    tokens = _MemoryTokenStore();
    repository = AuthRepository(
      client: client,
      tokenStore: tokens,
      deviceIdentity: device,
    );
    when(() => device.payload()).thenAnswer(
      (_) async => <String, String>{
        'device_uuid': 'test-device',
        'device_name': 'Test iPhone',
        'platform': 'ios',
        'app_version': '1.0.0',
      },
    );
  });

  test('login accepts the real API account shape without uuid', () async {
    when(() => client.post('/auth/login', data: any(named: 'data')))
        .thenAnswer(
          (_) async => <String, dynamic>{
            'data': {
              'token': 'secure-login-token',
              'user': {
                'name': 'Mobile Customer',
                'email': 'customer@example.com',
                'email_verified': false,
              },
            },
          },
        );

    final session = await repository.signIn(
      email: 'customer@example.com',
      password: 'Secure1234',
    );

    expect(session.email, 'customer@example.com');
    expect(await tokens.read(), 'secure-login-token');
  });

  test('signup accepts the real API account shape without uuid', () async {
    when(() => client.post('/auth/register', data: any(named: 'data')))
        .thenAnswer(
          (_) async => <String, dynamic>{
            'data': {
              'token': 'secure-registration-token',
              'user': {
                'name': 'New Customer',
                'email': 'new@example.com',
                'preferred_locale': 'en',
              },
            },
          },
        );

    final session = await repository.register(
      name: 'New Customer',
      email: 'new@example.com',
      password: 'Secure1234',
      passwordConfirmation: 'Secure1234',
    );

    expect(session.email, 'new@example.com');
    expect(await tokens.read(), 'secure-registration-token');
  });

  test('restores a session when /account contains no uuid', () async {
    await tokens.write('existing-token');
    when(() => client.get('/account')).thenAnswer(
      (_) async => <String, dynamic>{
        'data': {
          'name': 'Existing Customer',
          'email': 'existing@example.com',
        },
      },
    );

    final session = await repository.restore();

    expect(session?.email, 'existing@example.com');
    expect(await tokens.read(), 'existing-token');
  });

  test('rejects missing account email before storing token', () async {
    when(() => client.post('/auth/login', data: any(named: 'data')))
        .thenAnswer(
          (_) async => <String, dynamic>{
            'data': {
              'token': 'should-not-be-saved',
              'user': {'email': null},
            },
          },
        );

    await expectLater(
      repository.signIn(email: 'test@example.com', password: 'Secure1234'),
      throwsA(isA<FormatException>()),
    );
    expect(await tokens.read(), isNull);
  });

  test('rejects missing token before storing a session', () async {
    when(() => client.post('/auth/register', data: any(named: 'data')))
        .thenAnswer(
          (_) async => <String, dynamic>{
            'data': {
              'token': null,
              'user': {'email': 'new@example.com'},
            },
          },
        );

    await expectLater(
      repository.register(
        name: 'New Customer',
        email: 'new@example.com',
        password: 'Secure1234',
        passwordConfirmation: 'Secure1234',
      ),
      throwsA(isA<FormatException>()),
    );
    expect(await tokens.read(), isNull);
  });
}
