# KabulFit Mobile

Production Flutter client for the KabulFit Laravel commerce platform.

## Requirements

- Flutter stable (see `.github/workflows/ci.yml` for the CI channel)
- Dart 3.11+
- Android Studio / Xcode for platform builds

## Environments

The app has `dev`, `staging`, and `production` Android flavors and matching Dart entrypoints.
Runtime configuration is compile-time only; no secrets are committed.

```bash
flutter pub get
flutter run --flavor dev -t lib/main_dev.dart \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

Production builds require HTTPS:

```bash
flutter build appbundle --flavor production -t lib/main_production.dart \
  --dart-define=API_BASE_URL=https://kabulfit.com/api/v1
```

See `docs/ARCHITECTURE.md` and `docs/RELEASES.md` before extending or releasing the app.
