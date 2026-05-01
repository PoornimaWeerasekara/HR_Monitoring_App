import os
import firebase_admin
from firebase_admin import credentials, firestore
from dotenv import load_dotenv

load_dotenv()

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
FIREBASE_KEY_PATH = os.getenv("FIREBASE_KEY_PATH", "serviceAccountKey.json")
FULL_KEY_PATH = os.path.join(BASE_DIR, FIREBASE_KEY_PATH)

if not os.path.exists(FULL_KEY_PATH):
    print(f"Error: Firebase key not found at {FULL_KEY_PATH}")
    exit(1)

cred = credentials.Certificate(FULL_KEY_PATH)
firebase_admin.initialize_app(cred)
db = firestore.client()

print("Fetching latest heart rate logs...")
docs = db.collection("heart_rate_logs").order_by("timestamp", direction=firestore.Query.DESCENDING).limit(10).stream()

print("| Timestamp | User ID | Label | Confidence | Mean HR | SDNN | RMSSD |")
print("|-----------|---------|-------|------------|---------|------|-------|")

for doc in docs:
    data = doc.to_dict()
    ts = data.get("timestamp")
    uid = data.get("user_id", "N/A")
    pred = data.get("prediction", {})
    label = pred.get("label", "N/A")
    conf = pred.get("confidence", 0.0)
    feats = data.get("features", {})
    mean_hr = feats.get("mean_hr", 0.0)
    sdnn = feats.get("sdnn", 0.0)
    rmssd = feats.get("rmssd", 0.0)
    
    print(f"| {ts} | {uid} | {label} | {conf} | {mean_hr:.1f} | {sdnn:.1f} | {rmssd:.1f} |")
