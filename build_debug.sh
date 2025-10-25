#!/bin/bash

# Set environment variables
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=/opt/android-sdk

# Clean previous builds
fvm flutter clean

# Get dependencies
fvm flutter pub get

# Ensure local.properties has correct SDK path
echo "sdk.dir=/opt/android-sdk" > android/local.properties
echo "flutter.sdk=/home/rbruno/fvm/versions/3.19.0" >> android/local.properties
echo "flutter.buildMode=debug" >> android/local.properties
echo "flutter.versionName=1.12.32" >> android/local.properties

# Accept licenses
yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --licenses 2>/dev/null || true

# Install required SDK components
yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager "platforms;android-34" "build-tools;30.0.3" 2>/dev/null || true

# Build APK
fvm flutter build apk --debug

echo "Build completed!"
echo "APK location: build/app/outputs/flutter-apk/app-debug.apk"