import json

# Load the JSON file
with open("locations.json", "r") as file:
    locations = json.load(file)

for location in locations:
    location['objectID'] = location['business_id']

# Save the updated JSON to a new file
with open("updated_locations.json", "w") as file:
    json.dump(locations, file, indent=4)

print("New JSON with additional attributes has been created as 'updated_users.json'.")
