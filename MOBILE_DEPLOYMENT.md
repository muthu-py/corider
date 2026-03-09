# Mobile Deployment & Troubleshooting Guide

This document summarizes the setup, fixes, and commands required to run the CoRider app on a mobile device while connected to a backend running on your laptop.

## 1. Running the Backend for Mobile Access

To allow your mobile device to connect to your laptop, the backend must listen on all network interfaces.

**Command:**
```bash
cd backend
../venv/bin/uvicorn app.main:app --reload --port 8000 --host 0.0.0.0
```

---

## 2. Shared Configuration (.env)

Your `.env` file in the root directory must point to your laptop's local IP address.

**Example Configuration:**
```env
SUPABASE_URL="your-supabase-url"
SUPABASE_ANON_KEY="your-anon-key"
BACKEND_URL="http://YOUR_LAPTOP_IP:8000"
GOOGLE_WEB_CLIENT_ID="your-google-web-client-id.apps.googleusercontent.com"
```

> [!TIP]
> To find your laptop's IP address:
> `ip addr show $(ip route get 1.2.3.4 | awk '{print $5}')`

---

## 3. Errors Encountered & Fixes

### Error: `No Android SDK found`
**Fix:** Installed the Android SDK and command-line tools from the Arch Linux AUR.
```bash
yay -S android-sdk android-sdk-platform-tools android-sdk-build-tools android-sdk-cmdline-tools-latest
flutter config --android-sdk /opt/android-sdk
yes | flutter doctor --android-licenses
```

### Error: `The SDK directory is not writable (/opt/android-sdk)`
**Fix:** Changed ownership of the SDK directory to the current user.
```bash
sudo chown -R $USER:$USER /opt/android-sdk
```

### Error: `PlatformException(sign_in_failed, Code 10)`
**Reason:** The app's SHA-1 fingerprint was not registered with Google/Supabase.
**Fix:** Identify the fingerprint and add it to the Google Cloud Console and Supabase Dashboard.
**Debug SHA-1:** `B5:54:A3:A6:74:75:B4:9B:92:94:31:22:FC:CE:17:D0:8F:4C:74:68`

### Error: `Login Failed: No ID Token found.`
**Reason:** `GoogleSignIn` was missing the `serverClientId` (Web Client ID).
**Fix:** 
1. Obtain a **Web application** Client ID from Google Cloud Console.
2. Update `AuthService.dart` to use it:
```dart
final GoogleSignIn googleSignIn = GoogleSignIn(
  serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
);
```

---

## 4. Building the App

To generate the installer (APK) for your phone:
```bash
flutter build apk --split-per-abi
```
**Recommended APK for most phones:**
`build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

---

## 5. Running Multiple Instances (Different Accounts)

To test with two different accounts on the same machine:
1. **Linux App:** Run `flutter run -d linux`.
2. **Web App:** Run `flutter run -d chrome`.
Since they use different storage mechanisms, their sessions remain isolated.
