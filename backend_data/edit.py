from google.cloud import firestore

# Initialize Firestore client
db = firestore.Client()

def update_user_roles():
    print("Fetching user data...")
    users = db.collection('Users').stream()
    batch = db.batch()
    updates_count = 0

    print("Processing users...")
    for user in users:
        user_ref = db.collection('Users').document(user.id)
        user_data = user.to_dict()

        if 'own' in user_data and isinstance(user_data['own'], list) and len(user_data['own'])>0:
            new_role = 'Business Owner'
        else:
            new_role = 'Traveller'
        if user_data.get('role') != new_role:
            batch.update(user_ref, {'role': new_role})
            updates_count += 1
    if updates_count > 0:
        print(f"Committing updates for {updates_count} users...")
        batch.commit()
        print("User roles updated successfully.")
    else:
        print("No updates were needed.")

update_user_roles()
