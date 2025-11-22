#!/bin/bash

# ============================================
# App Store Connect Setup Script
# ETA School Transport - iOS Configuration
# ============================================

set -e  # Exit on error

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "================================================"
echo "  App Store Connect Setup - ETA School Transport"
echo "================================================"
echo -e "${NC}"

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script must run on macOS"
    exit 1
fi

print_success "Running on macOS"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed. Please install Flutter 3.19.0"
    exit 1
fi

print_success "Flutter is installed"

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | grep "Flutter" | awk '{print $2}')
print_info "Flutter version: $FLUTTER_VERSION"

if [[ "$FLUTTER_VERSION" != "3.19.0" ]]; then
    print_warning "Recommended Flutter version is 3.19.0, you have $FLUTTER_VERSION"
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if Ruby is installed
if ! command -v ruby &> /dev/null; then
    print_error "Ruby is not installed"
    exit 1
fi

print_success "Ruby is installed ($(ruby --version))"

# Check if Bundler is installed
if ! command -v bundle &> /dev/null; then
    print_info "Installing Bundler..."
    sudo gem install bundler
    print_success "Bundler installed"
else
    print_success "Bundler is already installed"
fi

# Check if .env.appstore exists
if [ ! -f ".env.appstore" ]; then
    print_info "Creating .env.appstore from example..."

    if [ -f ".env.appstore.example" ]; then
        cp .env.appstore.example .env.appstore
        print_success ".env.appstore file created"
        print_warning "⚠️  IMPORTANT: Edit .env.appstore with your credentials!"
        print_info "You need to add:"
        echo "  - APPLE_ID (your Apple ID email)"
        echo "  - TEAM_ID (from Apple Developer portal)"
        echo "  - APP_STORE_CONNECT_API_ISSUER_ID (from App Store Connect)"
        echo ""
        read -p "Press Enter to open .env.appstore in nano editor..."
        nano .env.appstore
    else
        print_error ".env.appstore.example not found"
        exit 1
    fi
else
    print_success ".env.appstore already exists"
fi

# Verify AuthKey file exists
if [ ! -f "AuthKey_2A6UCBGW5Z.p8" ]; then
    print_error "AuthKey_2A6UCBGW5Z.p8 not found in project root"
    print_info "Please ensure the .p8 file is in the project root directory"
    exit 1
fi

print_success "AuthKey_2A6UCBGW5Z.p8 found"

# Navigate to iOS directory
cd ios

# Install Fastlane and dependencies
print_info "Installing Fastlane and dependencies..."
bundle install
print_success "Fastlane installed"

# Install CocoaPods dependencies
print_info "Installing CocoaPods dependencies..."
pod install
print_success "CocoaPods dependencies installed"

# Go back to project root
cd ..

# Load environment variables
print_info "Loading environment variables..."
export $(cat .env.appstore | grep -v '^#' | xargs)

# Verify required environment variables
MISSING_VARS=0

if [ -z "$TEAM_ID" ] || [ "$TEAM_ID" = "YOUR_TEAM_ID" ]; then
    print_error "TEAM_ID is not set in .env.appstore"
    MISSING_VARS=1
fi

if [ -z "$APP_STORE_CONNECT_API_ISSUER_ID" ] || [ "$APP_STORE_CONNECT_API_ISSUER_ID" = "YOUR_ISSUER_ID_HERE" ]; then
    print_error "APP_STORE_CONNECT_API_ISSUER_ID is not set in .env.appstore"
    MISSING_VARS=1
fi

if [ -z "$APPLE_ID" ] || [ "$APPLE_ID" = "your-apple-id@example.com" ]; then
    print_error "APPLE_ID is not set in .env.appstore"
    MISSING_VARS=1
fi

if [ $MISSING_VARS -eq 1 ]; then
    print_error "Please edit .env.appstore and add the missing credentials"
    print_info "Run: nano .env.appstore"
    exit 1
fi

print_success "All required environment variables are set"

# Test Fastlane installation
print_info "Testing Fastlane installation..."
cd ios
if bundle exec fastlane --version &> /dev/null; then
    print_success "Fastlane is working correctly"
else
    print_error "Fastlane test failed"
    exit 1
fi

# Show app info
print_info "Getting app information..."
bundle exec fastlane app_info

cd ..

echo ""
print_success "Setup completed successfully!"
echo ""
print_info "Next steps:"
echo "  1. Verify your credentials in .env.appstore"
echo "  2. Review metadata in ios/fastlane/metadata/"
echo "  3. Add screenshots to ios/fastlane/screenshots/"
echo "  4. Read the full documentation: docs/app-store-setup.md"
echo ""
print_info "Common commands:"
echo "  - Upload metadata:      cd ios && bundle exec fastlane upload_metadata"
echo "  - Upload to TestFlight: cd ios && bundle exec fastlane upload_testflight"
echo "  - Upload to App Store:  cd ios && bundle exec fastlane upload_appstore"
echo "  - Full release:         cd ios && bundle exec fastlane release"
echo ""
print_warning "Remember to NEVER commit .env.appstore or *.p8 files to Git!"
echo ""
