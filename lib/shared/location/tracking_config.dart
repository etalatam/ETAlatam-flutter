import 'package:geolocator/geolocator.dart';

class TrackingConfig {
  final Duration sendInterval;
  final Duration healthCheckInterval;
  final Duration healthCheckThreshold;
  final int distanceFilter;
  final LocationAccuracy accuracy;
  final bool requiresActiveTrip;
  final String roleName;

  const TrackingConfig({
    required this.sendInterval,
    required this.healthCheckInterval,
    required this.healthCheckThreshold,
    required this.distanceFilter,
    required this.accuracy,
    required this.requiresActiveTrip,
    required this.roleName,
  });

  static const driver = TrackingConfig(
    sendInterval: Duration(seconds: 10),
    healthCheckInterval: Duration(seconds: 60),
    healthCheckThreshold: Duration(seconds: 30),
    distanceFilter: 5,
    accuracy: LocationAccuracy.best,
    requiresActiveTrip: true,
    roleName: 'eta.drivers',
  );

  static const studentTest = TrackingConfig(
    sendInterval: Duration(seconds: 10),
    healthCheckInterval: Duration(seconds: 60),
    healthCheckThreshold: Duration(seconds: 30),
    distanceFilter: 5,
    accuracy: LocationAccuracy.high,
    requiresActiveTrip: false,
    roleName: 'eta.students',
  );

  static const studentProd = TrackingConfig(
    sendInterval: Duration(minutes: 5),
    healthCheckInterval: Duration(minutes: 10),
    healthCheckThreshold: Duration(minutes: 6),
    distanceFilter: 50,
    accuracy: LocationAccuracy.medium,
    requiresActiveTrip: false,
    roleName: 'eta.students',
  );

  static TrackingConfig forRole(String? roleName, {bool isTestMode = true}) {
    switch (roleName) {
      case 'eta.drivers':
        return driver;
      case 'eta.students':
        return isTestMode ? studentTest : studentProd;
      default:
        return studentTest;
    }
  }
}
