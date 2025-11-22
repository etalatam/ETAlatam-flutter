#!/usr/bin/env python3
"""
Upload App Store Connect Metadata using API
Works on Linux without Fastlane
"""

import jwt
import time
import json
import os
from datetime import datetime, timedelta
from pathlib import Path
import requests

# Configuration from .env.appstore
KEY_ID = "2A6UCBGW5Z"
ISSUER_ID = "633d3064-8dbd-412b-aa53-2c4aa211c354"
BUNDLE_ID = "com.etalatam.schoolapp"
KEY_FILE = "AuthKey_2A6UCBGW5Z.p8"

# API Base URL
API_BASE = "https://api.appstoreconnect.apple.com/v1"

class Colors:
    BLUE = '\033[0;34m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    RED = '\033[0;31m'
    NC = '\033[0m'

def print_success(msg):
    print(f"{Colors.GREEN}✅ {msg}{Colors.NC}")

def print_info(msg):
    print(f"{Colors.BLUE}ℹ️  {msg}{Colors.NC}")

def print_warning(msg):
    print(f"{Colors.YELLOW}⚠️  {msg}{Colors.NC}")

def print_error(msg):
    print(f"{Colors.RED}❌ {msg}{Colors.NC}")

def generate_jwt_token():
    """Generate JWT token for App Store Connect API"""
    print_info("Generando JWT token...")

    # Read private key
    if not os.path.exists(KEY_FILE):
        print_error(f"No se encuentra el archivo: {KEY_FILE}")
        return None

    with open(KEY_FILE, 'r') as f:
        private_key = f.read()

    # Token expires in 20 minutes (maximum allowed)
    expiration_time = datetime.now() + timedelta(minutes=19)

    # JWT headers
    headers = {
        "alg": "ES256",
        "kid": KEY_ID,
        "typ": "JWT"
    }

    # JWT payload
    payload = {
        "iss": ISSUER_ID,
        "iat": int(time.time()),
        "exp": int(expiration_time.timestamp()),
        "aud": "appstoreconnect-v1"
    }

    # Generate token
    token = jwt.encode(payload, private_key, algorithm="ES256", headers=headers)

    print_success("Token JWT generado correctamente")
    return token

def make_api_request(endpoint, token, method="GET", data=None):
    """Make request to App Store Connect API"""
    url = f"{API_BASE}{endpoint}"

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

    try:
        if method == "GET":
            response = requests.get(url, headers=headers, timeout=30)
        elif method == "POST":
            response = requests.post(url, headers=headers, json=data, timeout=30)
        elif method == "PATCH":
            response = requests.patch(url, headers=headers, json=data, timeout=30)

        # Debug: print response details
        print_info(f"Request: {method} {url}")
        print_info(f"Status: {response.status_code}")
        if response.status_code >= 400:
            print_error(f"Response: {response.text}")

        return response
    except Exception as e:
        print_error(f"Error en request API: {str(e)}")
        return None

def get_app_id(token):
    """Get App ID from Bundle ID"""
    print_info(f"Buscando app con Bundle ID: {BUNDLE_ID}...")

    endpoint = f"/apps?filter[bundleId]={BUNDLE_ID}"
    response = make_api_request(endpoint, token)

    if not response or response.status_code != 200:
        print_error(f"Error al buscar app: {response.status_code if response else 'No response'}")
        if response:
            print_error(f"Respuesta: {response.text}")
        return None

    data = response.json()

    if not data.get('data') or len(data['data']) == 0:
        print_error("No se encontró la app en App Store Connect")
        print_warning("Asegúrate de que la app existe en https://appstoreconnect.apple.com")
        return None

    app_id = data['data'][0]['id']
    app_name = data['data'][0]['attributes']['name']

    print_success(f"App encontrada: {app_name} (ID: {app_id})")
    return app_id

def get_app_info_localization(token, app_id, locale):
    """Get app info localization for a specific locale"""
    print_info(f"Obteniendo localización para: {locale}...")

    endpoint = f"/appInfos?filter[app]={app_id}"
    response = make_api_request(endpoint, token)

    if not response or response.status_code != 200:
        print_error(f"Error al obtener app info: {response.status_code if response else 'No response'}")
        return None

    data = response.json()

    if not data.get('data') or len(data['data']) == 0:
        print_error("No se encontró información de la app")
        return None

    app_info_id = data['data'][0]['id']

    # Get localizations
    endpoint = f"/appInfoLocalizations?filter[appInfo]={app_info_id}&filter[locale]={locale}"
    response = make_api_request(endpoint, token)

    if not response or response.status_code != 200:
        return None

    data = response.json()

    if data.get('data') and len(data['data']) > 0:
        return data['data'][0]['id']

    return None

def create_app_info_localization(token, app_id, locale):
    """Create a new app info localization"""
    print_info(f"Creando localización para: {locale}...")

    # First get app info ID
    endpoint = f"/appInfos?filter[app]={app_id}"
    response = make_api_request(endpoint, token)

    if not response or response.status_code != 200:
        return None

    data = response.json()
    app_info_id = data['data'][0]['id']

    # Create localization
    endpoint = "/appInfoLocalizations"
    payload = {
        "data": {
            "type": "appInfoLocalizations",
            "attributes": {
                "locale": locale
            },
            "relationships": {
                "appInfo": {
                    "data": {
                        "type": "appInfos",
                        "id": app_info_id
                    }
                }
            }
        }
    }

    response = make_api_request(endpoint, token, method="POST", data=payload)

    if response and response.status_code == 201:
        localization_id = response.json()['data']['id']
        print_success(f"Localización creada: {locale}")
        return localization_id

    return None

def update_app_info_localization(token, localization_id, metadata):
    """Update app info localization with metadata"""
    endpoint = f"/appInfoLocalizations/{localization_id}"

    payload = {
        "data": {
            "type": "appInfoLocalizations",
            "id": localization_id,
            "attributes": metadata
        }
    }

    response = make_api_request(endpoint, token, method="PATCH", data=payload)

    return response and response.status_code == 200

def read_metadata_file(locale, filename):
    """Read metadata from file"""
    filepath = f"ios/fastlane/metadata/{locale}/{filename}"

    if not os.path.exists(filepath):
        return None

    with open(filepath, 'r', encoding='utf-8') as f:
        return f.read().strip()

def upload_metadata_for_locale(token, app_id, locale, locale_name):
    """Upload all metadata for a specific locale"""
    print_info(f"\n{'='*60}")
    print_info(f"Subiendo metadatos para: {locale_name} ({locale})")
    print_info(f"{'='*60}\n")

    # Get or create localization
    localization_id = get_app_info_localization(token, app_id, locale)

    if not localization_id:
        localization_id = create_app_info_localization(token, app_id, locale)

    if not localization_id:
        print_error(f"No se pudo obtener/crear localización para {locale}")
        return False

    # Read metadata files
    name = read_metadata_file(locale, "name.txt")
    subtitle = read_metadata_file(locale, "subtitle.txt")
    privacy_policy_url = read_metadata_file(locale, "privacy_url.txt")
    privacy_policy_text = read_metadata_file(locale, "description.txt")  # Using description as privacy text for now

    # Prepare metadata
    metadata = {}

    if name:
        metadata["name"] = name
        print_info(f"  • Name: {name}")

    if subtitle:
        metadata["subtitle"] = subtitle
        print_info(f"  • Subtitle: {subtitle}")

    if privacy_policy_url:
        metadata["privacyPolicyUrl"] = privacy_policy_url
        print_info(f"  • Privacy URL: {privacy_policy_url}")

    if not metadata:
        print_warning(f"No hay metadatos para subir en {locale}")
        return False

    # Update localization
    print_info(f"Actualizando metadatos en App Store Connect...")

    if update_app_info_localization(token, localization_id, metadata):
        print_success(f"✅ Metadatos actualizados para {locale_name}")
        return True
    else:
        print_error(f"Error al actualizar metadatos para {locale}")
        return False

def main():
    print(f"\n{Colors.BLUE}{'='*60}")
    print("  Upload Metadata to App Store Connect")
    print("  ETA School Transport - Metadata Only")
    print(f"{'='*60}{Colors.NC}\n")

    # Generate JWT token
    token = generate_jwt_token()
    if not token:
        print_error("No se pudo generar el token JWT")
        return 1

    # Get App ID
    app_id = get_app_id(token)
    if not app_id:
        print_error("No se pudo obtener el ID de la app")
        return 1

    # Upload metadata for Spanish
    success_es = upload_metadata_for_locale(token, app_id, "es-ES", "Español (España)")

    # Upload metadata for English
    success_en = upload_metadata_for_locale(token, app_id, "en-US", "English (US)")

    # Summary
    print(f"\n{Colors.BLUE}{'='*60}")
    print("  RESUMEN")
    print(f"{'='*60}{Colors.NC}\n")

    if success_es:
        print_success("Español: Metadatos subidos correctamente")
    else:
        print_error("Español: Error al subir metadatos")

    if success_en:
        print_success("English: Metadata uploaded successfully")
    else:
        print_error("English: Error uploading metadata")

    if success_es and success_en:
        print(f"\n{Colors.GREEN}{'='*60}")
        print("  ✅ TODOS LOS METADATOS SUBIDOS CORRECTAMENTE")
        print(f"{'='*60}{Colors.NC}\n")
        print_info("Verifica en: https://appstoreconnect.apple.com")
        return 0
    else:
        print(f"\n{Colors.YELLOW}{'='*60}")
        print("  ⚠️  ALGUNOS METADATOS NO SE PUDIERON SUBIR")
        print(f"{'='*60}{Colors.NC}\n")
        return 1

if __name__ == "__main__":
    exit(main())
