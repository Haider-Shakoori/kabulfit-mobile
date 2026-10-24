# KabulFit luxury fashion Flutter showcase — implementation status

Reference: approved 12-panel **KabulFit Luxury Fashion App Showcase.png** from the user's ChatGPT Library.

This design branch is based on `feat/batch-18-opt-in-demo-catalog` and connects to the **staging-only Laravel API** at `https://kabulfit.businessos.af/api/v1`. The original `kabulfit.com` continues to run Base44. Keep USD-only original backend prices, original product inventory and size choices, live backend categories and product images. Do not enable demo products for acceptance testing.

## Design coverage

| Reference panel | Implementation | Remaining acceptance |
| --- | --- | --- |
| 1. Splash / onboarding | Three-slide first-install introduction with real product photography, localized labels, stored completion | Confirm imagery/cropping and layout on actual iPhone |
| 2. Home | Branded light storefront, search navigation, editorial catalog hero, backend category photo avatars, featured products, five tabs | Screenshot/layout comparison, localized long-copy and image loading |
| 3. Shop / category | Responsive product photo cards, search, real USD pricing, backend category filter, five tabs | Visual polish and device RTL QA |
| 4. Product detail | Swipeable image gallery with linked selectable thumbnails, size chips, tailoring section, stock-safe cart/wishlist | Compare on device; verify original sizes and variants |
| 5. Measurement guide | Live-catalog hero, original step-by-step tips, and drawn measurement-marker mannequin | Check accessibility, garment-specific directions; no fabricated tutorial videos |
| 6. Side menu | Branded navigation drawer, real destinations, language options | Match drawer spacing and typography on phone |
| 7. Cart | Redesigned cart rows with real photos matched from live catalog, USD totals and safe quantities/removals | Verify small-phone layout and locales; image fallback if product no longer exists |
| 8. Checkout | Three-stage address, shipping-method and review interface, USD subtotal, preserving guarded Stripe PaymentSheet flow | End-to-end payment acceptance unavailable until Stripe keys and device QA |
| 9. Account | Branded customer account header with live email, all real destinations | Real-device avatar and email overflow QA |
| 10. Orders | Luxury order-history cards showing actual order/payment status, with real backend tracking retained | Refine status grouping and compare on real iPhone |
| 11. Wishlist | Live product photos/prices matched from catalog, choose-options link to accurate sizes, wishlist removal via backend | Test long product names, empty and sold-out states |
| 12. Measurement profile | Real profile CRUD with expandable visual measurement summary, illustrated figure and API-supplied numbers | Verify real-device RTL and varied measurement sets; never invent body measurements |

## Verification before merge

- GitHub Mobile CI format, strict analyze, Flutter tests, Android builds and unsigned iOS preflight all pass.
- Compare all 12 screens against original reference on physical iPhone, including small screens and landscape/RTL where applicable.
- English, Dari and Pashto text, navigation and buttons validated.
- All categories/products/photos/prices, USD-only, original sizes, stock, auth, cart and orders tested against staging API.
- No real charges and no domain cutover before final approval.
- An unsigned IPA is a packaging test only, **not a normally installable iOS distribution**. Signed IPA requires Apple provisioning.

## Development-only verification

The redesign is committed as draft PR #14. Verify it with the **current branch HEAD** and an uncancelled Mobile CI workflow; success from prior branches does not validate the new screens. The iOS artifact is unsigned and is not an ordinary installable IPA. Compare all 12 panels on a device before visual sign-off.

## CI verification note

The order-history redesign was added on this branch and formatted with the Flutter project's CI toolchain. Release acceptance requires a fresh CI run on the final branch commit; preceding runs may have been cancelled as the branch was updated. The original domain and `main` remain unchanged.

## Design completion checkpoint (implementation, not pixel-perfect certification)

- The six previously partial screen areas now have implemented UI elements: product thumbnail rail, illustrated fitting guide, photograph-based cart and wishlist cards, three-stage checkout, and profile-value illustration.
- Catalog images and prices are taken from the live USD Laravel API, never from invented local demo product records. Cart/wishlist data does not include photographs; the UI matches its returned localized product slug against the already-loaded catalog and falls back gracefully if missing.
- Wishlist calls the existing authenticated DELETE route; shoppers choose size/variant on the product page rather than bypassing inventory validation.
- Only the approved original Base44-inspired photography is displayed. The illustrative tailor figure is static, not a depiction of a customer's body.
- This is **not yet pixel-perfect or production-approved** without side-by-side iPhone screenshots, long-text/RTL QA, actual size and inventory scenarios, and payment acceptance. The reference mockup's AFN pricing is intentionally **not** copied; the approved real app currency remains USD.

## Original KabulFit website parity fixes — signup, guide, branding

- `/register` provides first-class customer signup using the already-existing Laravel `/api/v1/{locale}/auth/register` endpoint and real mobile device payload. Name, email, optional phone, password confirmation and backend validation are retained.
- Sign-in and registration can navigate back to the public measurements form, restoring a locally saved measurement draft rather than losing the entered values.
- The Measurements navigation tab now opens `/measurement-guide` publicly. `/measurements` remains login-protected for private persisted profiles; guest users can access the guide and register or sign in to save.
- The public guide mirrors the original Laravel `resources/views/content/pages/measurement-guide.blade.php`: **11 male and 17 female measurement steps**, exact translated labels, 28 original image URLs, and the original English/Dari/Pashto tutorial-video links from `database/data/base44_measurement_guide_videos.json`. All **28 original photos returned HTTP 200** during staging checks.
- The measurements entry form displays real public Laravel measurement definitions for each garment type and converts displayed inch values into authoritative centimeter values before the server save.
- Both exact original KabulFit header/white logo PNG blobs (verified identical Git object SHA to the Laravel original) are bundled under `assets/brand/` and shown in app headers, onboarding, login and registration. Logos no longer depend on staging image availability.
- Android and iOS builds and regression tests must pass on the **final commit**, not an earlier branch SHA. No original production domain changes or automatic PR merge.

**Outstanding source-of-truth acceptance:** the original web guide additionally shows body-type/weight planning inputs that the currently published mobile measurement-profile API does not persist; do not imply these have been synchronized. Physical iPhone and RTL screenshot comparison and real authenticated signup-to-profile QA remain necessary.

- Guest measurement drafts are stored in platform secure storage (iOS Keychain/Android Keystore-backed plugin), not ordinary preferences; saving private data remains account-scoped.
- The public registration endpoint was checked with an invalid request and returned HTTP 422 validation errors as expected (no account was created in this validation check).
- The original dark/white logo PNG bytes have been added as bundled Flutter assets (offline), with regression checks for their canonical byte sizes.

### Verification release-candidate trigger
The one-time CI Flutter formatter completed and removed itself. The next Mobile CI run must be evaluated on the new branch HEAD; earlier cancelled runs are not acceptance evidence. Do not merge the draft without actual device QA and alignment of body-type/weight fields to the original website.
