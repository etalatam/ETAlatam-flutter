# 🚀 App Store Connect - Guía Rápida / Quick Guide

[🇪🇸 Español](#español) | [🇺🇸 English](#english)

---

## 🇪🇸 Español

### ⚡ Inicio Rápido

#### 1. Ejecuta el script de configuración automática

```bash
./setup_appstore.sh
```

Este script instalará todo lo necesario y te guiará en la configuración.

#### 2. Completa tus credenciales

Edita el archivo `.env.appstore` con tus datos:

```bash
nano .env.appstore
```

Necesitas:
- **APPLE_ID**: Tu email de Apple Developer
- **TEAM_ID**: Encuéntralo en https://developer.apple.com/account (sección Membership)
- **APP_STORE_CONNECT_API_ISSUER_ID**: En App Store Connect > Users and Access > Keys

#### 3. Sube los metadatos

```bash
cd ios
bundle exec fastlane upload_metadata
```

Esto subirá las descripciones en **español** e **inglés** a App Store Connect.

---

### 📂 Archivos Configurados

#### ✅ Metadatos (en Español e Inglés)

Ubicación: `ios/fastlane/metadata/`

**Idiomas configurados:**
- 🇪🇸 Español (España) - `es-ES/`
- 🇺🇸 English (US) - `en-US/`

**Archivos incluidos:**
- `name.txt` - Nombre de la app
- `subtitle.txt` - Subtítulo
- `description.txt` - Descripción completa
- `keywords.txt` - Palabras clave para búsqueda
- `marketing_url.txt` - URL de marketing
- `support_url.txt` - URL de soporte
- `privacy_url.txt` - Política de privacidad
- `release_notes.txt` - Notas de la versión

#### ✅ Configuración de Fastlane

- `ios/Gemfile` - Dependencias de Ruby
- `ios/fastlane/Appfile` - Configuración de la cuenta
- `ios/fastlane/Fastfile` - Comandos automatizados
- `.env.appstore` - Variables de entorno (NO COMMITEAR)

---

### 📸 Capturas de Pantalla

Para agregar screenshots:

1. Crea las carpetas por idioma y tamaño:
```
ios/fastlane/screenshots/
├── es-ES/
│   ├── iPhone 6.5 inch/     (1284 x 2778 px)
│   ├── iPhone 5.5 inch/     (1242 x 2208 px)
│   └── iPad Pro (12.9 inch)/ (2048 x 2732 px)
└── en-US/
    ├── iPhone 6.5 inch/
    ├── iPhone 5.5 inch/
    └── iPad Pro (12.9 inch)/
```

2. Nombra los archivos en orden:
   - `01_screenshot.png`
   - `02_screenshot.png`
   - etc.

3. Sube los screenshots:
```bash
cd ios
bundle exec fastlane upload_screenshots
```

---

### 🔧 Comandos Principales

| Comando | Descripción |
|---------|-------------|
| `fastlane app_info` | Ver info de la app |
| `fastlane upload_metadata` | Subir descripciones |
| `fastlane upload_screenshots` | Subir capturas |
| `fastlane upload_testflight` | Subir a TestFlight |
| `fastlane upload_appstore` | Subir a App Store |
| `fastlane release` | Proceso completo |

**Uso:**
```bash
cd ios
bundle exec fastlane <comando>
```

---

### 📚 Documentación Completa

Para instrucciones detalladas:
- 🇪🇸 **[Español](docs/app-store-setup.md)**
- 🇺🇸 **[English](docs/app-store-setup-en.md)**

---

### 🔐 Seguridad - MUY IMPORTANTE

**⚠️ NUNCA commitees estos archivos a Git:**
- ❌ `.env.appstore`
- ❌ `*.p8`
- ❌ `AuthKey_*.p8`

Estos archivos ya están protegidos en `.gitignore`.

---

### 📊 Información de la App

- **Bundle ID**: `com.etalatam.schoolapp`
- **Nombre**: ETA School Transport
- **Versión actual**: 1.12.38
- **Build**: 38
- **Categoría**: Education (Educación)
- **Clasificación**: 4+

---

### ✅ Checklist antes de publicar

- [ ] Credenciales configuradas en `.env.appstore`
- [ ] Metadatos en español e inglés revisados
- [ ] Screenshots agregados (español e inglés)
- [ ] URLs de soporte y privacidad funcionando
- [ ] App probada en dispositivos reales
- [ ] Versión beta probada en TestFlight

---

## 🇺🇸 English

### ⚡ Quick Start

#### 1. Run the automatic setup script

```bash
./setup_appstore.sh
```

This script will install everything needed and guide you through the setup.

#### 2. Complete your credentials

Edit the `.env.appstore` file with your data:

```bash
nano .env.appstore
```

You need:
- **APPLE_ID**: Your Apple Developer email
- **TEAM_ID**: Find it at https://developer.apple.com/account (Membership section)
- **APP_STORE_CONNECT_API_ISSUER_ID**: In App Store Connect > Users and Access > Keys

#### 3. Upload metadata

```bash
cd ios
bundle exec fastlane upload_metadata
```

This will upload descriptions in **Spanish** and **English** to App Store Connect.

---

### 📂 Configured Files

#### ✅ Metadata (in Spanish and English)

Location: `ios/fastlane/metadata/`

**Configured languages:**
- 🇪🇸 Spanish (Spain) - `es-ES/`
- 🇺🇸 English (US) - `en-US/`

**Included files:**
- `name.txt` - App name
- `subtitle.txt` - Subtitle
- `description.txt` - Full description
- `keywords.txt` - Search keywords
- `marketing_url.txt` - Marketing URL
- `support_url.txt` - Support URL
- `privacy_url.txt` - Privacy policy
- `release_notes.txt` - Version notes

#### ✅ Fastlane Configuration

- `ios/Gemfile` - Ruby dependencies
- `ios/fastlane/Appfile` - Account configuration
- `ios/fastlane/Fastfile` - Automated commands
- `.env.appstore` - Environment variables (DO NOT COMMIT)

---

### 📸 Screenshots

To add screenshots:

1. Create folders by language and size:
```
ios/fastlane/screenshots/
├── es-ES/
│   ├── iPhone 6.5 inch/     (1284 x 2778 px)
│   ├── iPhone 5.5 inch/     (1242 x 2208 px)
│   └── iPad Pro (12.9 inch)/ (2048 x 2732 px)
└── en-US/
    ├── iPhone 6.5 inch/
    ├── iPhone 5.5 inch/
    └── iPad Pro (12.9 inch)/
```

2. Name files in order:
   - `01_screenshot.png`
   - `02_screenshot.png`
   - etc.

3. Upload screenshots:
```bash
cd ios
bundle exec fastlane upload_screenshots
```

---

### 🔧 Main Commands

| Command | Description |
|---------|-------------|
| `fastlane app_info` | View app info |
| `fastlane upload_metadata` | Upload descriptions |
| `fastlane upload_screenshots` | Upload screenshots |
| `fastlane upload_testflight` | Upload to TestFlight |
| `fastlane upload_appstore` | Upload to App Store |
| `fastlane release` | Complete process |

**Usage:**
```bash
cd ios
bundle exec fastlane <command>
```

---

### 📚 Complete Documentation

For detailed instructions:
- 🇪🇸 **[Spanish](docs/app-store-setup.md)**
- 🇺🇸 **[English](docs/app-store-setup-en.md)**

---

### 🔐 Security - VERY IMPORTANT

**⚠️ NEVER commit these files to Git:**
- ❌ `.env.appstore`
- ❌ `*.p8`
- ❌ `AuthKey_*.p8`

These files are already protected in `.gitignore`.

---

### 📊 App Information

- **Bundle ID**: `com.etalatam.schoolapp`
- **Name**: ETA School Transport
- **Current version**: 1.12.38
- **Build**: 38
- **Category**: Education
- **Rating**: 4+

---

### ✅ Checklist before publishing

- [ ] Credentials configured in `.env.appstore`
- [ ] Metadata in Spanish and English reviewed
- [ ] Screenshots added (Spanish and English)
- [ ] Support and privacy URLs working
- [ ] App tested on real devices
- [ ] Beta version tested on TestFlight

---

**Created**: 2025-01-08
**Maintained by**: Robert Bruno
**Project**: ETAlatam Flutter App
