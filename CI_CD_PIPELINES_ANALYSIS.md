# ETAlatam Flutter - CI/CD & Pipelines Analysis

**Project**: ETA School Transport - Flutter Application  
**Current Version**: 1.12.38 (Build 38)  
**Flutter Version**: 3.19.0  
**Dart SDK**: 3.2.0  
**Current Branch**: tareas-pendientes-fix-android  

---

## 1. GitHub Actions Workflows

### 1.1 Android Build Pipeline (`.github/workflows/android-build.yml`)

**Purpose**: Automated Android APK build with split architectures on every push/PR to main branch

**Triggers**:
- Push to `main` branch
- Pull requests to `main` branch

**Execution Environment**: Ubuntu Latest

**Pipeline Stages**:

1. **Checkout Code**
   - Uses: `actions/checkout@v4`
   - Pulls entire repository

2. **Set Up Flutter**
   - Uses: `subosito/flutter-action@v2`
   - Channel: stable
   - Version: 3.19.2 (Note: slightly different from CLAUDE.md requirement of 3.19.0)
   - Cache enabled for faster builds

3. **Extract Version**
   - Reads version from `pubspec.yaml`
   - Format: `<major>.<minor>.<patch>+<build>`
   - Stores as output variable: `steps.get_version.outputs.version`

4. **Get Dependencies**
   - Command: `flutter pub get`
   - Installs all Dart/Flutter dependencies

5. **Decode Keystore**
   - Decodes base64-encoded keystore from secrets
   - Creates: `android/app/upload-keystore.jks`
   - Required for signing APKs

6. **Build APKs**
   - Command: `flutter build apk --split-per-abi --tree-shake-icons`
   - Generates separate APKs for each architecture:
     - arm64-v8a (64-bit ARM)
     - armeabi-v7a (32-bit ARM)
   - Tree-shake-icons enabled to reduce size

7. **Rename APKs**
   - Renames outputs with version number
   - Format: `eta-<arch>-<version>.apk`

8. **Upload Artifacts**
   - Uploads both APKs as GitHub artifacts
   - Artifacts available for download from Actions run

**Secrets Used** (GitHub Actions Secrets):
- `KEYSTORE_FILE`: Base64-encoded Android keystore
- `KEYSTORE_PASSWORD`: Keystore file password
- `KEY_PASSWORD`: Key password
- `KEY_ALIAS`: Key alias in keystore

**Duration**: ~10-15 minutes

**Outputs**:
- `eta-arm64-v8a-<version>.apk` (primary architecture)
- `eta-armeabi-v7a-<version>.apk` (fallback architecture)

---

## 2. Fastlane Configuration (iOS/macOS)

### 2.1 Fastlane Setup

**Location**: `/ios/fastlane/`

**Components**:
- `Gemfile`: Ruby dependencies (fastlane, cocoapods)
- `Appfile`: App configuration
- `Fastfile`: Lane definitions
- `metadata/`: Localized app store metadata

### 2.2 Appfile (`ios/fastlane/Appfile`)

**Configuration**:
```
apple_id: env["APPLE_ID"] or "your-apple-id@example.com"
team_id: env["TEAM_ID"] or "YOUR_TEAM_ID_HERE"
itc_team_id: env["ITC_TEAM_ID"] or env["TEAM_ID"]
app_identifier: "com.etalatam.schoolapp"
```

**Environment Variables**:
- `APPLE_ID`: Apple Developer Account email
- `TEAM_ID`: Apple Developer Team ID (10-character string)
- `ITC_TEAM_ID`: iTunes Connect Team ID (usually same as TEAM_ID)

### 2.3 Fastfile - Available Lanes

**Build Lanes**:

| Lane | Command | Purpose |
|------|---------|---------|
| `build` | `fastlane build` | Build iOS with Flutter (no signing) |
| `build_archive` | `fastlane build_archive` | Build and create IPA archive with App Store provisioning |
| `increment_build` | `fastlane increment_build` | Increment build number |
| `increment_version` | `fastlane increment_version [type:major/minor/patch]` | Increment version |
| `app_info` | `fastlane app_info` | Display app information |

**Metadata Lanes**:

| Lane | Command | Purpose |
|------|---------|---------|
| `upload_metadata` | `fastlane upload_metadata` | Upload metadata in ES and EN languages |
| `upload_screenshots` | `fastlane upload_screenshots` | Upload screenshots |

**Distribution Lanes**:

| Lane | Command | Purpose |
|------|---------|---------|
| `upload_testflight` | `fastlane upload_testflight [skip_build:true]` | Build, archive, and upload to TestFlight |
| `upload_appstore` | `fastlane upload_appstore [skip_build:true] [skip_metadata:true] [skip_screenshots:true] [submit_for_review:true]` | Upload to App Store |
| `release` | `fastlane release [submit_for_review:false]` | Complete release: build + metadata + upload |

**Secrets Used** (Environment Variables):

```env
# Apple Developer Account
APPLE_ID=etalatamdev@gmail.com
TEAM_ID=494S8338AJ
ITC_TEAM_ID=494S8338AJ

# App Store Connect API
APP_STORE_CONNECT_API_KEY_ID=2A6UCBGW5Z
APP_STORE_CONNECT_API_ISSUER_ID=633d3064-8dbd-412b-aa53-2c4aa211c354
APP_STORE_CONNECT_API_KEY_PATH=../AuthKey_2A6UCBGW5Z.p8
```

**How to Run**:
```bash
cd ios
bundle exec fastlane <lane_name> [options]
```

---

## 3. Metadata & Localization

### 3.1 Metadata Structure

**Location**: `ios/fastlane/metadata/`

**Supported Languages**:
- Spanish (es-ES)
- English (en-US)

**Files per Language**:
```
metadata/
├── es-ES/
│   ├── name.txt                    # "ETA School Transport"
│   ├── subtitle.txt                # "Seguimiento de Transporte Escolar"
│   ├── description.txt             # Full description (1,850+ chars)
│   ├── keywords.txt                # Search keywords
│   ├── marketing_url.txt           # https://etalatam.com
│   ├── support_url.txt             # https://etalatam.com/support
│   ├── privacy_url.txt             # https://etalatam.com/privacy
│   └── release_notes.txt           # Version-specific release notes
└── en-US/
    └── [same structure with English content]
```

### 3.2 Screenshots Structure

**Location**: `ios/fastlane/screenshots/`

**Structure**:
```
screenshots/
├── es-ES/
│   └── iPhone 6.5 inch/
│       ├── 01_screenshot.png       (1284 x 2778 px)
│       ├── 02_screenshot.png
│       └── ...
└── en-US/
    └── iPhone 6.5 inch/
        ├── 01_screenshot.png
        └── ...
```

---

## 4. Build Scripts

### 4.1 Main Build Script (`build_app.sh`)

**Purpose**: Interactive cross-platform build script

**Features**:
- Verifies Flutter installation
- Runs code analysis
- Interactive platform selection
- Builds for Android, iOS, Web, or all platforms

**Usage**:
```bash
./build_app.sh
```

**Build Options**:
1. Android APK (release)
2. Android App Bundle (release)
3. iOS (release)
4. Web (release)
5. All platforms

**Output Locations**:
- Android APK: `build/app/outputs/flutter-apk/app-release.apk`
- Android Bundle: `build/app/outputs/bundle/release/app-release.aab`
- iOS: `build/ios/iphoneos/`
- Web: `build/web/`

### 4.2 Debug Build Script (`build_debug.sh`)

**Purpose**: Fast Android debug build for development

**Uses**:
- FVM (Flutter Version Manager)
- Java 17
- Android SDK at `/opt/android-sdk`

**Configuration**:
```bash
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ANDROID_HOME=/opt/android-sdk
ANDROID_SDK_ROOT=/opt/android-sdk
```

**Features**:
- Auto-accepts Android licenses
- Installs required SDK components
- Builds debug APK

**Output**: `build/app/outputs/flutter-apk/app-debug.apk`

### 4.3 Test Execution Script (`run_tests.sh`)

**Purpose**: E2E and integration testing

**Test Credentials** (for testing):
- Email: `etalatam+representante1@gmail.com`
- Password: `casa1234`

**Test Options**:
1. Basic login tests
2. Detailed login tests
3. All tests
4. Headless mode (CI/CD compatible)

**Output**: `test_results/test_output.log`

### 4.4 App Store Setup Script (`setup_appstore.sh`)

**Purpose**: Automated macOS setup for iOS/App Store deployment

**Requirements**:
- macOS only
- Flutter 3.19.0 (checked with warning)
- Ruby with Bundler
- Xcode tools

**Setup Steps**:
1. Verifies system requirements
2. Creates `.env.appstore` from template
3. Verifies AuthKey file exists
4. Installs Fastlane via Bundler
5. Installs CocoaPods dependencies
6. Validates environment variables
7. Tests Fastlane installation
8. Displays app information

**Guard Checks**:
- Ensures `.env.appstore` is properly configured
- Validates all required API credentials
- Verifies API key file exists

---

## 5. Gradle Configuration (Android)

### 5.1 Root Build Configuration (`android/build.gradle`)

**Gradle Plugins**:
- Kotlin: 1.9.21
- Android Gradle Plugin: 8.0.2
- Google Services (FirebaseConfig): 4.3.5

**Repositories**:
- Google Maven
- Maven Central
- Gradle Plugins Portal

### 5.2 App Build Configuration (`android/app/build.gradle`)

**App Configuration**:
- Namespace: `com.etalatam.schoolapp`
- Compile SDK: 34
- Min SDK: 21
- Target SDK: 33
- Version: From `local.properties` (1.12.38+38)

**Plugins**:
- Android Application
- Google Services (Firebase)
- Kotlin Android
- Flutter Gradle

**Dependencies**:
- Kotlin stdlib
- Google Play Services Maps: 18.1.0
- OneSignal: [5.0.0, 5.99.99]
- Firebase BOM: 32.5.0

**Signing Configuration**:
- Currently uses debug keys (TODO: implement release signing)
- Commented-out release signing block

### 5.3 Settings Configuration (`android/settings.gradle`)

**Gradle Version**: 7.3.0
**Flutter Plugin Loader**: 1.0.0
**Google Services**: 4.3.15

---

## 6. Environment Configuration Files

### 6.1 `.env.appstore.example`

**Template for App Store Connect API Configuration**:
```env
# User credentials
APPLE_ID=your-apple-id@example.com
TEAM_ID=YOUR_TEAM_ID
ITC_TEAM_ID=YOUR_TEAM_ID

# App Store Connect API
APP_STORE_CONNECT_API_KEY_ID=2A6UCBGW5Z
APP_STORE_CONNECT_API_ISSUER_ID=YOUR_ISSUER_ID_HERE
APP_STORE_CONNECT_API_KEY_PATH=../AuthKey_2A6UCBGW5Z.p8
```

### 6.2 `.env.appstore` (Actual - .gitignored)

**Contains Real Credentials** (Never commit):
```env
APPLE_ID=etalatamdev@gmail.com
TEAM_ID=494S8338AJ
APP_STORE_CONNECT_API_ISSUER_ID=633d3064-8dbd-412b-aa53-2c4aa211c354
```

---

## 7. Security & Secrets Management

### 7.1 GitHub Actions Secrets

**Android Build Secrets**:
- `KEYSTORE_FILE`: Base64-encoded .jks keystore file
- `KEYSTORE_PASSWORD`: Keystore password
- `KEY_PASSWORD`: Key password
- `KEY_ALIAS`: Signing key alias

**Location**: GitHub Repository Settings → Secrets and variables → Actions

### 7.2 Local Development Secrets

**Protected Files** (in `.gitignore`):
```
# App Store Connect
.env.appstore
*.p8
AuthKey_*.p8

# Certificates
*.cer
*.p12
*.mobileprovision
*.certSigningRequest

# Fastlane reports
**/ios/fastlane/report.xml
**/ios/fastlane/test_output
**/ios/fastlane/Preview.html
```

### 7.3 API Key Handling

**App Store Connect API**:
- Key ID: `2A6UCBGW5Z`
- Key Type: Team Key (secure, not user password)
- Key File: `AuthKey_2A6UCBGW5Z.p8` (must be kept private)
- Issuer ID: UUID format

---

## 8. Deployment Workflows

### 8.1 Android Deployment

**Automated via GitHub Actions**:

```
Push to main → GitHub Actions
    ↓
Checkout code
    ↓
Setup Flutter 3.19.2
    ↓
Get dependencies
    ↓
Decode keystore from secrets
    ↓
Build APKs (split by architecture)
    ↓
Rename with version
    ↓
Upload as artifacts → Available for manual download
```

**Manual Deployment** (if needed):
```bash
# Without automation
./build_app.sh
# Select option 1 (Android APK)
# Then manually upload to Play Store
```

### 8.2 iOS/App Store Deployment

**Prerequisite Setup** (one-time on macOS):
```bash
./setup_appstore.sh
# Installs Fastlane, CocoaPods, validates credentials
```

**Metadata Upload** (no binary):
```bash
cd ios
bundle exec fastlane upload_metadata
# Uploads app name, description, keywords for ES and EN
```

**TestFlight Deployment**:
```bash
cd ios
bundle exec fastlane upload_testflight
# Builds, archives, signs, and uploads to TestFlight
```

**App Store Deployment**:
```bash
cd ios
bundle exec fastlane upload_appstore [submit_for_review:true]
# Builds, signs, and submits to App Store
# Optionally auto-submit for review
```

**Full Release Process**:
```bash
cd ios
bundle exec fastlane release [submit_for_review:false]
# Builds → Archives → Uploads metadata → Uploads to App Store
# Requires manual review submission in App Store Connect
```

### 8.3 Version Management

**Version Format**: `major.minor.patch+build`
- Stored in `pubspec.yaml`: `version: 1.12.38+38`
- Read by build systems automatically

**Version Bumping**:
```bash
# iOS (Xcode)
cd ios
bundle exec fastlane increment_build      # Increment build number only
bundle exec fastlane increment_version    # Interactive major/minor/patch
```

---

## 9. Python Metadata Upload Scripts

### 9.1 Purpose

Alternative to Fastlane for uploading metadata on Linux without macOS

**Files**:
- `upload_metadata_api.py`: v1 implementation
- `upload_metadata_api_v2.py`: v2 with improved endpoint handling

### 9.2 Capabilities

**Authentication**:
- Generates JWT token using App Store Connect API
- Token lifetime: 20 minutes (max allowed by Apple)

**Operations**:
- Find app by bundle ID
- Upload metadata for multiple languages
- Authenticate using `.p8` key file

**Configuration** (hardcoded in scripts):
```python
KEY_ID = "2A6UCBGW5Z"
ISSUER_ID = "633d3064-8dbd-412b-aa53-2c4aa211c354"
BUNDLE_ID = "com.etalatam.schoolapp"
KEY_FILE = "AuthKey_2A6UCBGW5Z.p8"
API_BASE = "https://api.appstoreconnect.apple.com/v1"
```

### 9.3 Usage

**Requirements**:
```bash
pip3 install PyJWT cryptography requests
```

**Run**:
```bash
python3 upload_metadata_api.py
# or
python3 upload_metadata_api_v2.py
```

---

## 10. Documentation Files

### 10.1 App Store Setup Guides

**Files**:
- `docs/app-store-setup.md` - Complete Spanish guide (13KB)
- `docs/app-store-setup-en.md` - Complete English guide (12KB)

**Content**:
- Step-by-step setup instructions
- Troubleshooting
- Best practices
- Command reference

### 10.2 Configuration Summary

**File**: `APP_STORE_CONFIGURATION_SUMMARY.md` (23KB)

**Covers**:
- Completed configuration overview
- All credentials configured
- Metadata for 2 languages
- Fastlane setup details
- Next steps guide
- Important warnings

### 10.3 Metadata Upload Guide

**File**: `COMO_SUBIR_METADATOS.md` (7KB, Spanish)

**Provides**:
- 3 upload method options:
  1. Python script (Linux/Mac)
  2. Fastlane (macOS only)
  3. Manual web upload (no dependencies)
- Detailed field mappings
- Verification checklist
- Troubleshooting

---

## 11. CI/CD Summary Table

| Component | Technology | Location | Trigger | Status |
|-----------|-----------|----------|---------|--------|
| **Android Build** | GitHub Actions | `.github/workflows/android-build.yml` | Push/PR to main | Active |
| **iOS Build** | Fastlane | `ios/fastlane/Fastfile` | Manual (cd ios) | Configured |
| **Metadata Upload (iOS)** | Fastlane + Python | `ios/fastlane/ + .py scripts` | Manual | Configured |
| **Testing** | Flutter Test | `run_tests.sh` | Manual | Available |
| **Version Management** | Fastlane + pubspec.yaml | `ios/fastlane/ + pubspec.yaml` | Manual | Configured |
| **Code Analysis** | flutter analyze | `build_app.sh` | Manual | Available |

---

## 12. Required Secrets for Full CI/CD Setup

### Android (GitHub Actions Secrets):
- [ ] `KEYSTORE_FILE` - Base64 encoded .jks
- [ ] `KEYSTORE_PASSWORD` - Password for keystore
- [ ] `KEY_PASSWORD` - Password for key
- [ ] `KEY_ALIAS` - Signing key alias

### iOS/macOS (Local `.env.appstore`):
- [ ] `APPLE_ID` - Apple Developer account email
- [ ] `TEAM_ID` - Apple Team ID (from developer.apple.com)
- [ ] `APP_STORE_CONNECT_API_ISSUER_ID` - UUID from App Store Connect
- [ ] `AuthKey_2A6UCBGW5Z.p8` - API key file

---

## 13. Known Issues & TODOs

**Android Build**:
- Flutter version: 3.19.2 (workflow) vs 3.19.0 (CLAUDE.md) - Minor mismatch
- Release signing: Currently commented out, using debug keys

**iOS Build**:
- Fastlane requires macOS - cannot run on Linux/Windows
- CocoaPods pods need installation before fastlane usage

**Testing**:
- Integration tests require physical device or emulator
- Login tests use hardcoded test credentials

---

## 14. Getting Started Checklist

### First-time Setup (Android CI/CD):
- [ ] Create GitHub Actions secrets (KEYSTORE_FILE, passwords, alias)
- [ ] Add `.jks` keystore file
- [ ] Verify GitHub Actions enabled in repo settings
- [ ] Test workflow by pushing to main or creating PR

### First-time Setup (iOS/App Store):
- [ ] Run `./setup_appstore.sh` on macOS
- [ ] Complete `.env.appstore` with credentials
- [ ] Verify AuthKey_2A6UCBGW5Z.p8 exists
- [ ] Test with `cd ios && bundle exec fastlane app_info`
- [ ] Upload metadata: `bundle exec fastlane upload_metadata`

### Ongoing Maintenance:
- [ ] Version bumps: Use `fastlane increment_version`
- [ ] Screenshots: Update in `ios/fastlane/screenshots/`
- [ ] Release notes: Update `metadata/*/release_notes.txt`
- [ ] Metadata: Keep `metadata/*/` files current

---

## 15. File Structure Reference

```
ETAlatam-flutter/
├── .github/
│   └── workflows/
│       └── android-build.yml          # GitHub Actions - Android
│
├── .env.appstore.example              # Config template
├── .env.appstore                      # Actual config (GITIGNORED)
├── .gitignore                         # Protects secrets
│
├── android/
│   ├── build.gradle                   # Root Gradle config
│   ├── settings.gradle                # Gradle settings
│   └── app/
│       └── build.gradle               # App build config
│
├── ios/
│   ├── Gemfile                        # Ruby dependencies
│   ├── Podfile                        # CocoaPods config
│   └── fastlane/
│       ├── Appfile                    # App config
│       ├── Fastfile                   # Build lanes
│       ├── metadata/                  # Localized app store data
│       │   ├── es-ES/
│       │   └── en-US/
│       └── screenshots/               # App store screenshots
│           ├── es-ES/
│           └── en-US/
│
├── build_app.sh                       # Interactive build script
├── build_debug.sh                     # Debug Android build
├── run_tests.sh                       # E2E test runner
├── setup_appstore.sh                  # macOS setup automation
│
├── upload_metadata_api.py             # Python metadata upload v1
├── upload_metadata_api_v2.py          # Python metadata upload v2
│
├── pubspec.yaml                       # Flutter config + version
│
├── docs/
│   ├── app-store-setup.md             # iOS guide (ES)
│   ├── app-store-setup-en.md          # iOS guide (EN)
│   └── fcm-notifications.md           # FCM documentation
│
├── APPSTORE_README.md                 # Quick app store guide
├── APP_STORE_CONFIGURATION_SUMMARY.md # Config details
├── COMO_SUBIR_METADATOS.md            # Metadata upload guide (ES)
│
└── [other files...]
```

---

## 16. Command Reference

### Build Commands

```bash
# Android
flutter build apk --release
flutter build appbundle --release
./build_app.sh                     # Interactive

# iOS (requires macOS)
flutter build ios --release

# Web
flutter build web --release

# Debug Android
./build_debug.sh
```

### iOS Deployment Commands

```bash
cd ios

# Setup (first time on macOS)
bundle exec fastlane setup_appstore  # Actually run ./setup_appstore.sh from root

# Get info
bundle exec fastlane app_info

# Upload metadata only
bundle exec fastlane upload_metadata

# TestFlight
bundle exec fastlane upload_testflight

# App Store
bundle exec fastlane upload_appstore

# Full release
bundle exec fastlane release

# Version management
bundle exec fastlane increment_build
bundle exec fastlane increment_version [type:major]
```

### Testing Commands

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Test with script
./run_tests.sh              # Interactive menu
```

### Utility Commands

```bash
# Code analysis
flutter analyze

# Code formatting
dart format .

# Clean build
flutter clean && flutter pub get

# Check installed Flutter
flutter --version
```

---

**Last Updated**: November 2025  
**Maintained By**: Robert Bruno  
**Repository**: ETAlatam-flutter
