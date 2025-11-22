#!/usr/bin/env python3
"""
Check existing localizations in App Store Connect
"""

import jwt
import time
from datetime import datetime, timedelta
import requests

KEY_ID = "2A6UCBGW5Z"
ISSUER_ID = "633d3064-8dbd-412b-aa53-2c4aa211c354"
KEY_FILE = "AuthKey_2A6UCBGW5Z.p8"
API_BASE = "https://api.appstoreconnect.apple.com/v1"

def generate_jwt_token():
    with open(KEY_FILE, 'r') as f:
        private_key = f.read()

    expiration_time = datetime.now() + timedelta(minutes=19)

    headers = {"alg": "ES256", "kid": KEY_ID, "typ": "JWT"}
    payload = {
        "iss": ISSUER_ID,
        "iat": int(time.time()),
        "exp": int(expiration_time.timestamp()),
        "aud": "appstoreconnect-v1"
    }

    return jwt.encode(payload, private_key, algorithm="ES256", headers=headers)

token = generate_jwt_token()

# Get version localizations
version_id = "1939aabc-3f79-4188-a33f-4a9f17d75701"
url = f"{API_BASE}/appStoreVersions/{version_id}/appStoreVersionLocalizations"

headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json"
}

response = requests.get(url, headers=headers)
data = response.json()

print("\nLocalizaciones existentes:\n")
for loc in data.get('data', []):
    locale = loc['attributes']['locale']
    loc_id = loc['id']
    desc = loc['attributes'].get('description', 'N/A')[:50]
    print(f"Locale: {locale}")
    print(f"ID: {loc_id}")
    print(f"Description: {desc}...")
    print("-" * 60)
