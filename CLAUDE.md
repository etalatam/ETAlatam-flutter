# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ETAlatam is a Flutter cross-platform application (Android/iOS/Web) for real-time school transport tracking, supporting three user roles:
- **Drivers**: GPS tracking, route management, and student attendance
- **Students**: Real-time bus location tracking and trip history
- **Guardians/Parents**: Monitor multiple students and receive real-time notifications

**Version**: 1.12.33
**Flutter**: 3.19.0 (strictly required - exact version)
**Dart SDK**: 3.2.0 (strictly required - exact version)

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
flutter build web --release              # Build for web

# Code Quality
flutter analyze                          # Run static analysis
dart format .                           # Format code
dart fix                                # Auto-fix common issues

# Testing
flutter test                             # Run all tests
flutter test test/specific_test.dart    # Run specific test file
flutter test integration_test            # Run integration tests

# Dependencies
flutter pub get                          # Install dependencies
flutter pub upgrade                      # Upgrade dependencies
flutter clean                           # Clean build artifacts
flutter pub run build_runner build       # Generate Isar schemas (*.g.dart files)
```

## Architecture

### Clean Architecture Pattern
The codebase follows clean architecture with clear separation of concerns:

```
lib/
├── domain/                  # Business logic layer
│   ├── entities/           # Isar database entities (Driver, LoginInformation, etc.)
│   ├── repositories/       # Abstract repository interfaces
│   └── datasources/        # Abstract data source interfaces
│
├── infrastructure/          # Implementation layer
│   ├── repositories/       # Repository implementations
│   ├── datasources/        # Data source implementations (Isar, API)
│   ├── mappers/           # Data transformation between DTOs and entities
│   └── services/          # Isar database service
│
├── Pages/                  # UI layer - Screen implementations by user role
│   ├── driver_home.dart   # Driver dashboard
│   ├── students_home.dart # Student tracking interface
│   ├── guardians_home.dart# Guardian/parent monitoring
│   ├── trip_page.dart     # Active trip tracking
│   ├── login_page.dart    # Authentication
│   ├── providers/         # Page-level state providers
│   └── map/               # Map-related components
│
├── shared/                # Singleton services
│   ├── fcm/              # Firebase Cloud Messaging (NotificationService)
│   ├── location/         # GPS tracking (LocationService)
│   └── emitterio/        # Real-time messaging (EmitterService)
│
├── providers/            # Global app providers (ThemeProvider)
├── API/                  # HTTP client for backend integration
├── Models/               # Data models (DTOs)
├── controllers/          # Business logic, helpers, and app configuration
└── components/           # Reusable UI widgets
```

### State Management

**Primary Pattern**: Provider with MultiProvider setup in [main.dart](lib/main.dart)

**Core Singleton Providers**:
- `ThemeProvider` - Dark/light theme with SharedPreferences persistence
- `LocationService.instance` - GPS tracking and distance calculations
- `EmitterService.instance` - WebSocket-based real-time messaging
- `NotificationService.instance` - FCM topic-based notifications

**Secondary Pattern**: GetX for navigation and dependency injection
- `Get.put()` for service registration (LocaleController, PreferencesSetting)
- `Get.find()` for retrieving services
- GetMaterialApp with named route navigation

**Note**: Riverpod is available but not actively used (commented out in codebase)

### Key Services & Technologies

**Backend Integration**:
- API Base URL: `https://api.etalatam.com` ([helpers.dart:12](lib/controllers/helpers.dart#L12))
- HTTP Client: `HttpService` ([client.dart](lib/API/client.dart))
- Real-time updates: Emitter.io WebSocket (`wss://emitter.etalatam.com:443`)
- Automatic session management (401/403 logout handling)

**Location Services**:
- Primary: `background_locator_2` for GPS tracking
- Maps: Mapbox Maps Flutter (primary), Google Maps Flutter (secondary)
- Mapbox Token: Configured in [main.dart](lib/main.dart) (should be moved to env variables)
- Distance calculation: Haversine formula with thread-safe accumulation
- Background updates: WorkManager (Android) and native services (iOS)

**Database (Isar)**:
- NoSQL database for offline-first architecture
- Location: [isar_services.dart](lib/infrastructure/services/isar_services.dart)
- Entities: `LoginInformation`, `BackgroundPosition`, `Driver`
- Auto-generated schemas: `*.g.dart` files (run build_runner to regenerate)

**Notifications (FCM)**:
- Topic-based architecture for segmented notifications
- Topics hierarchy:
  - User ID: `user-{userId}` (direct user targeting by ID)
  - User Email: `email-{email_sanitized}` (email with @ replaced by _at_ and . by _dot_)
  - User Topic: Backend-provided personal topic from `/rpc/get_my_user_topic`
  - Drivers: `route-{route_id}-driver`
  - Students: `route-{route_id}-student`, `route-{route_id}-pickup_point-{pickup_id}`
  - Guardians: `route-{route_id}-guardian`, `route-{route_id}-student-{student_id}`
  - Active trips: `trip-{trip_id}`
- Setup in `setupNotifications()` to prevent infinite login loops
- Full documentation: [docs/fcm-notifications.md](docs/fcm-notifications.md)

**Local Storage**:
- LocalStorage package: Token storage ([helpers.dart](lib/controllers/helpers.dart))
- SharedPreferences: User preferences and theme persistence
- Isar: Structured data and entities

## Critical Implementation Notes

### Location Service
- **Singleton**: `LocationService.instance` initialized early in app lifecycle
- **Thread Safety**: Uses `synchronized` package to prevent race conditions in distance calculations
- **Distance Tracking**: Accumulates distance using Haversine formula during active trips
- **Location**: [location_service.dart](lib/shared/location/location_service.dart)
- **Known Issue**: Students not reporting position correctly (TODO.MD #1)

### Notification Service
- **Topic Hierarchy**: user → route-role → trip (most general to most specific)
- **Subscription Tracking**: Internal `topicsList` prevents duplicate subscriptions
- **Login Integration**: MUST call `setupNotifications()` to avoid infinite loops
- **Cleanup**: Call `close()` on logout to unsubscribe from all topics
- **Location**: [notification_service.dart](lib/shared/fcm/notification_service.dart)
- **Known Issue**: Notification settings not persisting (TODO.MD #8)

### Emitter Service
- **Purpose**: Real-time WebSocket communication for live position updates
- **Auto-reconnection**: Monitors connectivity and reconnects automatically
- **Channel Pattern**: Subscription-based publish/subscribe model
- **Location**: [emitter_service.dart](lib/shared/emitterio/emitter_service.dart)

### Theme System
- **Provider**: `ThemeProvider` (`lib/providers/theme_provider.dart`)
- **Persistence**: Automatic saving to SharedPreferences
- **Migration**: Some components still use legacy theme system and need updating
- **Modern approach** (preferred):
  ```dart
  Theme.of(context).scaffoldBackgroundColor
  Theme.of(context).textTheme.titleLarge
  ```
- **Legacy approach** (to be migrated):
  ```dart
  activeTheme.main_bg
  activeTheme.h5
  ```
- **Known Issue**: Dark mode visualization problems (TODO.MD #7)

## Current Task Priorities (from TODO.MD)

### 🚨 High Priority Issues
1. **Student GPS Issues** ([location_service.dart](lib/shared/location/location_service.dart))
   - Students not reporting position correctly
   - Verify GPS precision, update frequency, and server communication

2. **Distance Calculation** ([location_service.dart](lib/shared/location/location_service.dart))
   - Haversine algorithm producing incorrect results
   - Review formula implementation and accumulation logic

3. **Driver Map Interaction** ([trip_page.dart](lib/Pages/trip_page.dart))
   - Map loses centering and touch controls not working
   - Implement mode switching: follow mode vs free exploration mode

4. **Password Recovery** ([login_page.dart](lib/Pages/login_page.dart))
   - Email sending functionality broken
   - Verify API endpoint, email validation, and user feedback

### 🔧 Medium Priority Issues
5. **Driver Position Update Optimization**
   - Sync with Emitter events instead of constant updates
   - Update only when position changes

6. **Bus Icon Label Duplication** ([trip_page.dart](lib/Pages/trip_page.dart))
   - Clear old map annotations before creating new ones
   - Implement annotation existence verification in `_updateIcon()`

7. **Dark Mode Issues**
   - Review color contrast and text visibility
   - Update components not respecting theme

8. **Notification Settings**
   - Verify topic subscription/unsubscription
   - Implement preference persistence

### 📋 Additional Tasks
9. **Map Performance Optimization** - Improve rendering with multiple markers
10. **Offline State Management** - Implement local caching
11. **Unit Tests** - Add tests for critical functionality

### 🎯 Implementation Order (3-Week Plan)
**Week 1 - Critical**:
- Task #4: Password recovery
- Task #1: Student position reporting
- Task #2: Distance calculation

**Week 2 - User Experience**:
- Task #3: Driver map interaction
- Task #5: Label duplication
- Task #6: Position update optimization

**Week 3 - Improvements**:
- Task #7: Dark mode
- Task #8: Notification settings
- Task #9: Performance optimization

## Development Workflow

### Git Branches
- `main`: Production-ready code
- `tareas-pendientes`: Current development branch
- `tareas-pendientes-fix-android`: Android-specific fixes
- Feature branches: `feature/[feature-name]`

### Commit Convention
Use format: `fix: [#numero] descripción breve` for issue-related commits

### Building for Production
1. Clean project: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Run analysis: `flutter analyze`
4. Run tests: `flutter test`
5. Use build script: `./build_app.sh` (interactive menu)

### Environment Configuration

**Required Files**:
- `android/app/google-services.json` - Firebase configuration for Android
- `ios/Runner/GoogleService-Info.plist` - Firebase configuration for iOS

**Required Permissions**:
- Location (foreground & background) - for driver/student tracking
- Camera - for image capture features
- Notifications - for FCM push notifications

**Configuration Points**:
- API Base URL: [helpers.dart:12](lib/controllers/helpers.dart#L12)
- Mapbox Token: [main.dart](lib/main.dart) (currently hardcoded, should use env)
- OneSignal Client ID: [helpers.dart](lib/controllers/helpers.dart) (alternative to FCM)

## Known Issues & Solutions

**Build Issues**:
- **Flutter version**: MUST be exactly 3.19.0 (strict requirement) - Use `flutter downgrade 3.19.0`
- **Dart SDK**: Must be exactly 3.2.0
- **Build failures**: Run `flutter clean` then `flutter pub get`
- **Schema generation**: Run `flutter pub run build_runner build` if Isar entities change
- **Dependency conflicts**: Some dependencies are outdated - update carefully

**Runtime Issues**:
- **Location permissions**: Required for driver/student roles, especially background on Android 10+
- **Notification permissions**: Must be granted for FCM to work
- **Session expiration**: App automatically logs out on 401/403 responses
- **Infinite login loop**: Ensure `setupNotifications()` is called correctly (fixed in commit 9e6d827)

**Database Issues**:
- **Isar version conflicts**: Delete app data and reinstall
- **Schema migrations**: Changes to entity classes require app reinstall or migration code

## Page-Specific Guidance

### Driver Home ([driver_home.dart](lib/Pages/driver_home.dart))
- Loads routes for current day
- Subscribes to `route-{routeId}-driver` FCM topics
- Manages trip start/stop lifecycle
- Key method: `_getDailyRoutes()`
- Subscription point: Line 295

### Students Home ([students_home.dart](lib/Pages/students_home.dart))
- Real-time bus tracking
- Subscribes to `route-{routeId}-student` and pickup point topics
- Displays ETA and trip status
- Key method: `_getStudentData()`
- Subscription points: Lines 299, 304

### Guardians Home ([guardians_home.dart](lib/Pages/guardians_home.dart))
- Multi-student tracking interface
- Subscribes to student-specific topics: `route-{routeId}-student-{studentId}`
- Attendance history viewing
- Key method: `_getParentData()`
- Subscription points: Lines 310, 314, 317

### Trip Page ([trip_page.dart](lib/Pages/trip_page.dart))
- Active trip tracking with live map
- Subscribes to `trip-{tripId}` topic
- Student attendance management
- Known issue: Map interaction controls (#3 in TODO.MD)
- Known issue: Label duplication (#5 in TODO.MD)
- Key method: `_updateIcon()` for map markers
- Subscription point: Line 764

### Login Page ([login_page.dart](lib/Pages/login_page.dart))
- User authentication
- Token management
- Known issue: Password recovery not working (#4 in TODO.MD)

## Testing Approach

### Current Test Coverage
- Widget tests in `test/` directory
- Integration tests in `integration_test/` directory
- Theme testing script: `./test_theme.sh`

### Testing Requirements
- Manual testing required for location-based features
- Integration testing recommended with real devices for GPS functionality
- Test accounts available for each user role

### Before Committing
Always run:
```bash
flutter analyze
flutter test
```

## Debugging Tips

### Location Issues
- Check `LocationService` initialization in [location_service.dart](lib/shared/location/location_service.dart)
- Verify permissions are granted
- Review distance accumulation logic (synchronized block)
- Check GPS accuracy and update frequency

### Notification Issues
- Verify topic subscriptions with FCM logs
- Check `setupNotifications()` is called on login
- Review [docs/fcm-notifications.md](docs/fcm-notifications.md) for topic structure
- Verify permissions granted
- Check Firebase configuration files

### Map Issues
- Check Mapbox token is valid
- Verify EmitterService connection for real-time updates
- Review camera controls in trip_page.dart
- Check for duplicate annotations

### Build Issues
- Verify Flutter version: `flutter --version`
- Clean and rebuild: `flutter clean && flutter pub get`
- Check for Isar schema errors: regenerate with build_runner

## Important File References

**Configuration**:
- [pubspec.yaml](pubspec.yaml) - Dependencies and project metadata
- [main.dart](lib/main.dart) - App entry point with provider setup
- [helpers.dart](lib/controllers/helpers.dart) - Global configuration and constants

**Core Services**:
- [location_service.dart](lib/shared/location/location_service.dart) - GPS tracking
- [notification_service.dart](lib/shared/fcm/notification_service.dart) - FCM notifications
- [emitter_service.dart](lib/shared/emitterio/emitter_service.dart) - Real-time messaging
- [client.dart](lib/API/client.dart) - HTTP API client
- [isar_services.dart](lib/infrastructure/services/isar_services.dart) - Database service
- [theme_provider.dart](lib/providers/theme_provider.dart) - Theme management

**Documentation**:
- [README.md](README.md) - Project overview (Spanish)
- [docs/fcm-notifications.md](docs/fcm-notifications.md) - Notification system guide
- [TODO.MD](TODO.MD) - Current task tracking

**Build**:
- [build_app.sh](build_app.sh) - Interactive build script

## FCM Notification Topics - Quick Reference

### Topic Format Structure
```
user-{userId}                                    # Direct user targeting by ID
email-{email_sanitized}                          # User targeting by email (@ → _at_, . → _dot_)
user-{backend_topic}                             # Backend-provided personal topic
route-{route_id}-driver                          # Drivers on specific route
route-{route_id}-student                         # Students on specific route
route-{route_id}-pickup_point-{pickup_id}        # Specific pickup point
route-{route_id}-guardian                        # Guardians for specific route
route-{route_id}-student-{student_id}            # Specific student updates
trip-{trip_id}                                   # Active trip updates
```

### Subscription Lifecycle
1. **Login**: Subscribe to personal topics:
   - `user-{userId}` - User ID topic
   - `email-{email_sanitized}` - Email-based topic
   - Backend-provided personal topic from API
2. **Load Data**: Subscribe to role-specific topics
3. **Start Trip**: Subscribe to `trip-{trip_id}`
4. **End Trip**: Keep role topics, unsubscribe from trip
5. **Logout**: Unsubscribe from ALL topics via `NotificationService.close()`

## Additional Notes

### Environment Setup Prerequisites
- Flutter SDK 3.19.0 (exact version)
- Android Studio or VS Code with Flutter extension
- Physical device or emulator
- Firebase project with FCM configured
- Mapbox access token

### IDE Configuration - Hide Generated Files

**Android Studio**:
1. Navigate to `Preferences` → `Editor` → `File Types`
2. Add to `Ignore files and folders`: `*.inject.summary;*.inject.dart;*.g.dart;`

**Visual Studio Code**:
1. Navigate to `Settings`
2. Search `Files:Exclude` and add:
```json
{
  "**/*.inject.summary": true,
  "**/*.inject.dart": true,
  "**/*.g.dart": true
}
```

---

*Last updated: January 2025*
*Responsible: Robert Bruno*
*Branch: tareas-pendientes-fix-android*
