# Arindi — Courier App (Flutter)

App for couriers (olib ketuvchilar) to receive pickup requests, accept them,
and finish ("qabul qildim") with an optional comment and confirmed weight.

## Features
- Phone + password login (couriers are created from the admin panel)
- Three tabs: **Yangi** (pending), **Mening** (accepted by me), **Yakunlangan** (collected)
- Request detail: photo, weight, estimated amount, address, comment
- Call the user / open the location in Google Maps
- **Accept** a pending request, then **finish** it (comment + actual weight) →
  the request moves to `collected` and the user is notified

## Setup
```bash
cd mobile_courier
flutter create .
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

### Default courier login (from backend seeder)
- Phone: `+998901112233`
- Password: `password`

### Android permission
Add to `android/app/src/main/AndroidManifest.xml` inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
`url_launcher` (tel / maps) needs these queries in the manifest:
```xml
<queries>
  <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
  <intent><action android:name="android.intent.action.DIAL"/><data android:scheme="tel"/></intent>
</queries>
```

## Structure
```
lib/
  core/      constants, theme, api_client, app_state
  models/    models.dart (Courier, Application)
  services/  services.dart (CourierService)
  widgets/   helpers.dart (StatusChip, formatMoney)
  screens/   login_screen, applications_screen, application_detail_screen
```
