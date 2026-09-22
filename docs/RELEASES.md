# Mobile Release Operations

## Local checks

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos
flutter test
```

## Android

Use `dev` for local emulators and `production` for signed store artifacts. Keystores
and passwords belong in the CI secret store. Never commit `key.properties`, `.jks`
or `.keystore` files.

## iOS

Development teams, provisioning profiles and distribution certificates are injected
on a trusted macOS release runner. CI compiles with `--no-codesign` to catch project
regressions without exposing signing material.

## Production gate

- Green quality, Android and iOS jobs on the exact release commit.
- HTTPS production API URL supplied at build time.
- Dependency and secret scans clean.
- Store signing performed from protected secrets.
- Release artifact tested against the production-candidate Laravel API.
