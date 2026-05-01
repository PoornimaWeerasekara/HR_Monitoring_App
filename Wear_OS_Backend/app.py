import os
import joblib
import numpy as np
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

# 1. Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)

# 2. Build paths
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# 3. Firebase Initialisation
import firebase_admin
from firebase_admin import credentials, firestore

FIREBASE_KEY_PATH = os.getenv("FIREBASE_KEY_PATH", "serviceAccountKey.json")
FIREBASE_PROJECT_ID = os.getenv("FIREBASE_PROJECT_ID", "vitasense-6eeb1")
FIREBASE_DB_URL = os.getenv("FIREBASE_DB_URL", "https://vitasense-6eeb1-default-rtdb.firebaseio.com")

FULL_KEY_PATH = os.path.join(BASE_DIR, FIREBASE_KEY_PATH)

db = None
if os.path.exists(FULL_KEY_PATH):
    try:
        cred = credentials.Certificate(FULL_KEY_PATH)
        firebase_admin.initialize_app(cred, {
            'projectId': FIREBASE_PROJECT_ID,
            'databaseURL': FIREBASE_DB_URL
        })
        db = firestore.client()
        print("[INFO] Firebase Firestore connected successfully.")
    except Exception as e:
        print(f"[ERROR] Firebase failed to initialise: {e}")
else:
    print(f"[WARNING] Firebase key not found at {FULL_KEY_PATH}. Data will not be saved.")

# 4. Load ML Model
MODEL_PATH = os.path.join(BASE_DIR, "stress_detection_model.pkl")
model = None
if os.path.exists(MODEL_PATH):
    try:
        model = joblib.load(MODEL_PATH)
        print("[INFO] Stress Detection Model loaded successfully.")
    except Exception as e:
        print(f"[ERROR] Failed to load model: {e}")
else:
    print(f"[WARNING] Model file not found at {MODEL_PATH}. Using dummy fallback.")

def _extract_input(features):
    """
    Ensures features are in the correct order for the GradientBoostingClassifier (11 features):
    'window_seconds' 'hr_bpm' 'rr_mean_ms' 'sdnn_ms' 'rmssd_ms'
    'pnn50_percent' 'respiration_rate_bpm' 'lf_power_ms2' 'hf_power_ms2'
    'lf_hf_ratio' 'total_power_ms2'
    """
    try:
        return np.array([[
            60.0,                                # window_seconds
            features.get("mean_hr", 75.0),       # hr_bpm
            features.get("mean_rr", 800.0),      # rr_mean_ms
            features.get("sdnn", 50.0),          # sdnn_ms
            features.get("rmssd", 45.0),         # rmssd_ms
            features.get("pnn50", 20.0),         # pnn50_percent
            15.0,                                # respiration_rate_bpm
            100.0,                               # lf_power_ms2
            100.0,                               # hf_power_ms2
            1.0,                                 # lf_hf_ratio
            200.0                                # total_power_ms2
        ]])
    except Exception as e:
        raise ValueError(f"Feature processing error: {e}")

# 5. Routes
@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy", "firebase": db is not None, "model": model is not None})

@app.route("/predict", methods=["POST"])
def predict():
    """
    Receives heart-rate data, runs stress prediction, and saves to Firestore.
    Returns the prediction result for display on the watch.
    """
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data provided"}), 400

    user_id = data.get("user_id", "default_user")
    features = data.get("features", {})
    
    # ── Inference ─────────────────────────────────────────────────────────
    prediction_result = {"label": "not_stressed", "confidence": 1.0} # Default
    
    if model:
        try:
            input_data = _extract_input(features)
            pred = model.predict(input_data)[0]
            
            # The model returns 'low', 'medium', or 'high'
            raw_label = str(pred).lower().strip()
            
            # Map to 'stressed' or 'not_stressed' as requested
            if raw_label == 'low':
                label = "not_stressed"
            elif raw_label in ['medium', 'high']:
                label = "stressed"
            else:
                label = raw_label # Fallback if unknown
            
            confidence = 1.0
            if hasattr(model, "predict_proba"):
                probs = model.predict_proba(input_data)[0]
                confidence = float(np.max(probs))

            prediction_result = {
                "label": label,
                "confidence": confidence # Full precision to match user image
            }
        except Exception as e:
            print(f"[ERROR] Prediction failed: {e}")
            prediction_result = {"label": "error", "confidence": 0.0, "error": str(e)}

    # ── Firebase persistence (Firestore) ──────────────────────────────────
    if db:
        try:
            import datetime
            iso_timestamp = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")

            save_data = {
                "user_id": user_id,
                "timestamp": firestore.SERVER_TIMESTAMP, # Native Firestore Timestamp for 'actual time'
                "prediction": prediction_result,
                "features": features
            }
            # Revert to 'stress_predictions' collection as per user request
            db.collection("stress_predictions").add(save_data)
        except Exception as e:
            print(f"[ERROR] Failed to save to Firebase Firestore: {e}")
    # ────────────────────────────────────────────────────────────────────────

    return jsonify({
        "status": "success", 
        "prediction": {
            **prediction_result,
            "mean_hr": features.get("mean_hr", 0.0)
        }
    })

if __name__ == "__main__":
    # Port 5005 as expected by the Watch app
    app.run(host="0.0.0.0", port=5005, debug=True)
