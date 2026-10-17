# KabulFit luxury fashion Flutter showcase — implementation status

Reference: approved 12-panel **KabulFit Luxury Fashion App Showcase.png** from the user's ChatGPT Library.

This design branch is based on `feat/batch-18-opt-in-demo-catalog` and connects to the **staging-only Laravel API** at `https://kabulfit.businessos.af/api/v1`. The original `kabulfit.com` continues to run Base44. Keep USD-only original backend prices, original product inventory and size choices, live backend categories and product images. Do not enable demo products for acceptance testing.

## Design coverage

| Reference panel | Implementation | Remaining acceptance |
| --- | --- | --- |
| 1. Splash / onboarding | Three-slide first-install introduction with real product photography, localized labels, stored completion | Confirm imagery/cropping and layout on actual iPhone |
| 2. Home | Branded light storefront, search navigation, editorial catalog hero, backend category photo avatars, featured products, five tabs | Screenshot/layout comparison, localized long-copy and image loading |
| 3. Shop / category | Responsive product photo cards, search, real USD pricing, backend category filter, five tabs | Visual polish and device RTL QA |
| 4. Product detail | Swipeable gallery, size chips, tailoring section, backend stock-safe cart/wishlist actions | Add thumbnail rail, preview actual size/variant combinations |
| 5. Measurement guide | Guide route with live hero and actionable step-by-step written tips | Tutorial videos must not be shown as real until verified content exists |
| 6. Side menu | Branded navigation drawer, real destinations, language options | Match drawer spacing and typography on phone |
| 7. Cart | Redesigned cards, safe quantity mutations, USD subtotal, navigation | Display real product thumbnails and refined row spacing |
| 8. Checkout | Elegant address/shipping/summary design while preserving pending-order/payment safety | Full 3-step visual workflow, payment deliberately disabled without Stripe config |
| 9. Account | Branded customer account header with live email, all real destinations | Real-device avatar and email overflow QA |
| 10. Orders | Existing real backend orders/tracking screens | Redesign order status cards and tabs to reference |
| 11. Wishlist | Branded card/list view, real customer wishlist items | Show product photography and quick actions when API supports them |
| 12. Measurement profile | Real profile CRUD with bottom navigation | Add visual measurement summary; never invent body measurements |

## Verification before merge

- GitHub Mobile CI format, strict analyze, Flutter tests, Android builds and unsigned iOS preflight all pass.
- Compare all 12 screens against original reference on physical iPhone, including small screens and landscape/RTL where applicable.
- English, Dari and Pashto text, navigation and buttons validated.
- All categories/products/photos/prices, USD-only, original sizes, stock, auth, cart and orders tested against staging API.
- No real charges and no domain cutover before final approval.
- An unsigned IPA is a packaging test only, **not a normally installable iOS distribution**. Signed IPA requires Apple provisioning.

## Development-only verification

The redesign is committed as draft PR #14. Verify it with the **current branch HEAD** and an uncancelled Mobile CI workflow; success from prior branches does not validate the new screens. The iOS artifact is unsigned and is not an ordinary installable IPA. Compare all 12 panels on a device before visual sign-off.
