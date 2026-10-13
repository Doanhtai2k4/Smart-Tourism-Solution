import os
import json
import sys
from datetime import datetime
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

# Ensure UTF-8 printing
try:
    sys.stdout.reconfigure(encoding='utf-8')
except AttributeError:
    pass

# Paths
BASE_DIR = os.path.dirname(__file__)
DATA_DIR = os.path.join(BASE_DIR, 'data')
CREDENTIALS_FILE = os.path.join(BASE_DIR, 'firebase-credentials.json')
USERS_JSON_FILE = os.path.join(DATA_DIR, 'users_firebase.json')
TRIPS_JSON_FILE = os.path.join(DATA_DIR, 'trips_firebase.json')

print("=== Firebase Firestore Data Importer ===")

# 1. Verification
if not os.path.exists(CREDENTIALS_FILE):
    print(f"\n[ERROR] Missing Firebase credentials file at: {CREDENTIALS_FILE}")
    print("Please follow the instructions in the implementation plan to download 'firebase-credentials.json'")
    print("from the Firebase Console and save it into the analytics directory.")
    sys.exit(1)

if not os.path.exists(USERS_JSON_FILE) or not os.path.exists(TRIPS_JSON_FILE):
    print("\n[ERROR] Missing generated JSON files! Run generate_firebase_data.py first.")
    sys.exit(1)

# 2. Initialize Firebase Admin SDK
print("Connecting to Firebase Firestore...")
try:
    cred = credentials.Certificate(CREDENTIALS_FILE)
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("Successfully authenticated and connected to Firestore database!")
except Exception as e:
    print(f"[ERROR] Connection failed: {e}")
    sys.exit(1)

# Helper function to parse ISO/date strings to datetime objects (for Firestore Timestamps)
def parse_date(date_str, is_dob=False):
    if not date_str:
        return None
    try:
        if is_dob:
            return datetime.strptime(date_str, "%Y-%m-%d")
        else:
            # Handle trailing 'Z' if present
            clean_str = date_str.replace("Z", "")
            return datetime.fromisoformat(clean_str)
    except Exception:
        return None

# Helper to write operations in batches (Firestore limits to 500 per batch)
class BatchWriter:
    def __init__(self, db_client):
        self.db = db_client
        self.batch = db_client.batch()
        self.count = 0
        self.total_committed = 0

    def set(self, doc_ref, data):
        self.batch.set(doc_ref, data)
        self.count += 1
        if self.count >= 400:  # Commit when reaching 400 to be safe
            self.commit()

    def commit(self):
        if self.count > 0:
            print(f"  Committing batch of {self.count} documents to Firestore...")
            self.batch.commit()
            self.total_committed += self.count
            self.batch = self.db.batch()
            self.count = 0

# 3. Load Datasets
print("\nLoading datasets from JSON...")
with open(USERS_JSON_FILE, 'r', encoding='utf-8') as f:
    users_data = json.load(f)
with open(TRIPS_JSON_FILE, 'r', encoding='utf-8') as f:
    trips_data = json.load(f)

writer = BatchWriter(db)

# 4. Import Users Collection
print("\n--- Phase 1: Importing Users ---")
for idx, user in enumerate(users_data):
    uid = user["uid"]
    doc_ref = db.collection("users").document(uid)
    
    # Preprocess date fields to native datetimes (which Firestore converts to Timestamps)
    user_doc = user.copy()
    user_doc["dateOfBirth"] = parse_date(user.get("dateOfBirth"), is_dob=True)
    user_doc["createdAt"] = parse_date(user.get("createdAt"))
    
    writer.set(doc_ref, user_doc)

writer.commit()
print(f"Uploaded {len(users_data)} user accounts successfully.")

# 5. Import Trips & Subcollections (Expenses)
print("\n--- Phase 2: Importing Trips & Expenses ---")
uploaded_trips = 0
uploaded_expenses = 0

for trip in trips_data:
    travel_id = trip["travelId"]
    doc_ref = db.collection("trips").document(travel_id)
    
    # Preprocess date fields
    trip_doc = trip.copy()
    trip_doc["createdAt"] = parse_date(trip.get("createdAt"))
    trip_doc["updatedAt"] = parse_date(trip.get("updatedAt"))
    trip_doc["visitedAt"] = parse_date(trip.get("visitedAt"))
    
    # Firestore supports Date objects for start/end dates beautifully
    trip_doc["startDate"] = parse_date(trip.get("startDate"), is_dob=True)
    trip_doc["endDate"] = parse_date(trip.get("endDate"), is_dob=True)
    
    # Extract embedded expenses and remove from the parent trip document
    expenses = trip_doc.pop("expenses", [])
    
    writer.set(doc_ref, trip_doc)
    uploaded_trips += 1
    
    # Upload child expenses as a subcollection: trips/{tripId}/expenses/{expenseId}
    for expense in expenses:
        expense_id = expense["id"]
        expense_ref = doc_ref.collection("expenses").document(expense_id)
        
        expense_doc = expense.copy()
        expense_doc["date"] = parse_date(expense.get("date"))
        
        writer.set(expense_ref, expense_doc)
        uploaded_expenses += 1

writer.commit()
print(f"Uploaded {uploaded_trips} trips successfully.")
print(f"Uploaded {uploaded_expenses} lồng (subcollection) expenses successfully.")

print("\n========================================")
print(f"SUCCESS! All done. Total documents written: {writer.total_committed}")
print("Your Firebase Firestore has been successfully seeded with realistic travel datasets!")
print("========================================")
