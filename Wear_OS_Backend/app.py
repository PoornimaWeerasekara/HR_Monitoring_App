import os
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

# 4. Routes
@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy", "firebase": db is not None})

@app.route("/predict", methods=["POST"])
def predict():
    """
    Receives heart-rate data and saves it to Firestore for the main VitaSense app.
    Returns the mean heart rate for display on the watch.
    """
    data = request.get_json()
    if not data:
        return jsonify({"error": "No data provided"}), 400

    user_id = data.get("user_id", "default_user")
    features = data.get("features", {})
    
    # Extract mean heart rate
    measured_hr = features.get("mean_hr", 0.0)

    # ── Firebase persistence (Firestore) ──────────────────────────────────
    if db:
        try:
            save_data = {
                "user_id": user_id,
                "timestamp": firestore.SERVER_TIMESTAMP,
                "heart_rate": measured_hr,
                "features": features,
                "app_source": "vitasense_wear_os"
            }
            # Save to 'heart_rate_logs' for the main VitaSense app to consume
            db.collection("heart_rate_logs").add(save_data)
        except Exception as e:
            print(f"[ERROR] Failed to save to Firebase Firestore: {e}")
    # ────────────────────────────────────────────────────────────────────────

    return jsonify({
        "status": "success", 
        "prediction": {
            "label": "measured", 
            "confidence": 1.0,
            "mean_hr": measured_hr
        }
    })

if __name__ == "__main__":
    # Port 5005 as expected by the Watch app
    app.run(host="0.0.0.0", port=5005, debug=True)
