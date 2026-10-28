# Articulate

An offline personal communication-training application for Android and Windows. Practice writing, reading, speaking, memory, debate and impromptu responses. Drafts, reviews and recordings stay on the device; there is no account, sync or AI assessment.

## Installation

### Direct downloads

**Installable downloads are not published yet.** The [GitHub Releases page](https://github.com/Dreii101/Articulate/releases) is where the Android and Windows downloads will appear when distribution is cleared. It currently contains no installer assets.

The prepared Android ARM64 APK and Windows x64 bundle are private release candidates. Their bundled native audio libraries still need a complete corresponding-source package and verified attribution inventory; see [native audio notices](assets/licenses/NATIVE-NOTICES.txt). I have not published those files as downloads.

The planned downloads are:

- **Android ARM64:** one APK for 64-bit ARM phones. The tested phone was an OPPO CPH2565 running Android 15/API 35; it installed, launched, recorded and played audio.
- **Windows x64:** a ZIP containing the complete app folder. Extract the folder and run `articulate.exe`; the EXE needs its DLLs and `data` directory beside it, so it is not a standalone file. A clean Windows installation and shortcut check are still pending.

### Build and install from source

Use Flutter 3.47.7 / Dart 3.13.5 and the Android SDK. Windows builds also require Visual Studio 2022 with **Desktop development with C++**. Clone this repository and run:

```sh
git clone https://github.com/Dreii101/Articulate.git
cd Articulate
flutter pub get
flutter analyze
flutter test --concurrency=1
```

To run the app on Windows:

```powershell
flutter run -d windows
```

To create and install an Android ARM64 release APK, create a signing key once, back it up securely, then build and install:

```powershell
.\tool\create-signing-key.ps1
flutter build apk --release --target-platform android-arm64
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

Keep the generated `.private` key and passwords out of Git. Future APK updates must be signed with the same key.

To build the Windows x64 app:

```powershell
flutter build windows --release
```

Run `build\windows\x64\runner\Release\articulate.exe` from the complete release folder. If packaging it yourself, include every file in that folder; do not copy the EXE alone. Flutter's [Android deployment guide](https://docs.flutter.dev/deployment/android) and [Windows build guide](https://docs.flutter.dev/platform-integration/windows/building) cover tool setup.

These are developer build instructions, not direct downloads. The verified release targets ARM64 Android (API 24+) and x64 Windows only.

## Privacy and backups

Settings → Data & privacy can export an unencrypted local archive containing practice text and original audio. Keep exports private and validate a backup before changing installations. Restore replaces the current library after a preview and explicit confirmation. Android↔Windows export and restore were verified on physical Android with synthetic test libraries; personal practice data was not used.

## Practice

Memory review suggestions are optional heuristics based on the user's own observations. Intervals and due dates can be changed. Custom exercise content is versioned; attempts preserve their original exercise and rubric. Benchmark labels and self-reviews describe user-provided conditions and judgments, not objective scores.

## Third-party notices

Font licenses and currently identified native audio notices are in `assets/fonts` and `assets/licenses`; Flutter dependency licenses are available in the app. Further native-library source, relinking and attribution work is required before redistributing packaged binaries. Articulate's original source is licensed under the [MIT License](LICENSE); third-party components and bundled assets retain their own licenses and notices.
