from google.cloud import firestore
import firebase_admin
from firebase_admin import credentials
# Initialize Firestore client
db = firestore.Client()
print('test')
# Example: Fetch all documents from a collection
docs = db.collection('Locations').stream()
for doc in docs:
    print(f'{doc.id}: {doc.to_dict()}')
    break
