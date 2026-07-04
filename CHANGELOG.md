## 1.0.2

* Reduce redundant platform-channel traffic for native text fields (param diffing and sync guards).
* Avoid unnecessary widget rebuilds using `ListenableBuilder` for focus and display updates.
* Isolate native platform views with `RepaintBoundary` for smoother compositing.
* Deduplicate Android / Apple native field logic into shared helpers.
* Expand widget and platform tests; fix stale Android unit test.

## 1.0.1

* Add Swift Package Manager support for iOS and tvOS.
* Migrate Android plugin to built-in Kotlin (remove legacy `build.gradle`).
* Update minimum supported Flutter version to 3.44.

## 1.0.0
 

* Declare Web, Windows, macOS, and Linux plugin platform support.
* Add Dart plugin registration for desktop and web targets.
* Replace `dart:io` platform checks with `defaultTargetPlatform` for web compatibility.

## 0.1.1

* Add repository, homepage, and issue tracker links to `pubspec.yaml`.
* Add GitHub Actions CI and pub.dev publish workflow.

## 0.1.0

* Initial release.
* TV-friendly `TvTextField` with D-pad / Siri Remote focus fixes.
* Native `EditText` on Android and native `UITextField` on iOS / tvOS.
* Flutter fallback for desktop, web, and mobile.
* `TvTextFieldScope` for directional navigation mode.
* Platform auto-detection for Android TV and Apple TV.
