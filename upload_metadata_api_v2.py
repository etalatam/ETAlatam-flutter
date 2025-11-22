#!/usr/bin/env python3
"""
Upload App Store Connect Metadata using API V2
Uses appStoreVersions and appStoreVersionLocalizations endpoints
Works with Team Keys
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

    if not os.path.exists(KEY_FILE):
        print_error(f"No se encuentra el archivo: {KEY_FILE}")
        return None

    with open(KEY_FILE, 'r') as f:
        private_key = f.read()

    expiration_time = datetime.now() + timedelta(minutes=19)

    headers = {
        "alg": "ES256",
        "kid": KEY_ID,
        "typ": "JWT"
    }

    payload = {
        "iss": ISSUER_ID,
        "iat": int(time.time()),
        "exp": int(expiration_time.timestamp()),
        "aud": "appstoreconnect-v1"
    }

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

        if response.status_code >= 400:
            print_error(f"Error {response.status_code}: {response.text}")

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
        return None

    data = response.json()

    if not data.get('data') or len(data['data']) == 0:
        print_error("No se encontró la app en App Store Connect")
        return None

    app_id = data['data'][0]['id']
    app_name = data['data'][0]['attributes']['name']

    print_success(f"App encontrada: {app_name} (ID: {app_id})")
    return app_id

def get_app_store_versions(token, app_id):
    """Get all app store versions for the app"""
    print_info("Obteniendo versiones de la app...")

    endpoint = f"/apps/{app_id}/appStoreVersions?filter[platform]=IOS&filter[appStoreState]=PREPARE_FOR_SUBMISSION,READY_FOR_REVIEW,WAITING_FOR_REVIEW,IN_REVIEW,DEVELOPER_REJECTED,REJECTED,PENDING_DEVELOPER_RELEASE,PENDING_APPLE_RELEASE"
    response = make_api_request(endpoint, token)

    if not response or response.status_code != 200:
        # Try to get any version
        endpoint = f"/apps/{app_id}/appStoreVersions?filter[platform]=IOS"
        response = make_api_request(endpoint, token)

    if not response or response.status_code != 200:
        return None

    data = response.json()

    if not data.get('data') or len(data['data']) == 0:
        print_warning("No se encontraron versiones de la app")
        print_info("Necesitas crear una versión primero en App Store Connect")
        return None

    # Get the most recent version
    version = data['data'][0]
    version_id = version['id']
    version_string = version['attributes']['versionString']

    print_success(f"Versión encontrada: {version_string} (ID: {version_id})")
    return version_id

def get_version_localizations(token, version_id):
    """Get existing localizations for a version"""
    print_info("Obteniendo localizaciones de la versión...")

    endpoint = f"/appStoreVersions/{version_id}/appStoreVersionLocalizations"
    response = make_api_request(endpoint, token)

    if not response or response.status_code != 200:
        return {}

    data = response.json()
    localizations = {}

    for loc in data.get('data', []):
        locale = loc['attributes']['locale']
        loc_id = loc['id']
        localizations[locale] = loc_id

    print_info(f"Localizaciones existentes: {', '.join(localizations.keys())}")
    return localizations

def create_localization(token, version_id, locale):
    """Create a new localization for a version"""
    print_info(f"Creando localización para: {locale}...")

    endpoint = "/appStoreVersionLocalizations"
    payload = {
        "data": {
            "type": "appStoreVersionLocalizations",
            "attributes": {
                "locale": locale
            },
            "relationships": {
                "appStoreVersion": {
                    "data": {
                        "type": "appStoreVersions",
                        "id": version_id
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

def update_localization(token, localization_id, metadata):
    """Update localization with metadata"""
    endpoint = f"/appStoreVersionLocalizations/{localization_id}"

    payload = {
        "data": {
            "type": "appStoreVersionLocalizations",
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

def upload_metadata_for_locale(token, version_id, localizations, locale, locale_name):
    """Upload all metadata for a specific locale"""
    print_info(f"\n{'='*60}")
    print_info(f"Subiendo metadatos para: {locale_name} ({locale})")
    print_info(f"{'='*60}\n")

    # Get or create localization
    localization_id = localizations.get(locale)

    if not localization_id:
        localization_id = create_localization(token, version_id, locale)

    if not localization_id:
        print_error(f"No se pudo obtener/crear localización para {locale}")
        return False

    # Read metadata files
    description = read_metadata_file(locale, "description.txt")
    keywords = read_metadata_file(locale, "keywords.txt")
    marketing_url = read_metadata_file(locale, "marketing_url.txt")
    support_url = read_metadata_file(locale, "support_url.txt")
    promotional_text = read_metadata_file(locale, "subtitle.txt")  # Using subtitle as promotional text

    # Prepare metadata
    metadata = {}

    if description:
        metadata["description"] = description
        print_info(f"  • Description: {len(description)} caracteres")

    if keywords:
        metadata["keywords"] = keywords
        print_info(f"  • Keywords: {keywords}")

    if marketing_url:
        metadata["marketingUrl"] = marketing_url
        print_info(f"  • Marketing URL: {marketing_url}")

    if support_url:
        metadata["supportUrl"] = support_url
        print_info(f"  • Support URL: {support_url}")

    if promotional_text:
        metadata["promotionalText"] = promotional_text
        print_info(f"  • Promotional Text: {promotional_text}")

    # Note: whatsNew cannot be edited when app is not in editable state
    # It will be added in a future update when creating a new version

    if not metadata:
        print_warning(f"No hay metadatos para subir en {locale}")
        return False

    # Update localization
    print_info(f"Actualizando metadatos en App Store Connect...")

    if update_localization(token, localization_id, metadata):
        print_success(f"✅ Metadatos actualizados para {locale_name}")
        return True
    else:
        print_error(f"Error al actualizar metadatos para {locale}")
        return False

def main():
    print(f"\n{Colors.BLUE}{'='*60}")
    print("  Upload Metadata to App Store Connect V2")
    print("  ETA School Transport - Using appStoreVersions")
    print(f"{'='*60}{Colors.NC}\n")

    # Generate JWT token
    token = generate_jwt_token()
    if not token:
        return 1

    # Get App ID
    app_id = get_app_id(token)
    if not app_id:
        return 1

    # Get App Store Version
    version_id = get_app_store_versions(token, app_id)
    if not version_id:
        print_error("No se pudo obtener la versión de la app")
        print_warning("Crea una nueva versión en App Store Connect primero")
        return 1

    # Get existing localizations
    localizations = get_version_localizations(token, version_id)

    # Upload metadata for Spanish
    success_es = upload_metadata_for_locale(token, version_id, localizations, "es-ES", "Español (España)")

    # Upload metadata for English
    success_en = upload_metadata_for_locale(token, version_id, localizations, "en-US", "English (US)")

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
    elif success_es or success_en:
        print(f"\n{Colors.YELLOW}{'='*60}")
        print("  ⚠️  ALGUNOS METADATOS SE SUBIERON")
        print(f"{'='*60}{Colors.NC}\n")
        return 0
    else:
        print(f"\n{Colors.RED}{'='*60}")
        print("  ❌ NO SE PUDIERON SUBIR METADATOS")
        print(f"{'='*60}{Colors.NC}\n")
        return 1

if __name__ == "__main__":
    exit(main())
