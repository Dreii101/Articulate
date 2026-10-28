# Articulate

An offline personal communication-training application for Android and Windows. Practice writing, reading, speaking, memory, debate and impromptu responses. Drafts, reviews and recordings stay on the device; there is no account, sync or AI assessment.

## Installation

**No end-user downloads are published yet.** The native audio-library redistribution audit is still open, so no installers have been uploaded. The ARM64 Android candidate was freshly installed and launched on an OPPO CPH2565 (Android 15/API 35); physical capture/playback and Android↔Windows archive restores passed with synthetic fixtures. Windows clean-install and shortcut verification remain pending.

To build and install from source, use Flutter 3.47.7 / Dart 3.13.5 and the Android SDK; Windows builds also require Visual Studio 2022 with Desktop development with C++. Clone this repository, then run:

```sh
flutter pub get
flutter analyze
flutter test --concurrency=1
flutter run -d windows
```

For an Android release build, create a private signing key once and back it up securely, then build the ARM64 APK:

```powershell
.\tool\create-signing-key.ps1
flutter build apk --release --target-platform android-arm64
```

Install `build/app/outputs/flutter-apk/app-release.apk` by opening it on the phone, or with `adb install build/app/outputs/flutter-apk/app-release.apk`. Keep the generated `.private` key and passwords out of Git. A different key cannot update an installation signed by another developer.

For Windows, build and run the complete release folder:

```powershell
flutter build windows --release
```

Copy or zip the entire `build/windows/x64/runner/Release` folder, then run `articulate.exe` from that folder. Keep its DLL files and `data` directory alongside the executable; a shortcut can point to that executable.

These are self-build instructions, not published downloads. Do not redistribute generated packages until the native audio-library source, relinking and attribution audit is complete. Flutter's [Android deployment guide](https://docs.flutter.dev/deployment/android) and [Windows build guide](https://docs.flutter.dev/platform-integration/windows/building) cover tool setup.

The release candidate previously built by the project targets ARM64 Android (API 24+) and x64 Windows, not every Android or Windows architecture. Windows requires all generated DLLs and the complete `data` folder alongside the executable. See [native audio notices](assets/licenses/NATIVE-NOTICES.txt) for the unresolved distribution requirements.

## Privacy and backups

Settings → Data & privacy can export an unencrypted local archive containing practice text and original audio. Keep exports private and validate a backup before changing installations. Restore replaces the current library after a preview and explicit confirmation. Cross-platform restore remains to be verified on physical Android hardware.

## Practice

Memory review suggestions are optional heuristics based on the user's own observations. Intervals and due dates can be changed. Custom exercise content is versioned; attempts preserve their original exercise and rubric. Benchmark labels and self-reviews describe user-provided conditions and judgments, not objective scores.

## Third-party notices

Font licenses and currently identified native audio notices are in `assets/fonts` and `assets/licenses`; Flutter dependency licenses are available in the app. Further native-library source, relinking and attribution work is required before redistributing packaged binaries. Articulate's original source is licensed under the [MIT License](LICENSE); third-party components and bundled assets retain their own licenses and notices.
