# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ETAlatam is a Flutter application for real-time school transport tracking system supporting three user types:
- **Drivers**: GPS tracking and route management
- **Students**: Real-time bus location tracking
- **Guardians/Parents**: Monitor student transport in real-time

## Essential Commands

```bash
# Development
flutter run                              # Run in debug mode
flutter run --release                    # Run in release mode

# Building
./build_app.sh                          # Interactive build script (Android/iOS/Web)
flutter build apk --release              # Build Android APK
flutter build appbundle --release        # Build Android App Bundle
flutter build ios --release              # Build iOS (requires Mac)

# Code Quality
flutter analyze                          # Run static analysis
dart format .                           # Format code

# Testing
flutter test                             # Run all tests
flutter test test/specific_test.dart    # Run specific test file

# Dependencies
flutter pub get                          # Install dependencies
flutter pub upgrade                      # Upgrade dependencies
flutter clean                           # Clean build artifacts
```

## Architecture

### Clean Architecture Pattern
The codebase follows clean architecture with clear separation:

```
lib/
├── domain/              # Business logic and entities
│   ├── entities/       # Core business objects (User, Route, Driver, etc.)
│   └── interfaces/     # Repository interfaces
├── infrastructure/      # External dependencies and implementations
│   ├── repositories/   # Data access implementations
│   ├── services/       # External service integrations
│   └── isar/          # Database schemas
└── presentation/       # UI layer
    ├── pages/         # Screen implementations
    ├── widgets/       # Reusable UI components
    └── providers/     # State management
```

### State Management
- **Provider Pattern**: Used throughout with MultiProvider setup
- **Key Providers**:
  - `ThemeProvider`: Dark/light theme management
  - `LocationService`: GPS tracking (singleton)
  - `EmitterService`: Real-time messaging (singleton)
  - `NotificationService`: FCM notifications (singleton)

### Key Services & Technologies

**Backend Integration**:
- API Base URL: `http://api.eta.ec` (production)
- Real-time updates via Emitter.io channels
- RESTful API for data operations

**Location & Maps**:
- Mapbox for map rendering and geocoding
- Background location tracking with `flutter_background_geolocation`
- Distance calculations using Haversine formula

**Database**:
- Isar database for local storage
- Offline-first architecture with sync capabilities
- Entities: User, Driver, Student, Route, RouteStop, Institution

**Notifications**:
- Firebase Cloud Messaging (FCM) for push notifications
- Background message handling
- Local notifications support

## Current Task Priorities (from TODO.MD)

### High Priority Issues
1. **Student GPS Issues**: Students not reporting position correctly
2. **Distance Calculation**: Algorithm producing incorrect results
3. **Driver Map**: Touch interactions not working properly
4. **Password Recovery**: Email sending functionality broken

### Recent Updates
- Implemented complete dark/light theme system (Material Design 3)
- Performance optimizations for API requests
- Session management improvements

## Development Workflow

### Git Branches
- `main`: Production branch
- `tareas-pendientes`: Current development branch
- Feature branches: `feature/[feature-name]`

### Building for Production
1. Ensure all dependencies are installed: `flutter pub get`
2. Run analysis: `flutter analyze`
3. Run tests: `flutter test`
4. Use build script: `./build_app.sh` (interactive menu)

### Environment Configuration
- Firebase: Configure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- Mapbox: Set access token in map components
- API endpoints: Update base URL in service classes

## Known Issues & Solutions

**Build Issues**:
- Strict Flutter version requirement: 3.19.0
- Dart SDK: >=3.2.0 <4.0.0
- If build fails, run `flutter clean` then `flutter pub get`

**Runtime Issues**:
- Location permissions must be granted for driver/student roles
- Background location requires special permissions on Android 10+
- Notification permissions required for FCM

**Database Issues**:
- Isar database version conflicts: Delete app data and reinstall
- Schema changes require database migration

## Testing Approach
- Widget tests in `test/` directory
- Manual testing for location-based features
- Test accounts available for each user role
- Integration testing with real devices recommended for GPS features

## Build Status
- Last updated: October 2025