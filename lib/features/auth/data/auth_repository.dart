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
      final nested = response['data'];
      final account = nested is Map<String, dynamic> ? nested : response;
      return AuthSession.fromAccount(account);
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
    return _persistSession(response);
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
    return _persistSession(response);
  }

  /// Validate the whole authentication payload before storing credentials.
  /// The API's AccountResource contains an email, not a customer UUID.
  Future<AuthSession> _persistSession(Map<String, dynamic> response) async {
    final nested = response['data'];
    final data = nested is Map<String, dynamic> ? nested : response;
    final token = data['token'];
    final account = data['user'];

    if (token is! String ||
        token.isEmpty ||
        account is! Map<String, dynamic>) {
      throw const FormatException('Invalid authentication response from KabulFit.');
    }

    final session = AuthSession.fromAccount(account);
    await _tokenStore.write(token);
    return session;
  }

  Future<void> signOut() async {
    try {
      await _client.post('/auth/logout');
    } finally {
      await _tokenStore.clear();
    }
  }
}
