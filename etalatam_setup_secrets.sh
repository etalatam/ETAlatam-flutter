#!/bin/bash

# ============================================================================
# ETAlatam Flutter - GitHub Secrets Configuration Script
# Project: ETAlatam School Transport Tracking System
# Author: ETAlatam DevOps Team
# Date: $(date +%Y-%m-%d)
# ============================================================================

set -e  # Exit on error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Configuración del repositorio ETAlatam
REPO_OWNER="etalatam"  # Cambiar según tu organización
REPO_NAME="ETAlatam-flutter"
GITHUB_API="https://api.github.com"

# Banner ETAlatam
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                                ║${NC}"
echo -e "${BLUE}║     ${CYAN}🚌 ETAlatam School Transport Tracking System 🚌${BLUE}           ║${NC}"
echo -e "${BLUE}║           ${MAGENTA}GitHub Secrets Configuration Tool${BLUE}                   ║${NC}"
echo -e "${BLUE}║                                                                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Función para verificar prerrequisitos
check_prerequisites() {
    echo -e "${CYAN}🔍 Verificando prerrequisitos para ETAlatam...${NC}"
    echo ""

    # Verificar Python3
    if ! command -v python3 &> /dev/null; then
        echo -e "${YELLOW}⚠️  Python3 no instalado. Instalando...${NC}"
        sudo apt-get update && sudo apt-get install -y python3 python3-pip
    else
        echo -e "${GREEN}✅ Python3 instalado${NC}"
    fi

    # Verificar PyNaCl para encriptación
    if ! python3 -c "import nacl" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Instalando PyNaCl para encriptación...${NC}"
        pip3 install --user --break-system-packages pynacl 2>/dev/null || pip3 install --user pynacl
    else
        echo -e "${GREEN}✅ PyNaCl instalado${NC}"
    fi

    # Verificar git
    if ! command -v git &> /dev/null; then
        echo -e "${RED}❌ Git no está instalado${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ Git instalado${NC}"
    fi

    # Verificar jq para JSON parsing (opcional pero útil)
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}⚠️  jq no instalado (opcional). Instalar con: sudo apt install jq${NC}"
    else
        echo -e "${GREEN}✅ jq instalado${NC}"
    fi

    echo ""
}

# Función para obtener el token de GitHub
get_github_token() {
    echo -e "${CYAN}🔑 Obteniendo token de GitHub para ETAlatam...${NC}"

    # Intentar obtener de pass
    if command -v pass &> /dev/null && pass show etalatam/github/token &> /dev/null 2>&1; then
        GITHUB_TOKEN=$(pass show etalatam/github/token | head -1)
        echo -e "${GREEN}✅ Token obtenido desde pass${NC}"
    # Intentar variable de entorno
    elif [ -n "$ETALATAM_GITHUB_TOKEN" ]; then
        GITHUB_TOKEN="$ETALATAM_GITHUB_TOKEN"
        echo -e "${GREEN}✅ Token obtenido de variable ETALATAM_GITHUB_TOKEN${NC}"
    elif [ -n "$GITHUB_TOKEN" ]; then
        echo -e "${GREEN}✅ Token obtenido de variable GITHUB_TOKEN${NC}"
    else
        # Solicitar token al usuario
        echo -e "${YELLOW}No se encontró token automáticamente.${NC}"
        echo -e "${CYAN}Por favor ingrese su GitHub Personal Access Token:${NC}"
        echo -e "${CYAN}(Necesita permisos: repo, workflow)${NC}"
        read -s -p "Token: " GITHUB_TOKEN
        echo ""
    fi

    if [ -z "$GITHUB_TOKEN" ]; then
        echo -e "${RED}❌ No se pudo obtener el token de GitHub${NC}"
        exit 1
    fi
}

# Función para obtener la clave pública del repositorio
get_repo_public_key() {
    local response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "$GITHUB_API/repos/$REPO_OWNER/$REPO_NAME/actions/secrets/public-key")

    if [[ $response == *"key_id"* ]]; then
        echo "$response"
    else
        echo -e "${RED}❌ Error obteniendo clave pública del repositorio ETAlatam${NC}"
        echo -e "${YELLOW}Respuesta: $response${NC}"
        return 1
    fi
}

# Función para encriptar un secret
encrypt_secret() {
    local secret_value="$1"
    local public_key="$2"

    python3 -c "
import base64
from nacl import encoding, public

def encrypt(public_key: str, secret_value: str) -> str:
    public_key = public.PublicKey(public_key.encode('utf-8'), encoding.Base64Encoder())
    sealed_box = public.SealedBox(public_key)
    encrypted = sealed_box.encrypt(secret_value.encode('utf-8'))
    return base64.b64encode(encrypted).decode('utf-8')

print(encrypt('$public_key', '''$secret_value'''))
" 2>/dev/null || echo ""
}

# Función para configurar un secret
configure_secret() {
    local secret_name=$1
    local secret_value=$2
    local description=$3

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}📝 Configurando: ${secret_name}${NC}"
    echo -e "   ${description}"

    # Obtener clave pública
    local key_data=$(get_repo_public_key)
    if [ $? -ne 0 ]; then
        return 1
    fi

    local key_id=$(echo "$key_data" | python3 -c "import sys, json; print(json.load(sys.stdin)['key_id'])" 2>/dev/null)
    local public_key=$(echo "$key_data" | python3 -c "import sys, json; print(json.load(sys.stdin)['key'])" 2>/dev/null)

    if [ -z "$key_id" ] || [ -z "$public_key" ]; then
        echo -e "${RED}   ❌ Error obteniendo clave pública${NC}"
        return 1
    fi

    # Encriptar el secret
    local encrypted_value=$(encrypt_secret "$secret_value" "$public_key")

    if [ -z "$encrypted_value" ]; then
        echo -e "${RED}   ❌ Error encriptando secret${NC}"
        return 1
    fi

    # Enviar secret encriptado
    local response=$(curl -s -X PUT \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "$GITHUB_API/repos/$REPO_OWNER/$REPO_NAME/actions/secrets/$secret_name" \
        -d "{\"encrypted_value\":\"$encrypted_value\",\"key_id\":\"$key_id\"}" 2>&1)

    if [[ $response == "" ]] || [[ $response == *"204"* ]]; then
        echo -e "${GREEN}   ✅ Configurado exitosamente${NC}"
        return 0
    else
        echo -e "${RED}   ❌ Error al configurar${NC}"
        echo -e "${YELLOW}   Respuesta: $response${NC}"
        return 1
    fi
}

# Función principal de configuración
main() {
    check_prerequisites
    get_github_token

    echo ""
    echo -e "${BLUE}=== Configuración de Secrets para ETAlatam ===${NC}"
    echo ""

    # Verificar archivos necesarios para iOS
    echo -e "${CYAN}📁 Verificando archivos de certificados...${NC}"
    echo ""

    IOS_CERT_EXISTS=false
    IOS_PROFILE_EXISTS=false
    ANDROID_KEYSTORE_EXISTS=false

    if [ -f "ios/certificates/etalatam_distribution.p12" ]; then
        echo -e "${GREEN}✅ Certificado iOS encontrado${NC}"
        IOS_CERT_EXISTS=true
    else
        echo -e "${YELLOW}⚠️  Certificado iOS no encontrado (ios/certificates/etalatam_distribution.p12)${NC}"
    fi

    if [ -f "ios/certificates/etalatam.mobileprovision" ]; then
        echo -e "${GREEN}✅ Perfil de aprovisionamiento encontrado${NC}"
        IOS_PROFILE_EXISTS=true
    else
        echo -e "${YELLOW}⚠️  Perfil de aprovisionamiento no encontrado (ios/certificates/etalatam.mobileprovision)${NC}"
    fi

    if [ -f "android/app/etalatam-keystore.jks" ]; then
        echo -e "${GREEN}✅ Keystore Android encontrado${NC}"
        ANDROID_KEYSTORE_EXISTS=true
    else
        echo -e "${YELLOW}⚠️  Keystore Android no encontrado (android/app/etalatam-keystore.jks)${NC}"
    fi

    echo ""
    echo -e "${BLUE}=== Configurando Secrets de Android para ETAlatam ===${NC}"
    echo ""

    if [ "$ANDROID_KEYSTORE_EXISTS" = true ]; then
        echo -e "${YELLOW}🔄 Codificando keystore ETAlatam a base64...${NC}"
        KEYSTORE_BASE64=$(base64 -w 0 android/app/etalatam-keystore.jks)
        configure_secret "ETALATAM_ANDROID_KEYSTORE_BASE64" "$KEYSTORE_BASE64" "Keystore Android de ETAlatam (base64)"

        # Solicitar passwords si no están en variables de entorno
        if [ -z "$ETALATAM_KEYSTORE_PASSWORD" ]; then
            read -s -p "Ingrese el password del keystore ETAlatam: " ETALATAM_KEYSTORE_PASSWORD
            echo ""
        fi
        configure_secret "ETALATAM_ANDROID_KEYSTORE_PASSWORD" "$ETALATAM_KEYSTORE_PASSWORD" "Password del Keystore ETAlatam"

        if [ -z "$ETALATAM_KEY_PASSWORD" ]; then
            read -s -p "Ingrese el password de la llave: " ETALATAM_KEY_PASSWORD
            echo ""
        fi
        configure_secret "ETALATAM_ANDROID_KEY_PASSWORD" "$ETALATAM_KEY_PASSWORD" "Password de la llave ETAlatam"

        if [ -z "$ETALATAM_KEY_ALIAS" ]; then
            read -p "Ingrese el alias de la llave (default: etalatam): " ETALATAM_KEY_ALIAS
            ETALATAM_KEY_ALIAS=${ETALATAM_KEY_ALIAS:-etalatam}
        fi
        configure_secret "ETALATAM_ANDROID_KEY_ALIAS" "$ETALATAM_KEY_ALIAS" "Alias de la llave ETAlatam"
    else
        echo -e "${YELLOW}⚠️  Saltando configuración de Android (keystore no encontrado)${NC}"
    fi

    echo ""
    echo -e "${BLUE}=== Configurando Secrets de iOS para ETAlatam ===${NC}"
    echo ""

    if [ "$IOS_CERT_EXISTS" = true ]; then
        echo -e "${YELLOW}🔄 Codificando certificado iOS ETAlatam a base64...${NC}"
        CERT_BASE64=$(base64 -w 0 ios/certificates/etalatam_distribution.p12)
        configure_secret "ETALATAM_IOS_BUILD_CERTIFICATE_BASE64" "$CERT_BASE64" "Certificado iOS ETAlatam (P12 en base64)"

        if [ -z "$ETALATAM_CERT_PASSWORD" ]; then
            read -s -p "Ingrese el password del certificado P12: " ETALATAM_CERT_PASSWORD
            echo ""
        fi
        configure_secret "ETALATAM_IOS_BUILD_CERTIFICATE_PASSWORD" "$ETALATAM_CERT_PASSWORD" "Password del certificado ETAlatam"
    fi

    if [ "$IOS_PROFILE_EXISTS" = true ]; then
        echo -e "${YELLOW}🔄 Codificando perfil de aprovisionamiento ETAlatam...${NC}"
        PROFILE_BASE64=$(base64 -w 0 ios/certificates/etalatam.mobileprovision)
        configure_secret "ETALATAM_IOS_MOBILE_PROVISIONING_PROFILE_BASE64" "$PROFILE_BASE64" "Perfil de aprovisionamiento ETAlatam"
    fi

    # Keychain password (puede ser cualquier string)
    configure_secret "ETALATAM_IOS_GITHUB_KEYCHAIN_PASSWORD" "etalatam-ci-2024" "Password temporal para keychain ETAlatam"

    echo ""
    echo -e "${BLUE}=== Configurando App Store Connect para ETAlatam ===${NC}"
    echo ""

    # Solicitar credenciales de App Store Connect
    if [ -z "$ETALATAM_APP_STORE_KEY_ID" ]; then
        echo -e "${CYAN}Ingrese el App Store Connect API Key ID para ETAlatam:${NC}"
        read -p "Key ID: " ETALATAM_APP_STORE_KEY_ID
    fi
    configure_secret "ETALATAM_APP_STORE_CONNECT_API_KEY_ID" "$ETALATAM_APP_STORE_KEY_ID" "App Store Connect API Key ID"

    if [ -z "$ETALATAM_APP_STORE_ISSUER_ID" ]; then
        echo -e "${CYAN}Ingrese el App Store Connect Issuer ID:${NC}"
        read -p "Issuer ID: " ETALATAM_APP_STORE_ISSUER_ID
    fi
    configure_secret "ETALATAM_APP_STORE_CONNECT_API_ISSUER_ID" "$ETALATAM_APP_STORE_ISSUER_ID" "App Store Connect Issuer ID"

    if [ -z "$ETALATAM_APPLE_TEAM_ID" ]; then
        echo -e "${CYAN}Ingrese el Apple Team ID (ej: 494S8338AJ):${NC}"
        read -p "Team ID: " ETALATAM_APPLE_TEAM_ID
    fi
    configure_secret "ETALATAM_APPLE_TEAM_ID" "$ETALATAM_APPLE_TEAM_ID" "Apple Team ID de ETAlatam"

    # API Key content (archivo .p8)
    if [ -f "ios/certificates/AuthKey_ETAlatam.p8" ]; then
        echo -e "${GREEN}✅ Archivo de API Key encontrado${NC}"
        API_KEY_CONTENT=$(cat ios/certificates/AuthKey_ETAlatam.p8)
        configure_secret "ETALATAM_APP_STORE_CONNECT_API_KEY_CONTENT" "$API_KEY_CONTENT" "App Store Connect API Key (.p8)"
    else
        echo -e "${YELLOW}⚠️  Archivo de API Key no encontrado (ios/certificates/AuthKey_ETAlatam.p8)${NC}"
        echo -e "${CYAN}Pegue el contenido del archivo .p8 (Ctrl+D cuando termine):${NC}"
        API_KEY_CONTENT=$(cat)
        if [ ! -z "$API_KEY_CONTENT" ]; then
            configure_secret "ETALATAM_APP_STORE_CONNECT_API_KEY_CONTENT" "$API_KEY_CONTENT" "App Store Connect API Key (.p8)"
        fi
    fi

    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           📊 Resumen de Configuración ETAlatam                ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Verificar secrets configurados
    echo -e "${CYAN}Verificando secrets en el repositorio ETAlatam...${NC}"
    curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "$GITHUB_API/repos/$REPO_OWNER/$REPO_NAME/actions/secrets" | \
        python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if 'secrets' in data:
        secrets = data['secrets']
        print(f'Total secrets configurados: {len(secrets)}')
        print('')
        etalatam_secrets = [s for s in secrets if 'ETALATAM' in s['name']]
        other_secrets = [s for s in secrets if 'ETALATAM' not in s['name']]

        if etalatam_secrets:
            print('Secrets ETAlatam:')
            for secret in etalatam_secrets:
                print(f'  ✅ {secret[\"name\"]}')

        if other_secrets:
            print('\nOtros secrets:')
            for secret in other_secrets:
                print(f'  ℹ️  {secret[\"name\"]}')
except:
    print('Error obteniendo lista de secrets')
" 2>/dev/null || echo "Error listando secrets"

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║        ✅ Configuración ETAlatam Completada ✅                 ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}🚌 Sistema ETAlatam de Seguimiento de Transporte Escolar${NC}"
    echo ""
    echo -e "${MAGENTA}📱 Próximos pasos:${NC}"
    echo ""
    echo "1. Verificar workflows en:"
    echo "   ${BLUE}https://github.com/$REPO_OWNER/$REPO_NAME/actions${NC}"
    echo ""
    echo "2. Para probar Android CI/CD:"
    echo "   ${YELLOW}git add . && git commit -m 'Test ETAlatam CI/CD' && git push${NC}"
    echo ""
    echo "3. Para iOS CI/CD:"
    echo "   - Configurar runner self-hosted macOS"
    echo "   - O usar GitHub-hosted runner (requiere plan de pago)"
    echo ""
    echo "4. Ver documentación:"
    echo "   ${BLUE}cat ETALATAM_CI_CD_GUIDE.md${NC}"
    echo ""
    echo -e "${GREEN}💡 Los pipelines de ETAlatam están listos para usar${NC}"
    echo -e "${GREEN}   Android funcionará inmediatamente después del push${NC}"
}

# Ejecutar función principal
main "$@"