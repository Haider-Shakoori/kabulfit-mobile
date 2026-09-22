enum AppFlavor { dev, staging, production }

class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.analyticsEnabled,
    this.sentryDsn,
  });

  factory AppConfig.fromEnvironment(AppFlavor flavor) {
    const rawApiUrl = String.fromEnvironment('API_BASE_URL');
    const sentryDsn = String.fromEnvironment('SENTRY_DSN');
    const analyticsEnabled = bool.fromEnvironment('ANALYTICS_ENABLED');
    final fallback = flavor == AppFlavor.dev
        ? 'http://10.0.2.2:8000/api/v1'
        : '';
    final uri = Uri.tryParse(rawApiUrl.isEmpty ? fallback : rawApiUrl);

    if (uri == null || !uri.isAbsolute) {
      throw StateError('API_BASE_URL must be an absolute URL.');
    }
    if (flavor != AppFlavor.dev && uri.scheme != 'https') {
      throw StateError('Staging and production API_BASE_URL must use HTTPS.');
    }

    return AppConfig(
      flavor: flavor,
      apiBaseUrl: uri,
      analyticsEnabled: analyticsEnabled,
      sentryDsn: sentryDsn.isEmpty ? null : sentryDsn,
    );
  }

  final AppFlavor flavor;
  final Uri apiBaseUrl;
  final bool analyticsEnabled;
  final String? sentryDsn;
}
