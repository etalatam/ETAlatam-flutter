import 'dart:async';
import 'dart:math';

import 'package:eta_school_app/controllers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:synchronized/synchronized.dart';

import 'location_resurrector.dart';
import 'robust_location_tracker.dart';
import 'tracking_config.dart';

class LocationService extends ChangeNotifier {
  String? domain;

  static Map<String, dynamic>? _locationData;
  Map<String, dynamic>? get locationData => _locationData;

  String _currentAddress = '';
  String get currentAddress => _currentAddress;

  bool initialization = false;
  int _userId = 0;

  DateTime? _lastPositionDate = DateTime.now();
  double _totalDistance = 0.0;
  double _lastLatitude = 0;
  double _lastLongitude = 0;

  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    debugPrint('[LocationService] Getting instance with ID: ${_instance._instanceId}');
    return _instance;
  }

  late final String _instanceId;
  String get instanceId => _instanceId;

  LocationService._internal() {
    _instanceId = 'loc-${DateTime.now().millisecondsSinceEpoch}';
    debugPrint('[LocationService] Singleton instance created: $_instanceId');
  }

  double get totalDistance => _totalDistance;
  bool _shouldCalculateDistance = false;

  int _positionsSent = 0;
  DateTime? _lastPositionSentTime;

  int get positionsSent => _positionsSent;
  DateTime? get lastPositionSentTime => _lastPositionSentTime;

  final _distanceLock = Lock();

  static LocationService get instance => _instance;

  final RobustLocationTracker _tracker = RobustLocationTracker.instance;

  Future<void> init() async {
    if (initialization) {
      debugPrint('[LocationService.$_instanceId.init] Already initialized, skipping...');
      return;
    }

    try {
      _userId = await storage.getItem('id_usu') ?? 0;

      await _tracker.initialize();

      String? token;
      String? relationName;
      try {
        token = await storage.getItem('token');
        relationName = await storage.getItem('relation_name');
      } catch (e) {
        debugPrint('[LocationService] Could not get user data from storage: $e');
      }

      if (token == null || token.isEmpty) {
        debugPrint('[LocationService] No authenticated user - skipping tracker init');
      } else {
        if (relationName == 'eta.students') {
          debugPrint('[LocationService] Student role detected - will initialize tracker');
        } else if (relationName == 'eta.drivers') {
          debugPrint('[LocationService] Driver role detected - tracker will init on trip start');
        } else if (relationName == 'eta.guardians') {
          debugPrint('[LocationService] Guardian role detected - tracker not needed');
        }
      }

      initialization = true;
      debugPrint('[LocationService.$_instanceId.init] Initialization complete');
    } catch (e) {
      debugPrint('[LocationService] Initialization error: $e');
      initialization = false;
    }
  }

  Future<void> reinitializeAfterLogin() async {
    debugPrint('[LocationService] Reinitializing after login...');

    String? relationName;
    try {
      relationName = await storage.getItem('relation_name');
    } catch (e) {
      debugPrint('[LocationService] Could not get relation_name after login: $e');
      return;
    }

    if (relationName == 'eta.students') {
      debugPrint('[LocationService] Student logged in - tracker ready');
    } else if (relationName == 'eta.drivers') {
      debugPrint('[LocationService] Driver logged in - will init tracker on trip start');
    } else if (relationName == 'eta.guardians') {
      debugPrint('[LocationService] Guardian logged in - no location tracking needed');
    }
  }

  Future<void> startLocationService({bool calculateDistance = false}) async {
    debugPrint('[LocationService-$_instanceId.startLocationService] calculateDistance: $calculateDistance');

    if (!initialization) {
      await init();
    }

    try {
      _shouldCalculateDistance = calculateDistance;
      _loadLocalData();
      _saveShouldCalculateDistance();
    } catch (e) {
      debugPrint('[LocationService] Error loading local data: $e');
    }

    final hasPermissions = await _tracker.requestAllPermissions();
    if (!hasPermissions) {
      debugPrint('[LocationService] Permissions not granted');
      return;
    }

    String? relationName;
    try {
      relationName = await storage.getItem('relation_name');
    } catch (e) {
      debugPrint('[LocationService] Error getting relation_name: $e');
    }

    final config = TrackingConfig.forRole(relationName, isTestMode: true);
    debugPrint('[LocationService] Usando config para rol: ${config.roleName} - interval: ${config.sendInterval.inSeconds}s');

    await _tracker.startTracking(
      onPositionUpdate: _handlePositionUpdate,
      config: config,
    );

    await LocationResurrector.instance.startPeriodicCheck();

    debugPrint('[LocationService] Location service started successfully');
  }

  void _handlePositionUpdate(Map<String, dynamic> locationInfo) {
    trackingDynamic(locationInfo);
  }

  Future<void> trackingDynamic(Map<String, dynamic> locationInfo) async {
    debugPrint('[LocationService-$_instanceId.trackingDynamic] ${locationInfo.toString()}');

    try {
      String? relationName = await storage.getItem('relation_name');

      if (relationName == 'eta.drivers') {
        String? hasActiveTrip = await storage.getItem('has_active_trip');
        if (hasActiveTrip != 'true') {
          debugPrint('[LocationService.trackingDynamic] Driver sin viaje activo, deteniendo tracking');
          stopLocationService();
          return;
        }
      }

      _lastPositionDate = DateTime.now();

      await _distanceLock.synchronized(() async {
        if (!_shouldCalculateDistance) return;
        try {
          double speed = 0;
          if (locationInfo['speed'] != null) {
            speed = double.tryParse(locationInfo['speed'].toString()) ?? 0;
          }

          if (speed > 0.5) {
            debugPrint('[LocationService.trackingDynamic] Speed: $speed m/s');
            _calculateDistance(
              locationInfo['latitude'] ?? 0,
              locationInfo['longitude'] ?? 0,
            );
            debugPrint('Total distance: ${_totalDistance.toStringAsFixed(2)} meters');
          }
        } catch (e) {
          debugPrint('[LocationService.trackingDynamic.distanceCalculation.error] $e');
        }
      });

      _lastLatitude = locationInfo['latitude'] ?? 0;
      _lastLongitude = locationInfo['longitude'] ?? 0;

      final jsonData = {
        'latitude': locationInfo['latitude'],
        'longitude': locationInfo['longitude'],
        'altitude': locationInfo['altitude'],
        'accuracy': locationInfo['accuracy'],
        'heading': locationInfo['heading'],
        'speed': locationInfo['speed'],
        'speedAccuracy': locationInfo['speedAccuracy'],
        'time': locationInfo['time'],
        'distance': _totalDistance,
        'background': locationInfo['background'] ?? true,
      };

      _locationData = jsonData;
      notifyListeners();

      await httpService.sendTracking(position: jsonData, userId: _userId);
      debugPrint('[LocationService] Position sent with distance: ${_totalDistance.toStringAsFixed(2)} m');

      _positionsSent++;
      _lastPositionSentTime = DateTime.now();
    } catch (e) {
      debugPrint('[LocationService.trackingDynamic.error] $e');
    }
  }

  Future<void> stopLocationService({bool preserveCounters = false}) async {
    debugPrint('[LocationService-$_instanceId.stopLocationService]');
    debugPrint('[LocationService] Stopping service - Total distance: ${_totalDistance.toStringAsFixed(2)} m');

    try {
      await _tracker.stopTracking(preserveCounters: preserveCounters);

      if (!preserveCounters) {
        _totalDistance = 0;
        _lastLatitude = 0;
        _lastLongitude = 0;
        _shouldCalculateDistance = false;
        _saveDistance();
        _saveShouldCalculateDistance();

        _positionsSent = 0;
        _lastPositionSentTime = null;

        await LocationResurrector.instance.stopPeriodicCheck();
      }

      initialization = false;
    } catch (e) {
      debugPrint('[LocationService.stopLocationService.error] $e');
    }
  }

  Future<bool> askPermission() async {
    debugPrint('[LocationService-$_instanceId.askPermission]');
    return await _tracker.requestAllPermissions();
  }

  bool _isValidCoordinate(double lat, double lon) {
    return lat >= -90 &&
        lat <= 90 &&
        lon >= -180 &&
        lon <= 180 &&
        !lat.isNaN &&
        !lon.isNaN;
  }

  void _checkAndResetDistance() {
    if (_totalDistance > 1000 * 1000) {
      _totalDistance = 0;
      _saveDistance();
    }
  }

  void _saveDistance() async {
    try {
      await storage.setItem('last_calculated_distance', _totalDistance.toString());
      debugPrint('[LocationService] Saved distance: ${_totalDistance.toStringAsFixed(2)} m');
    } catch (e) {
      debugPrint('[LocationService] Error saving distance: $e');
    }
  }

  void _saveShouldCalculateDistance() async {
    try {
      await storage.setItem('should_calculate_distance', _shouldCalculateDistance.toString());
    } catch (e) {
      debugPrint('[LocationService] Error saving shouldCalculateDistance: $e');
    }
  }

  void _loadLocalData() async {
    try {
      String? savedDistance = await storage.getItem('last_calculated_distance');
      if (savedDistance != null && _shouldCalculateDistance) {
        _totalDistance = double.parse(savedDistance);
        debugPrint('[LocationService] Loaded saved distance: ${_totalDistance.toStringAsFixed(2)} m');
      } else {
        _totalDistance = 0;
        debugPrint('[LocationService] Starting with distance: 0 m');
      }
    } catch (e) {
      _totalDistance = 0;
      debugPrint('[LocationService] Error loading distance: $e');
    }

    try {
      String? savedShouldCalculateDistance =
          await storage.getItem('should_calculate_distance');
      if (savedShouldCalculateDistance != null) {
        _shouldCalculateDistance = bool.parse(savedShouldCalculateDistance);
      }
    } catch (e) {
      debugPrint('[LocationService] Error loading shouldCalculateDistance: $e');
    }
  }

  void _calculateDistance(double lat2, double lon2) {
    if (!_isValidCoordinate(_lastLatitude, _lastLongitude) ||
        !_isValidCoordinate(lat2, lon2)) {
      debugPrint('[LocationService._calculateDistance] Invalid coordinates');
      return;
    }

    if (_lastLatitude == 0 && _lastLongitude == 0) {
      _lastLatitude = lat2;
      _lastLongitude = lon2;
      debugPrint('[LocationService._calculateDistance] First position initialized');
      return;
    }

    const double earthRadius = 6371000;

    double lat1Rad = _toRadians(_lastLatitude);
    double lat2Rad = _toRadians(lat2);
    double deltaLat = _toRadians(lat2 - _lastLatitude);
    double deltaLon = _toRadians(lon2 - _lastLongitude);

    double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLon / 2) * sin(deltaLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    if (!distance.isNaN && distance >= 2 && distance < 200) {
      _totalDistance += distance;
      _saveDistance();
      debugPrint(
          '[LocationService._calculateDistance] Distance added: ${distance.toStringAsFixed(2)}m, Total: ${_totalDistance.toStringAsFixed(2)}m');
    } else if (distance < 2) {
      debugPrint(
          '[LocationService._calculateDistance] Distance ignored (too small/noise): ${distance.toStringAsFixed(2)}m');
    } else if (distance >= 200) {
      debugPrint(
          '[LocationService._calculateDistance] Distance ignored (GPS jump): ${distance.toStringAsFixed(2)}m');
    }

    if (distance < 200) {
      _lastLatitude = lat2;
      _lastLongitude = lon2;
    }

    _checkAndResetDistance();
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  bool get isTracking => _tracker.isTracking;
}
