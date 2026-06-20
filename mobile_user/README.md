# Arindi — User App (Flutter)

Mobile app for households to request waste pickup (po'choq, bo'tilka, plasmassa,
maklatura), track balance, and withdraw money.

## Features
- Phone + OTP login (OTP returned by the API in dev mode)
- Home with 4 category cards; only **Po'choq** is active, the rest show a
  "coming soon" alert
- New request form: weight (kg), home address with **Google Maps** picker,
  comment, **photo** (camera/gallery), and "Olib ketishsin" button
- History of requests with live status
- Balance + withdrawal (min 15 000 so'm): amount, card number, card holder,
  success alert → back to home
- Notifications (e.g. "to'lov qilindi")
- Profile: change language (uz/ru/en), about, dark mode

## Setup

```bash
cd mobile_user
flutter create .          # generates android/ ios/ platform folders (keeps lib/)
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

- `10.0.2.2` is the host machine from the Android emulator.
- For a real device use your computer's LAN IP, e.g. `http://192.168.1.10:8000`.

## Required platform configuration

After `flutter create .`, add the following.

### Android — `android/app/src/main/AndroidManifest.xml`
Inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
```
Inside `<application>` (Google Maps key):
```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```
Set `minSdkVersion 21` (or higher) in `android/app/build.gradle`.

### iOS — `ios/Runner/Info.plist`
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Manzilingizni xaritadan tanlash uchun</string>
<key>NSCameraUsageDescription</key>
<string>Chiqindi rasmini olish uchun</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Galereyadan rasm tanlash uchun</string>
```
Add your Google Maps key in `ios/Runner/AppDelegate.swift`:
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

## Project structure
```
lib/
  core/        constants, theme, l10n, storage, api_client, app_state
  models/      app_user, application, withdrawal, app_notification, category
  services/    services.dart (Auth/Profile/Category/Application/Withdrawal/Notification)
  widgets/     helpers, status_chip
  screens/
    auth/        phone_screen, otp_screen
    home/        main_shell, home_screen
    application/ pochoq_form_screen, map_picker_screen, applications_screen
    profile/     profile_screen, balance_screen, withdrawal_screen
    notifications/ notifications_screen
```
