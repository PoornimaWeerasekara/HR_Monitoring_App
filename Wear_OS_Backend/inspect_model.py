import joblib
import os

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, "stress_detection_model.pkl")

if os.path.exists(MODEL_PATH):
    model = joblib.load(MODEL_PATH)
    print(f"Model type: {type(model)}")
    
    if hasattr(model, 'classes_'):
        print(f"Classes: {model.classes_}")
    else:
        print("Classes not found.")
else:
    print("Model not found.")
