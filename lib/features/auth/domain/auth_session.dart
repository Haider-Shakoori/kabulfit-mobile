class AuthSession {
  const AuthSession({required this.email});

  /// The mobile API deliberately omits database IDs and does not expose a UUID
  /// for the customer. The email is the only field needed for session UI.
  factory AuthSession.fromAccount(Map<String, dynamic> account) {
    final email = account['email'];
    if (email is! String || email.trim().isEmpty) {
      throw const FormatException(
        'Invalid account details returned by KabulFit.',
      );
    }
    return AuthSession(email: email.trim());
  }

  final String email;
}
