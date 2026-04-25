# ⌚ Stress Wear: System Overview & Documentation

This document provides a high-level technical overview of the **Stress Wear** project, covering the Frontend (Watch App), Backend (Inference API), and Database (Firebase).

---

## 1. System Architecture
The system follows a classic **Client-Server** architecture designed for low-power wearable devices.

```mermaid
graph LR
    A[Galaxy Watch 5 Pro] -- "JSON (HRV Features)" --> B[Flask Backend]
    B -- "Inference" --> C[ML Model (.pkl)]
    B -- "Log Result" --> D[Firebase Firestore]
    B -- "Prediction" --> A
```

1.  **Watch App:** Collects heart rate samples and calculates HRV (Heart Rate Variability) features.
2.  **API Request:** Sends these features to the Flask server via a REST POST request.
3.  **ML Inference:** The server feeds the data into a pre-trained Gradient Boosting model.
4.  **Storage:** The result is saved to Firebase for long-term tracking.
5.  **Display:** The user sees their current stress level on the watch face.

---

## 2. Frontend: Flutter Wear OS App
The frontend is built with **Flutter** specifically for Wear OS devices.

- **Location:** `d:\Project\ResearchProject\stress_wear_app`
- **Key Files:**
  - `lib/main.dart`: UI logic and state management.
  - `lib/core/constants.dart`: Connection settings (IP/Port).
  - `MainActivity.kt`: Uses a **Platform Channel** to talk to the native Android Body Sensors.
- **Features:** 
  - Minimalist, dark-themed UI for watch screens.
  - Native sensor integration for real-time Heart Rate data.
  - Automated HRV feature extraction.

---

## 3. Backend: Flask Inference API
A Python-based server that handles the "heavy lifting" (Machine Learning) to save watch battery.

- **Location:** `d:\Project\ResearchProject\Wear_OS_Backend`
- **Port:** `5005` (Customized to avoid Windows system conflicts).
- **Technology Stack:**
  - **Flask:** Light-weight REST API.
  - **Scikit-Learn:** Loads and runs the `stress_detection_modelv1.pkl`.
  - **Python-Dotenv:** Manages configuration via a `.env` file.
- **Endpoint:** `POST /predict`
  - Accepts 11 features (BPM, SDNN, RMSSD, Frequency domain features, etc.).
  - Handles "missing" features by providing smart defaults.

---

## 4. Database: Firebase Integration
Used for persistent storage of stress data and user logs.

- **Type:** Google Cloud Firestore.
- **Security:** Uses a private **Service Account Key** (`serviceAccountKey.json`) so the watch doesn't need to be exposed to the public internet.
- **Data Schema:**
  ```json
  {
    "user_id": "string",
    "timestamp": "iso_date",
    "prediction": { "label": "stressed", "confidence": 0.95 },
    "features": { "mean_hr": 75, ... }
  }
  ```

---

## 5. Quick Execution Guide

### Start the Backend
1. Open terminal in `Wear_OS_Backend`.
2. Run `python app.py`.
3. Verify at `http://localhost:5005/`.

### Start the Watch App
1. Open `stress_wear_app` in Android Studio.
2. Run `flutter doctor --android-licenses` (First time only).
3. Connect your watch/emulator and click **Run**.

---

## 🛠️ Project Maintenance
- **To update the ML Model:** Simply replace `stress_detection_modelv1.pkl` in the backend folder.
- **To change the API Port:** Edit `FLASK_PORT` in the `.env` file and update `constants.dart` in the Flutter app.
- **To view logs:** Visit the [Firebase Console](https://console.firebase.google.com/) under Firestore > `stress_predictions`.
