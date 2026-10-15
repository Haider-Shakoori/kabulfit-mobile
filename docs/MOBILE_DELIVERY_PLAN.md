# KabulFit Mobile: Delivery Plan

## Confirmed baseline (15 October 2026)
- Existing Flutter app uses Riverpod, GoRouter, Dio and secure storage.
- Laravel is the source of truth for authentication, catalog, stock, prices, checkout, payment state and measurements.
- CI runs formatting, analysis, tests, Android builds and an **unsigned** iOS compile.
- An unsigned iOS compile is not an installable IPA.

## Implementation batches
1. **Catalog and design parity:** native home, categories, product lists, search/filter/sort, product details, image galleries, web design tokens, loading/error/empty states.
2. **Commerce:** login/register, cart, wishlist, address book, shipping, coupons, checkout, order details and server-side payment status. Reuse Laravel APIs; never calculate the authoritative order total in Flutter.
3. **Tailoring:** measurement profiles, measurement validation, tailoring personalization, tailor/order progress, account lifecycle.
4. **Localization and polish:** English/Dari/Pashto, RTL navigation and layouts, accessibility, deep links, offline-friendly caching, privacy controls.
5. **Release and acceptance:** Android release build, iOS signing, end-to-end test against staging/production-candidate API, device QA and IPA distribution.

## iOS delivery
The manual `iOS IPA Release` GitHub Actions workflow builds a signed IPA on a macOS runner if the repository's `ios-release` environment has these six secrets:
- `IOS_DISTRIBUTION_CERT_P12_BASE64`
- `IOS_DISTRIBUTION_CERT_PASSWORD`
- `IOS_PROVISIONING_PROFILE_BASE64`
- `IOS_TEAM_ID`
- `IOS_BUNDLE_ID`
- `IOS_KEYCHAIN_PASSWORD`

The provisioning profile, certificate, bundle ID and selected distribution method must agree. Ad Hoc profiles must include registered test device UDIDs. App Store distribution IPA is for TestFlight/App Store upload, not direct sideloading. Never commit certificates, provisioning profiles or secrets.

When signing is ready, run **Actions → iOS IPA Release → Run workflow** and retrieve the `kabulfit-ios-ipa` artifact. Verify the IPA on a real iPhone before release.

## Release gates
- CI green on intended commit and documented API coverage.
- Production API URL uses HTTPS and is reachable.
- Auth, cart, stock, order totals and payment events checked against Laravel.
- Three locales and RTL validated on device.
- Signed IPA built and tested on the intended install/distribution path.

**Status:** Release workflow is committed on a feature branch, not yet executed; signing configuration and the commerce/mobile delivery batches are pending.
