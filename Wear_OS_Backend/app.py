"""
Wear OS Stress Detection Backend
=================================
Serves a REST API that:
  1. Accepts HRV feature JSON from the Flutter Wear OS app
  2. Runs inference through the trained Keras model
  3. Persists the result to Firebase Firestore
  4. Returns the prediction to the watch

Development stages
------------------
Stage 1 (dummy) : comment-in STAGE_1 block, comment-out everything else
Stage 2 (model) : uncomment the model loading section
Stage 3 (firebase): uncomment the firebase section
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# ── Stage 2+: Model loading ─────────────────────────────────────────────────
# Uncomment the lines below once you have placed stress_detection_modelv1.pkl in this
# folder and installed scikit-learn.
#
import joblib
import os

# Build path relative to this script
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_FILENAME = os.getenv("MODEL_FILENAME", "stress_detection_modelv1.pkl")
MODEL_PATH = os.path.join(BASE_DIR, MODEL_FILENAME)

model = joblib.load(MODEL_PATH)
print(f"[INFO] Model loaded successfully from {MODEL_PATH}")
# ────────────────────────────────────────────────────────────────────────────

# ── Stage 3+: Firebase initialisation ───────────────────────────────────────
import firebase_admin
from firebase_admin import credentials, firestore

# Point to the JSON file you just provided
FIREBASE_KEY_PATH = os.getenv("FIREBASE_KEY_PATH", "serviceAccountKey.json")
FIREBASE_DB_URL = os.getenv("FIREBASE_DB_URL", "https://vitasense-6eeb1-default-rtdb.firebaseio.com/")

cred = credentials.Certificate(os.path.join(BASE_DIR, FIREBASE_KEY_PATH))
firebase_admin.initialize_app(cred, {
    'databaseURL': FIREBASE_DB_URL
})

db = firestore.client()
print("[INFO] Firebase Firestore connected successfully.")
# ────────────────────────────────────────────────────────────────────────────

app = Flask(__name__)
CORS(app)

# ─── Feature order must match training data exactly ─────────────────────────
FEATURE_KEYS = [
    'window_seconds', 'hr_bpm', 'rr_mean_ms', 'sdnn_ms', 'rmssd_ms',
    'pnn50_percent', 'respiration_rate_bpm', 'lf_power_ms2', 'hf_power_ms2',
    'lf_hf_ratio', 'total_power_ms2'
]


def _extract_input(features: dict) -> np.ndarray:
    """Build a (1, 11) numpy array from the features dict with fallbacks."""
    try:
        # Mapping incoming Flutter features to model features
        values = [
            float(features.get("window_seconds", 60.0)),
            float(features.get("mean_hr", features.get("hr_bpm", 75.0))),
            float(features.get("mean_rr", features.get("rr_mean_ms", 800.0))),
            float(features.get("sdnn", features.get("sdnn_ms", 50.0))),
            float(features.get("rmssd", features.get("rmssd_ms", 45.0))),
            float(features.get("pnn50", features.get("pnn50_percent", 20.0))),
            float(features.get("respiration_rate", 15.0)),
            float(features.get("lf_power", 500.0)),
            float(features.get("hf_power", 500.0)),
            float(features.get("lf_hf_ratio", 1.0)),
            float(features.get("total_power", 1000.0))
        ]
        return np.array([values])
    except Exception as e:
        raise ValueError(f"Feature processing error: {e}")
# ────────────────────────────────────────────────────────────────────────────

# ─── Routes ─────────────────────────────────────────────────────────────────

@app.route("/", methods=["GET"])
def home():
    return "Stress Detection API is running ✅"


@app.route("/health", methods=["GET"])
def health():
    """Lightweight health-check endpoint."""
    return jsonify({"status": "ok"})


@app.route("/predict", methods=["POST"])
def predict():
    data = request.get_json(silent=True)
    if not data:
        return jsonify({"error": "Request body must be valid JSON"}), 400

    user_id   = data.get("user_id")
    timestamp = data.get("timestamp")
    features  = data.get("features")

    # ── Basic validation ─────────────────────────────────────────────────────
    if not user_id or not features:
        return jsonify({"error": "Missing required fields: user_id, features"}), 400

    # ── Stage 1: Dummy prediction (remove once model is loaded) ─────────────
    # probability = 0.75
    # label = "not_stressed"
    # ────────────────────────────────────────────────────────────────────────

    # ── Stage 2+: Real model prediction ─────────────────────────────────────
    # Uncomment the block below (and remove the Stage-1 dummy block above)
    # once the model is loaded.
    #
    try:
        input_data = _extract_input(features)
    except ValueError as e:
        return jsonify({"error": str(e)}), 422
    
    try:
        # Try to get probabilities if the model supports it
        raw_probs = model.predict_proba(input_data)
        # Assuming class 1 is "stressed", depending on how model was trained.
        # If it's a binary classifier, raw_probs[0] is typically [prob_0, prob_1]
        probability = float(raw_probs[0][1]) if len(raw_probs[0]) > 1 else float(raw_probs[0][0])
    except AttributeError:
        # Fallback if predict_proba is not available
        raw = model.predict(input_data)
        probability = float(raw[0]) if hasattr(raw[0], '__float__') else 1.0 # fallback confidence
    
    label = "stressed" if probability >= 0.5 else "not_stressed"
    # ────────────────────────────────────────────────────────────────────────

    result = {"label": label, "confidence": probability}

    # ── Stage 3+: Firestore persistence ─────────────────────────────────────
    try:
        save_data = {
            "user_id": user_id,
            "timestamp": timestamp,
            "features": features,
            "prediction": result,
        }
        # Saves to the 'stress_predictions' collection
        db.collection("stress_predictions").add(save_data)
    except Exception as e:
        print(f"[ERROR] Failed to save to Firestore: {e}")
    # ────────────────────────────────────────────────────────────────────────

    return jsonify({"status": "success", "prediction": result})


# ─── Entry point ─────────────────────────────────────────────────────────────
if __name__ == "__main__":
    host = os.getenv("FLASK_HOST", "0.0.0.0")
    port = int(os.getenv("FLASK_PORT", 5005))
    # host="0.0.0.0"  → accessible from watch on the same Wi-Fi
    app.run(host=host, port=port, debug=True)
