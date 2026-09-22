# KabulFit Mobile Architecture

## Boundaries

Laravel is authoritative for identity, catalog, prices, stock, cart, measurements,
tailoring, checkout, payments, orders, roles and audit history. Flutter renders
server state and submits intent; it never marks payments successful or mutates
inventory independently.

## Structure

- `lib/app`: application composition and declarative routing.
- `lib/core`: environment, API, secure storage, localization, theme and preferences.
- `lib/features`: vertical feature slices with `data`, `domain`, `application` and
  `presentation` boundaries where needed.

Riverpod owns dependency injection and state. GoRouter owns navigation. Dio is the
single HTTP boundary. The bearer token is stored only in Keychain/Android secure
storage and is removed on logout or HTTP 401.

## Configuration

`API_BASE_URL`, `SENTRY_DSN`, and `ANALYTICS_ENABLED` are passed using
`--dart-define`. Staging and production reject non-HTTPS or absent API URLs.
Secrets, signing assets, Stripe secret keys and production credentials must never
be committed.

## Localization

English (`en`), Dari (`fa`) and Pashto (`ps`) are supported. Flutter resolves Dari
and Pashto to RTL automatically. New user-facing copy must be provided in all three
languages and covered by localization tests.

## Privacy and diagnostics

Analytics and remote error reporting are disabled until consent is resolved.
The bootstrap error hook logs locally only. A concrete analytics/crash provider may
be attached later behind the preferences consent boundary.

## Batch ownership

Batch 12 provides only the foundation and authentication shell. Catalog, commerce,
tailoring, Stripe and notifications are delivered in Batches 13–14 against the
existing versioned Laravel API.
