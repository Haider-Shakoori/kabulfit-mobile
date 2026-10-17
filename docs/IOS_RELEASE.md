# KabulFit iOS IPA release checklist

## Release scope

Batch 17 prepares the existing Flutter storefront, product catalog, customer accounts, cart/wishlist, shipping addresses, orders, measurements and tailoring for iOS delivery. Stripe payment activation and live payment testing are intentionally deferred. No Stripe publishable key is passed to the build, so online checkout remains disabled by design. This build should be treated as a **pre-payment pilot**, not a fully enabled commerce launch.

## Verified automated checks

Use the latest `Mobile CI` run for this branch. It checks Dart formatting, strict analysis, Flutter tests, Android development and release builds, and unsigned iOS compilation. The iOS job additionally uploads `KabulFit-UNSIGNED.ipa` as a packaging preflight **only**. An unsigned IPA cannot be installed on an ordinary iPhone.

## Staging-only IPA while Base44 remains live

Until the final domain cutover, the unsigned iOS CI preflight uses
`https://kabulfit.businessos.af/api/v1`, launches `main_staging.dart`, and
explicitly disables demo catalog fallback. This allows honest validation of
the original 130 active USD-priced products from Laravel rather than
`kabulfit.com`'s existing Base44 HTML responses.

**Release blocker:** archived product photo URLs on cPanel staging returned
HTTP 404 during the 2026-10-17 readiness check. Do not sign, distribute, or
claim a production-ready storefront until these assets are publicly served
and full EN/FA/PS catalog/detail/cart QA passes. The original website's
domain remains unchanged until all web and Flutter work is complete.

## Requirements for an installable IPA

An Apple Developer Program membership, a distribution certificate exported as a password-protected P12, a matching provisioning profile, the Apple Team ID, and an App ID matching `af.kabulfit.mobile` are required. For Ad Hoc distribution, registered test-device UDIDs must be included in the Ad Hoc profile. App Store distribution instead requires the appropriate App Store distribution profile and App Store Connect setup.

Configure the GitHub `ios-release` protected environment with these encrypted secrets:

- `IOS_DISTRIBUTION_CERT_P12_BASE64`: base64 of the P12 bytes (single line)
- `IOS_DISTRIBUTION_CERT_PASSWORD`: P12 export password
- `IOS_PROVISIONING_PROFILE_BASE64`: base64 of the `.mobileprovision` file (single line)
- `IOS_TEAM_ID`: Apple Developer Team ID
- `IOS_BUNDLE_ID`: `af.kabulfit.mobile`
- `IOS_KEYCHAIN_PASSWORD`: a strong temporary CI keychain password

Do not commit or paste signing credentials into source code or chat. Protect the GitHub environment with deployment branch restrictions and required approvals as appropriate.

The signed workflow `.github/workflows/ios-ipa-release.yml` must be present on the default branch before manual dispatch is available in the GitHub Actions interface. First merge the reviewed stacked feature PRs and release workflow into `main` once all checks pass. Then use **Actions → KabulFit iOS Signed IPA → Run workflow**, select **ad-hoc** for registered-device installs or **app-store** for TestFlight/App Store distribution, and keep the production API URL as `https://kabulfit.com/api/v1` only if the production mobile APIs are deployed and verified.

A successful run uploads `KabulFit.ipa` and `SHA256SUMS.txt`. Confirm app bundle ID, release version, entitlements, signing certificate, provisioning profile, launch and navigation on at least one real iPhone before delivery.

## Non-payment acceptance

- English, Dari and Pashto UI and right-to-left navigation checked on a real phone
- Production catalog and product details load with verified images, pricing and inventory
- Authentication and guest browsing, account access and logout verified
- Cart quantities and wishlist sync as intended; prevent misleading live checkout promises while Stripe is disabled
- Address and order history pages handle loading, errors and empty states
- Tailoring customization and measurement profiles work with expected units and validations
- API availability, network failures, app relaunch and language persistence tested
- No secrets, debug URLs or mock data included in the release build

## Intentional deferrals

Stripe PaymentSheet live/test payment flows, webhook reconciliation, and paid-order acceptance remain out of scope for this IPA milestone and must be completed before enabling real customer payments. No payment success should ever be inferred from PaymentSheet dismissal alone.
