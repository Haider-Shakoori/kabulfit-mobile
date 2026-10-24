import '../../../core/device/device_identity.dart';
import '../../../core/network/api_client.dart';
import '../../../core/security/token_store.dart';
import '../domain/auth_session.dart';

class AuthRepository {
  const AuthRepository({
    required ApiClient client,
    required TokenStore tokenStore,
    required DeviceIdentity deviceIdentity,
  }) : _client = client,
       _tokenStore = tokenStore,
       _deviceIdentity = deviceIdentity;

  final ApiClient _client;
  final TokenStore _tokenStore;
  final DeviceIdentity _deviceIdentity;

  Future<AuthSession?> restore() async {
    if (await _tokenStore.read() == null) return null;
    try {
      final response = await _client.get('/account');
      final data = response['data'] as Map<String, dynamic>? ?? response;
      return AuthSession(
        userUuid: data['uuid'] as String,
        email: data['email'] as String,
      );
    } catch (_) {
      await _tokenStore.clear();
      return null;
    }
  }

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final device = await _deviceIdentity.payload();
    final response = await _client.post(
      '/auth/login',
      data: {'email': email, 'password': password, ...device},
    );
    final data = response['data'] as Map<String, dynamic>? ?? response;
    await _tokenStore.write(data['token'] as String);
    final user = data['user'] as Map<String, dynamic>;
    return AuthSession(
      userUuid: user['uuid'] as String,
      email: user['email'] as String,
    );
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    final device = await _deviceIdentity.payload();
    final response = await _client.post(
      '/auth/register',
      data: {
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        ...device,
      },
    );
    final data = response['data'] as Map<String, dynamic>? ?? response;
    await _tokenStore.write(data['token'] as String);
    final user = data['user'] as Map<String, dynamic>;
    return AuthSession(
      userUuid: user['uuid'] as String,
      email: user['email'] as String,
    );
  }

  Future<void> signOut() async {
    try {
      await _client.post('/auth/logout');
    } finally {
      await _tokenStore.clear();
    }
  }
}
