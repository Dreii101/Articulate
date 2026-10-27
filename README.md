# Articulate

An offline personal communication-training application for Android and Windows. Practice writing, reading, speaking, memory, debate and impromptu responses. Drafts, reviews and recordings stay on the device; there is no account, sync or AI assessment.

## Installation

**Downloadable installers are not available yet.** The current binaries have not completed the native audio-library redistribution audit. Android hardware and Windows clean-install verification are also pending. Do not treat the current build as a production release.

Developers can run a local build using Flutter 3.47.7 / Dart 3.13.5, the Android SDK and, for Windows, Visual Studio 2022 with Desktop development with C++. Clone this repository and run:

```sh
flutter pub get
flutter analyze
flutter test --concurrency=1
flutter run -d windows
```

For a connected Android device, `flutter run -d <device-id>` creates a debug build. The existing application ID is `dev.articulate.articulate`; avoid uninstalling an existing copy or clearing its data. An Android release build requires your own private signing configuration; a different key cannot update an existing installation signed by the original developer. Do not commit keys or passwords. Flutter's [Android deployment guide](https://docs.flutter.dev/deployment/android) and [Windows build guide](https://docs.flutter.dev/platform-integration/windows/building) cover tool setup.

The release candidate previously built by the project targets ARM64 Android (API 24+) and x64 Windows, not every Android or Windows architecture. Windows requires all generated DLLs and the complete `data` folder alongside the executable. See [native audio notices](assets/licenses/NATIVE-NOTICES.txt) for the unresolved distribution requirements.

## Privacy and backups

Settings → Data & privacy can export an unencrypted local archive containing practice text and original audio. Keep exports private and validate a backup before changing installations. Restore replaces the current library after a preview and explicit confirmation. Cross-platform restore remains to be verified on physical Android hardware.

## Practice

Memory review suggestions are optional heuristics based on the user's own observations. Intervals and due dates can be changed. Custom exercise content is versioned; attempts preserve their original exercise and rubric. Benchmark labels and self-reviews describe user-provided conditions and judgments, not objective scores.

## Third-party notices

Font licenses and currently identified native audio notices are in `assets/fonts` and `assets/licenses`; Flutter dependency licenses are available in the app. Further native-library source, relinking and attribution work is required before redistributing packaged binaries. Articulate's original source is licensed under the [MIT License](LICENSE); third-party components and bundled assets retain their own licenses and notices.
