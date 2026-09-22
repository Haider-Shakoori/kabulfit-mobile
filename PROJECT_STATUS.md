# KabulFit Mobile Project Status

Last updated: 2026-09-22

## Batch 12 — Flutter mobile foundation

Status: implementation in progress on `feat/batch-12-flutter-foundation`.

Implemented:

- Separate Flutter Android/iOS repository.
- Dev, staging and production entrypoints and Android product flavors.
- HTTPS-enforced staging/production configuration through `--dart-define`.
- Riverpod dependency/state foundation and GoRouter navigation.
- Dio API client with locale/app-version headers, bearer authentication and
  bounded timeouts.
- Keychain/Android secure token storage with 401/logout revocation.
- English, Dari and Pashto localization with RTL support.
- KabulFit green, burgundy, gold and warm-neutral Material 3 design tokens.
- Authentication restoration/login shell and guest home shell.
- Consent-aware analytics/crash-reporting extension boundary.
- Android/iOS build foundations without committed signing credentials.
- Quality, test, Android and unsigned iOS CI gates.

Next: Batch 13 — Flutter shopping experience after Batch 12 PR and post-merge CI.
