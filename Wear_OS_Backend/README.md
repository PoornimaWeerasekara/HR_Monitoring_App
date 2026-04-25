# Wear OS Stress Detection – Flask Backend

REST API that receives HRV features from a Galaxy Watch 5 Pro,
runs inference on a trained Keras model, and persists results
to Firebase Firestore.

## Quick-start (Stage 1 – dummy mode)

```bash
# 1. Create & activate a virtual environment
python -m venv venv
venv\Scripts\activate          # Windows
# source venv/bin/activate     # macOS / Linux

# 2. Install dependencies
pip install flask flask-cors numpy

# 3. Run the server
python app.py
```

Open http://127.0.0.1:5000/ in a browser.
You should see: **Stress Detection API is running ✅**

---

## Development Stages

| Stage | What to enable | Extra packages |
|-------|---------------|----------------|
| 1 – Dummy API | No changes | `flask flask-cors numpy` |
| 2 – Real model | Uncomment model block in `app.py`, place `stress_model_v2.h5` here | `+ tensorflow` |
| 3 – Firebase | Uncomment firebase block, place `serviceAccountKey.json` here | `+ firebase-admin` |

---

## Postman test (Stage 1)

- **Method:** `POST`
- **URL:** `http://127.0.0.1:5000/predict`
- **Body → raw → JSON:**

```json
{
  "user_id": "student_001",
  "timestamp": "2026-04-25T10:30:00Z",
  "features": {
    "mean_hr": 82.5,
    "mean_rr": 727.3,
    "sdnn": 42.1,
    "rmssd": 35.8,
    "pnn50": 18.2,
    "min_hr": 74,
    "max_hr": 96
  }
}
```

Expected response:

```json
{
  "status": "success",
  "prediction": {
    "label": "not_stressed",
    "confidence": 0.75
  }
}
```

---

## Important security notes

- **Never commit `serviceAccountKey.json`** – it is already in `.gitignore`.
- Do not hard-code the Firebase credentials in source code.
- When deploying (Render / Railway / Cloud Run) supply the key as an environment variable or secret.

---

## Folder structure

```
Wear_OS_Backend/
├── app.py                  ← main Flask application
├── requirements.txt
├── .gitignore
├── stress_model_v2.h5      ← place your model here (not in repo)
├── serviceAccountKey.json  ← place your Firebase key here (not in repo)
└── README.md
```
