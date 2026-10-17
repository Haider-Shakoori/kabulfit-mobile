# KabulFit branded app icon and startup screen

- The launcher icon is derived from the **original KabulFit website favicon**,
  stored at `assets/brand/kabulfit-app-symbol.png`.
- The startup preloader uses the **original KabulFit wordmark**, not a generic
  placeholder, with a warm-white background and burgundy/gold accents.
- The startup indicator displays for at least 1.5 seconds while the saved
  onboarding preference is restored; onboarding and commerce remain unchanged.
- Apple uses a static warm-white native launch screen until Flutter draws its
  animated preloader. iOS does not support animation in the native launch screen.

## Generate the platform icons

```bash
flutter pub get
dart run tool/prepare_app_icon.dart
dart run flutter_launcher_icons
```

These commands generate a padded, opaque 1024px square master and correct
platform-specific icons for iOS and Android before building. They are also
performed automatically by GitHub Mobile CI and the existing signed-IPA
workflow, so a release does not accidentally retain the default Flutter icon.

The generated square master is ignored by Git; the original branded source
remains committed. No TestFlight distribution is triggered by these changes.
