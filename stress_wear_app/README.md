# Wear OS Stress Detection – Flutter App

Wear OS app for Galaxy Watch 5 Pro that:
1. Collects heart-rate data (dummy in Stage 1, real sensor in Stage 2+).
2. Calculates HRV features locally.
3. POSTs features to the Flask backend.
4. Displays the stress prediction result on the watch face.

---

## Prerequisites

| Tool | Version |
|------|---------|
| Flutter | ≥ 3.x |
| Dart | ≥ 3.x |
| Android Studio | Hedgehog or newer |
| Wear OS emulator | API 30+ or Galaxy Watch 5 Pro connected via adb |

---

## Quick start

```bash
# Install dependencies
flutter pub get

# Run on emulator or connected watch
flutter run
```

---

## Connect to the Flask backend

1. Find your laptop's IP address:
   ```
   ipconfig          # Windows
   ifconfig          # macOS / Linux
   ```
2. Open `lib/core/constants.dart` and update:
   ```dart
   static const String flaskBaseUrl = 'http://192.168.1.8:5000';
   ```
   > ⚠️ Never use `localhost` on a physical device.

3. Make sure Flask is running with `host="0.0.0.0"`.

4. Both the laptop and watch must be on the **same Wi-Fi network**.

---

## Folder structure

```
lib/
├── main.dart
├── core/
│   ├── constants.dart        ← Flask URL lives here
│   └── app_theme.dart
├── data/
│   ├── models/
│   │   ├── stress_request.dart
│   │   └── stress_response.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   └── heart_rate_service.dart
│   └── repositories/
│       └── stress_repository.dart
├── domain/
│   └── hrv_calculator.dart
├── presentation/
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── measuring_screen.dart
│   │   └── result_screen.dart
│   └── widgets/
│       └── round_button.dart
└── state/
    └── stress_controller.dart
```

---

## Development stages

| Stage | Change required |
|-------|----------------|
| 1 – Dummy HR + Dummy API | No changes – runs immediately |
| 2 – Dummy HR + Real model | Update Flask `app.py`, point `constants.dart` to laptop IP |
| 3 – Real sensor | Uncomment Platform Channel in `MainActivity.kt` + `heart_rate_service.dart` |
| 4 – Production | Deploy Flask, change `flaskBaseUrl` to HTTPS endpoint |

---

## Permissions

Declared in `android/app/src/main/AndroidManifest.xml`:

- `BODY_SENSORS` – heart-rate sensor access
- `INTERNET` – HTTP calls to the Flask backend
- `usesCleartextTraffic="true"` – allows `http://` during local testing (remove after deployment)
