# Quick Start - Fastlane Screenshot Automation

## Generate Screenshots (Local)

```bash
cd /Users/remote/workspace/eta/ETAlatam-flutter/ios
bundle exec fastlane screenshots
```

## View Screenshots

```bash
open ../screenshots/fastlane/screenshots.html
```

## Upload to App Store

```bash
bundle exec fastlane upload_screenshots
```

## Test Credentials

- **Conductor:** conductor4@gmail.com / casa1234
- **Guardian:** etalatam+representante1@gmail.com / casa1234

## Files to Modify

### Add More Devices
Edit: `ios/fastlane/Snapfile` - `devices([...])`

### Add More Languages
Edit: `ios/fastlane/Snapfile` - `languages([...])`

### Customize Screenshots
Edit: `ios/RunnerUITests/ScreenshotTests.swift`

## Troubleshooting

### Reset Simulators
```bash
xcrun simctl shutdown all
xcrun simctl erase all
```

### Clean Build
```bash
flutter clean
flutter pub get
cd ios && pod install
```

### View Full Logs
```bash
cat ios/fastlane/report.xml
```

## Documentation

- Full Implementation: `screenshots/FASTLANE_IMPLEMENTATION_COMPLETE.md`
- Task Plan: `screenshots/PLAN_DE_IMPLEMENTACION.md`
- Status: `screenshots/SCREENSHOT_AUTOMATION_STATUS.md`
