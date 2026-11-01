# LunaCare 0.3.0 — unified Flutter starter

This project combines the LunaCare 2.0 cycle calendar and daily symptom journal
with the security and utility services from the 3.0 starter.

## Included
- Arabic, French and English interface; Arabic uses right-to-left layout.
- Period start history, estimated cycle length and a monthly calendar.
- Daily mood, pain, flow, symptoms and notes.
- Local encrypted JSON storage using AES-256-GCM; key stored using
  `flutter_secure_storage`.
- One-time migration from the previous SharedPreferences starter data.
- Optional local reminder scheduling (permission required).
- PDF report preview/export.
- Biometric authentication test action.

## Important limitations
- This is a development starter, not a signed/release-ready app.
- The biometric action is currently a test action; it does not yet lock the
  entire app at launch or manage a PIN.
- Reminder scheduling currently creates one reminder for the next estimated
  date. Verify notification permissions and scheduling on each target device.
- Web secure-storage behavior requires HTTPS/localhost and browser testing.
- PDF output currently uses a basic Latin-safe layout; Arabic/French text
  rendering and embedded fonts need additional validation.
- iOS requires Xcode project configuration and permission descriptions.
- Android requires checking Gradle/plugin compatibility and notification
  permission configuration.
- No clinical validation is performed. Cycle estimates are informational only,
  are not guaranteed, and must not be used as contraception or diagnosis.
- Local storage means data can be lost if the app/browser data is cleared or
  the device is lost. Add a user-controlled encrypted export before relying
  on it as the only copy.

## Run
1. Install Flutter 3.19+ and verify with `flutter doctor`.
2. From this folder run `flutter pub get`.
3. Run Android: `flutter run -d <device-id>`.
4. Run web: `flutter run -d chrome` (test on HTTPS for secure storage).
5. Build web: `flutter build web`.
6. Build Android release: `flutter build apk --release`.
7. Build iOS on macOS with Xcode: `flutter build ios`.

## Privacy
The app has no analytics, ad SDK, account system or cloud sync configured.
The project is intended to keep records on the user's device.

## Automated APK build with GitHub Actions
This repository includes `.github/workflows/build-apk.yml`. Upload the project
contents to a GitHub repository, then open **Actions → Build LunaCare APK →
Run workflow**. When the workflow succeeds, download the
`lunacare-android-release` artifact. The workflow generates the Android
platform folder, installs dependencies and builds the release APK.
