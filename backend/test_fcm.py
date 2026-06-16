import os
import sys
import logging
from dotenv import load_dotenv

load_dotenv()
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from backend.app.services.notification_service import send_push
from backend.app.core.firebase import get_firebase_app

# Set up logging to console
logging.basicConfig(level=logging.INFO)

def test_fcm():
    print("Testing Firebase Cloud Messaging Configuration...")
    
    # 1. Check if Firebase initializes
    app = get_firebase_app()
    if app == "MOCK":
        print("[WARNING] Firebase is running in MOCK mode. Please provide FIREBASE_CREDENTIALS_JSON to enable real push notifications.")
    else:
        print("[SUCCESS] Firebase initialized successfully with real credentials.")

    # 2. Test sending a push notification (If you have a real device token, replace it here)
    # Put your physical device's FCM token here to test it on your real phone
    TEST_DEVICE_TOKEN = os.getenv("TEST_DEVICE_FCM_TOKEN", "YOUR_TEST_DEVICE_TOKEN_HERE")
    
    if TEST_DEVICE_TOKEN and TEST_DEVICE_TOKEN != "YOUR_TEST_DEVICE_TOKEN_HERE":
        print(f"\nAttempting to send test push to token: {TEST_DEVICE_TOKEN}")
        success = send_push(
            fcm_token=TEST_DEVICE_TOKEN,
            title="Bonded Dev Test",
            body="If you see this, push notifications are working!"
        )
        if success:
            print("[SUCCESS] Push notification dispatched successfully!")
        else:
            print("[ERROR] Push notification failed to send.")
    else:
        print("\n[INFO] No real device token provided. Skipping actual push dispatch test.")
        print("To test a real push, set TEST_DEVICE_FCM_TOKEN in your .env or replace 'YOUR_TEST_DEVICE_TOKEN_HERE' in this script.")

if __name__ == "__main__":
    test_fcm()
