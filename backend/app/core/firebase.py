import os
import logging
import base64
import json
import firebase_admin
from firebase_admin import credentials

logger = logging.getLogger("bonded.firebase")

_firebase_app = None

def get_firebase_app():
    global _firebase_app
    if _firebase_app is not None:
        return _firebase_app

    # Try loading from base64 environment variable first (recommended for production like Render/Railway)
    fcm_creds_b64 = os.getenv("FIREBASE_CREDENTIALS_B64")
    
    # Resolve absolute path based on this file's location to prevent CWD issues
    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    default_creds_path = os.path.join(base_dir, "firebase-credentials.json")
    fcm_creds_path = os.getenv("FIREBASE_CREDENTIALS_JSON") or os.getenv("FIREBASE_CREDENTIALS_PATH", default_creds_path)

    try:
        if fcm_creds_b64:
            logger.info("Initializing Firebase with B64 credentials...")
            creds_json = json.loads(base64.b64decode(fcm_creds_b64).decode("utf-8"))
            cred = credentials.Certificate(creds_json)
            _firebase_app = firebase_admin.initialize_app(cred)
            logger.info("Firebase Admin initialized successfully via B64 environment variable.")
        elif os.path.exists(fcm_creds_path):
            logger.info(f"Initializing Firebase with certificate from {fcm_creds_path}...")
            cred = credentials.Certificate(fcm_creds_path)
            _firebase_app = firebase_admin.initialize_app(cred)
            logger.info("Firebase Admin initialized successfully via local credentials file.")
        else:
            logger.warning(
                "Firebase service account credentials missing. "
                "Push notifications will be logged to console only (Mock Mode)."
            )
            _firebase_app = "MOCK"
    except Exception as e:
        logger.error(f"Failed to initialize Firebase Admin SDK: {e}. Running in Mock Mode.")
        _firebase_app = "MOCK"

    return _firebase_app
