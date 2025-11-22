#!/usr/bin/env python3
"""
Check app-level information and available localizations
"""

import jwt
import time
from datetime import datetime, timedelta
import requests
import json

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
app_id = "6755067314"

headers = {
    "Authorization": f"Bearer {token}",
    "Content-Type": "application/json"
}

print("\n" + "="*60)
print("INFORMACIÓN DE LA APP")
print("="*60 + "\n")

# Get app details
url = f"{API_BASE}/apps/{app_id}"
response = requests.get(url, headers=headers)
app_data = response.json()

if 'data' in app_data:
    attrs = app_data['data']['attributes']
    print(f"Nombre: {attrs.get('name')}")
    print(f"Bundle ID: {attrs.get('bundleId')}")
    print(f"SKU: {attrs.get('sku')}")
    print(f"Primary Locale: {attrs.get('primaryLocale')}")

print("\n" + "="*60)
print("INTENTANDO OBTENER INFORMACIÓN ADICIONAL")
print("="*60 + "\n")

# Try to get app info (this might fail with 403 as we saw before)
# But let's try with a direct GET instead of GET_COLLECTION
url = f"{API_BASE}/apps/{app_id}/appInfos"
response = requests.get(url, headers=headers)

if response.status_code == 200:
    data = response.json()
    if 'data' in data and len(data['data']) > 0:
        app_info_id = data['data'][0]['id']
        print(f"App Info ID: {app_info_id}")

        # Get app info localizations
        url = f"{API_BASE}/appInfos/{app_info_id}/appInfoLocalizations"
        response = requests.get(url, headers=headers)

        if response.status_code == 200:
            data = response.json()
            print("\nLocalizaciones a nivel de App Info:")
            for loc in data.get('data', []):
                locale = loc['attributes']['locale']
                name = loc['attributes'].get('name', 'N/A')
                print(f"  - {locale}: {name}")
else:
    print(f"No se pudo obtener App Info: {response.status_code}")
    print(f"Respuesta: {response.text[:200]}")
