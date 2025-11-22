# App Store Connect Setup for ETA School Transport

This guide will help you configure and upload your iOS application to App Store Connect.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Obtaining Credentials](#obtaining-credentials)
4. [Tools Installation](#tools-installation)
5. [Environment Variables Configuration](#environment-variables-configuration)
6. [Using Fastlane](#using-fastlane)
7. [Available Commands](#available-commands)
8. [Troubleshooting](#troubleshooting)

---

## 🔑 Prerequisites

Before starting, make sure you have:

- ✅ Active **Apple Developer Account** ($99 USD/year)
- ✅ **macOS** with Xcode installed (version 13.0 or higher)
- ✅ **Flutter 3.19.0** installed
- ✅ **Ruby** installed (pre-installed on macOS)
- ✅ Access to **App Store Connect** with administrator permissions
- ✅ Your application must be registered in App Store Connect

---

## 🚀 Initial Setup

### 1. Register the Application in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Sign in with your Apple ID
3. Click on **"My Apps"**
4. Click the **"+"** button and select **"New App"**
5. Complete the information:
   - **Platform**: iOS
   - **Name**: ETA School Transport
   - **Primary Language**: English (U.S.)
   - **Bundle ID**: Select `com.etalatam.schoolapp`
   - **SKU**: A unique identifier (e.g., `eta-school-transport-001`)
   - **User Access**: Full Access

### 2. Configure Basic Information

In App Store Connect, go to your app section and configure:

- **Category**: Education
- **Secondary Category** (optional): Utilities
- **Content Rights**: Select if it contains third-party content
- **Age Rating**: Complete the questionnaire (usually will be 4+)

---

## 🔐 Obtaining Credentials

### Step 1: Get your Team ID

**Option A - From Apple Developer:**
1. Go to: https://developer.apple.com/account
2. Sign in
3. In the **"Membership"** section, you'll find your **Team ID** (10 characters)

**Option B - From App Store Connect:**
1. Go to: https://appstoreconnect.apple.com
2. **Users and Access** > **Keys**
3. The Team ID appears at the top

### Step 2: Get App Store Connect API Key

You already have the `AuthKey_2A6UCBGW5Z.p8` file in your project. Now you need the **Issuer ID**:

1. Go to: https://appstoreconnect.apple.com
2. Go to **Users and Access**
3. Select the **Keys** tab
4. Copy the **Issuer ID** (UUID format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)

**Your API Key Information:**
- **Key ID**: `2A6UCBGW5Z` ✅ (you have the file)
- **Key File**: `AuthKey_2A6UCBGW5Z.p8` ✅
- **Issuer ID**: ⏳ (you must obtain it from the previous step)

---

## 🛠️ Tools Installation

### 1. Install Bundler and Fastlane

From the project directory:

```bash
# Install Bundler
sudo gem install bundler

# Navigate to iOS directory
cd ios

# Install dependencies (Fastlane and CocoaPods)
bundle install

# Verify Fastlane installation
bundle exec fastlane --version
```

### 2. Install CocoaPods Dependencies

```bash
# From the ios/ directory
pod install
```

---

## ⚙️ Environment Variables Configuration

### 1. Create configuration file

From the project root:

```bash
# Copy the example file
cp .env.appstore.example .env.appstore
```

### 2. Edit `.env.appstore`

Open the `.env.appstore` file and fill in with your data:

```bash
# Your Apple ID email
APPLE_ID=your-email@example.com

# Your Team ID (10 characters you obtained earlier)
TEAM_ID=ABC1234567

# iTunes Connect Team ID (usually the same as TEAM_ID)
ITC_TEAM_ID=ABC1234567

# App Store Connect API Key ID (already configured)
APP_STORE_CONNECT_API_KEY_ID=2A6UCBGW5Z

# Issuer ID (UUID you obtained from App Store Connect)
APP_STORE_CONNECT_API_ISSUER_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx

# Path to .p8 file (already configured)
APP_STORE_CONNECT_API_KEY_PATH=../AuthKey_2A6UCBGW5Z.p8
```

### 3. Load environment variables

```bash
# From the ios/ directory
export $(cat ../.env.appstore | xargs)
```

Or add this to your `~/.zshrc` or `~/.bash_profile`:

```bash
# Automatically load App Store variables
if [ -f ~/workspace/eta/ETAlatam-flutter/.env.appstore ]; then
    export $(cat ~/workspace/eta/ETAlatam-flutter/.env.appstore | xargs)
fi
```

---

## 🚀 Using Fastlane

### App Information

View current application information:

```bash
cd ios
bundle exec fastlane app_info
```

### Upload Metadata Only

To upload descriptions in Spanish and English without uploading a build:

```bash
cd ios
bundle exec fastlane upload_metadata
```

This will upload:
- ✅ App name
- ✅ Subtitle
- ✅ Description (Spanish and English)
- ✅ Keywords
- ✅ URLs (marketing, support, privacy)
- ✅ Release notes

### Upload Screenshots

First, place your screenshots in the corresponding folders:

```
ios/fastlane/screenshots/
├── es-ES/
│   ├── iPhone 6.5 inch/     # iPhone 14 Pro Max, 15 Pro Max
│   ├── iPhone 5.5 inch/     # iPhone 8 Plus
│   └── iPad Pro (12.9 inch)/
└── en-US/
    ├── iPhone 6.5 inch/
    ├── iPhone 5.5 inch/
    └── iPad Pro (12.9 inch)/
```

Then execute:

```bash
cd ios
bundle exec fastlane upload_screenshots
```

### Build and Upload to TestFlight

To send a beta version to TestFlight:

```bash
cd ios
bundle exec fastlane upload_testflight
```

### Build and Upload to App Store

To submit for review in App Store:

```bash
cd ios
bundle exec fastlane upload_appstore
```

### Complete Release Process

To do everything in a single command (build + metadata + upload):

```bash
cd ios
bundle exec fastlane release
```

To submit directly for review:

```bash
cd ios
bundle exec fastlane release submit_for_review:true
```

---

## 📝 Available Commands

| Command | Description |
|---------|-------------|
| `fastlane app_info` | View app information (version, build, bundle ID) |
| `fastlane build` | Build iOS app with Flutter |
| `fastlane build_archive` | Create IPA file for distribution |
| `fastlane upload_metadata` | Upload only metadata (descriptions, URLs, etc.) |
| `fastlane upload_screenshots` | Upload only screenshots |
| `fastlane upload_testflight` | Build and upload to TestFlight |
| `fastlane upload_appstore` | Build and upload to App Store |
| `fastlane release` | Complete process: build + metadata + upload |
| `fastlane increment_build` | Increment build number |
| `fastlane increment_version type:patch` | Increment version (patch/minor/major) |

### Version Management

```bash
# Increment patch version (1.12.38 → 1.12.39)
bundle exec fastlane increment_version type:patch

# Increment minor version (1.12.38 → 1.13.0)
bundle exec fastlane increment_version type:minor

# Increment major version (1.12.38 → 2.0.0)
bundle exec fastlane increment_version type:major

# Only increment build number (38 → 39)
bundle exec fastlane increment_build
```

---

## 🔍 Troubleshooting

### Error: "No API token found"

**Problem**: Fastlane can't find your API credentials.

**Solution**:
```bash
# Verify that variables are loaded
echo $APP_STORE_CONNECT_API_KEY_ID
echo $APP_STORE_CONNECT_API_ISSUER_ID

# If they're empty, load the .env.appstore file
export $(cat .env.appstore | xargs)
```

### Error: "Could not find provisioning profile"

**Problem**: You don't have provisioning profiles configured.

**Solution**:
1. Go to Xcode
2. Select the Runner project
3. Go to **Signing & Capabilities**
4. Check **"Automatically manage signing"**
5. Select your Team

### Error: "Build failed"

**Problem**: Flutter didn't compile correctly.

**Solution**:
```bash
# Clean and rebuild
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter build ios --release
```

### Error: "Invalid bundle identifier"

**Problem**: Bundle ID doesn't match.

**Solution**:
1. Verify in `ios/Runner.xcodeproj/project.pbxproj` that `PRODUCT_BUNDLE_IDENTIFIER = com.etalatam.schoolapp;`
2. Verify in App Store Connect that Bundle ID is exactly `com.etalatam.schoolapp`

### Error: "Version already exists"

**Problem**: A version with that number already exists.

**Solution**:
```bash
# Increment version or build
cd ios
bundle exec fastlane increment_version type:patch
# Or just the build
bundle exec fastlane increment_build
```

### Screenshots don't appear in App Store Connect

**Solution**:
- Verify that screenshots are in the correct size:
  - iPhone 6.5": 1242 x 2688 px or 1284 x 2778 px
  - iPhone 5.5": 1242 x 2208 px
  - iPad Pro 12.9": 2048 x 2732 px
- Files must be PNG or JPG
- Name files in order: `01_screenshot.png`, `02_screenshot.png`, etc.

---

## 📱 Configured Metadata Information

### Supported Languages
- ✅ **Spanish (Spain)** - es-ES
- ✅ **English (US)** - en-US (primary language)

### Created Metadata Files

```
ios/fastlane/metadata/
├── es-ES/
│   ├── name.txt              # ETA School Transport
│   ├── subtitle.txt          # School transportation tracking
│   ├── description.txt       # Full description in Spanish
│   ├── keywords.txt          # Search keywords
│   ├── marketing_url.txt     # Marketing URL
│   ├── support_url.txt       # Support URL
│   ├── privacy_url.txt       # Privacy policy URL
│   └── release_notes.txt     # Version release notes
└── en-US/
    ├── name.txt              # ETA School Transport
    ├── subtitle.txt          # School Bus Tracking System
    ├── description.txt       # Full description in English
    ├── keywords.txt          # Search keywords
    ├── marketing_url.txt     # Marketing URL
    ├── support_url.txt       # Support URL
    ├── privacy_url.txt       # Privacy policy URL
    └── release_notes.txt     # Version release notes
```

### Current Configuration

- **Bundle ID**: `com.etalatam.schoolapp`
- **Name**: ETA School Transport
- **Version**: 1.12.38
- **Build**: 38
- **Suggested category**: Education
- **Age rating**: 4+

---

## 🔐 Security

### ⚠️ IMPORTANT: Files you should NEVER commit to Git

The following files are already protected in `.gitignore`:

- ✅ `.env.appstore` - Contains your credentials
- ✅ `*.p8` - Private API keys
- ✅ `AuthKey_*.p8` - Your authentication key
- ✅ `*.cer`, `*.p12` - Certificates
- ✅ `*.mobileprovision` - Provisioning profiles

### Verify before committing

```bash
# Make sure these files DO NOT appear
git status

# If they appear, add them to .gitignore immediately
echo ".env.appstore" >> .gitignore
```

---

## 📚 Additional Resources

- [Fastlane Documentation](https://docs.fastlane.tools)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Screenshot Requirements](https://help.apple.com/app-store-connect/#/devd274dd925)

---

## ✅ Final Checklist Before Submitting for Review

- [ ] Metadata in Spanish and English completed
- [ ] Screenshots in all required sizes
- [ ] Privacy, support, and marketing URLs working
- [ ] App tested on physical devices
- [ ] TestFlight version tested by beta testers
- [ ] Compliance with [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [ ] Location permissions justified in the app
- [ ] App icons in all sizes
- [ ] Launch screen configured
- [ ] Contact information updated in App Store Connect

---

## 🆘 Support

If you have problems with the configuration:

1. Review the [Troubleshooting](#troubleshooting) section
2. Check Fastlane logs: `ios/fastlane/report.xml`
3. Consult [Fastlane documentation](https://docs.fastlane.tools)
4. Contact the ETAlatam development team

---

**Last updated**: 2025-01-08
**App version**: 1.12.38
**Maintained by**: Robert Bruno
