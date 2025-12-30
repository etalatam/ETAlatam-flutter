import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

class LocationTaskHandler extends TaskHandler {
  StreamSubscription<Position>? _positionSubscription;
  
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('[LocationTaskHandler] onStart - ${timestamp.toIso8601String()}');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    debugPrint('[LocationTaskHandler] onRepeatEvent - ${timestamp.toIso8601String()}');
    FlutterForegroundTask.sendDataToMain({'event': 'heartbeat', 'timestamp': timestamp.toIso8601String()});
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    debugPrint('[LocationTaskHandler] onDestroy');
    await _positionSubscription?.cancel();
  }

  @override
  void onReceiveData(Object data) {
    debugPrint('[LocationTaskHandler] onReceiveData: $data');
  }
}

class RobustLocationTracker extends ChangeNotifier {
  static final RobustLocationTracker _instance = RobustLocationTracker._internal();
  static RobustLocationTracker get instance => _instance;
  
  factory RobustLocationTracker() => _instance;
  
  RobustLocationTracker._internal() {
    _instanceId = 'tracker-${DateTime.now().millisecondsSinceEpoch}';
    debugPrint('[RobustLocationTracker] Instance created: $_instanceId');
  }

  late final String _instanceId;
  String get instanceId => _instanceId;

  StreamSubscription<Position>? _positionSubscription;
  Function(Map<String, dynamic>)? _onPositionUpdate;
  bool _isTracking = false;
  bool _isInitialized = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  
  DateTime? _lastPositionTime;
  Timer? _healthCheckTimer;
  int _distanceFilter = 10;

  bool get isTracking => _isTracking;
  bool get isInitialized => _isInitialized;
  DateTime? get lastPositionTime => _lastPositionTime;

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('[RobustLocationTracker] Already initialized');
      return;
    }

    FlutterForegroundTask.initCommunicationPort();
    
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'eta_location_channel',
        channelName: 'Seguimiento de ubicación',
        channelDescription: 'Seguimiento en segundo plano esta activo para mantener su ubicación actualizada',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        visibility: NotificationVisibility.VISIBILITY_PUBLIC,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(30000),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: false,
        allowWifiLock: false,
      ),
    );

    _isInitialized = true;
    debugPrint('[RobustLocationTracker] Initialized successfully');
  }

  Future<PermissionStatus> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.deniedForever) {
      return PermissionStatus.permanentlyDenied;
    }
    
    if (permission == LocationPermission.whileInUse || 
        permission == LocationPermission.always) {
      return PermissionStatus.granted;
    }
    
    return PermissionStatus.denied;
  }

  Future<PermissionStatus> requestBackgroundLocationPermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.locationAlways.status;
      if (!status.isGranted) {
        status = await Permission.locationAlways.request();
      }
      debugPrint('[RobustLocationTracker] Background location permission: $status');
      return status;
    }
    return PermissionStatus.granted;
  }

  Future<bool> requestBatteryOptimizationExclusion() async {
    if (Platform.isAndroid) {
      var status = await Permission.ignoreBatteryOptimizations.status;
      if (!status.isGranted) {
        status = await Permission.ignoreBatteryOptimizations.request();
      }
      debugPrint('[RobustLocationTracker] Battery optimization exclusion: $status');
      return status.isGranted;
    }
    return true;
  }

  Future<bool> requestAllPermissions() async {
    debugPrint('[RobustLocationTracker] Requesting all permissions...');
    
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('[RobustLocationTracker] Location services disabled');
      return false;
    }

    final locationStatus = await requestLocationPermission();
    if (!locationStatus.isGranted) {
      debugPrint('[RobustLocationTracker] Location permission denied');
      return false;
    }

    await requestBackgroundLocationPermission();
    await requestBatteryOptimizationExclusion();
    
    if (Platform.isAndroid) {
      final notificationPermission = await FlutterForegroundTask.checkNotificationPermission();
      if (notificationPermission != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }
    }

    debugPrint('[RobustLocationTracker] All permissions requested');
    return true;
  }

  Future<void> startTracking({
    required Function(Map<String, dynamic>) onPositionUpdate,
    int distanceFilter = 10,
  }) async {
    if (_isTracking) {
      debugPrint('[RobustLocationTracker] Already tracking, restarting stream...');
      await restartStream();
      return;
    }

    _onPositionUpdate = onPositionUpdate;
    _distanceFilter = distanceFilter;

    if (!_isInitialized) {
      await initialize();
    }

    final hasPermissions = await requestAllPermissions();
    if (!hasPermissions) {
      debugPrint('[RobustLocationTracker] Permissions not granted');
      return;
    }

    await _startForegroundService();
    await _startLocationStream();
    _startHealthCheck();

    _isTracking = true;
    _retryCount = 0;
    notifyListeners();
    
    debugPrint('[RobustLocationTracker] Tracking started successfully');
  }

  Future<void> _startForegroundService() async {
    if (await FlutterForegroundTask.isRunningService) {
      debugPrint('[RobustLocationTracker] Foreground service already running');
      return;
    }

    try {
      await FlutterForegroundTask.startService(
        serviceId: 256,
        notificationTitle: 'Ubicación activa',
        notificationText: 'Compartiendo ubicación en tiempo real',
        notificationIcon: null,
        callback: startCallback,
      );
      debugPrint('[RobustLocationTracker] Foreground service started');
    } catch (e) {
      debugPrint('[RobustLocationTracker] Error starting foreground service: $e');
      rethrow;
    }
  }

  Future<void> _startLocationStream() async {
    await _positionSubscription?.cancel();

    try {
      late LocationSettings locationSettings;

      if (Platform.isAndroid) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: _distanceFilter,
          forceLocationManager: false,
          intervalDuration: const Duration(seconds: 10),
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: 'Ubicación activa',
            notificationText: 'Compartiendo ubicación en tiempo real',
            notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
            enableWakeLock: false,
          ),
        );
      } else if (Platform.isIOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: _distanceFilter,
          activityType: ActivityType.automotiveNavigation,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true,
          allowBackgroundLocationUpdates: true,
        );
      } else {
        locationSettings = LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: _distanceFilter,
        );
      }

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        _handlePositionUpdate,
        onError: _handleStreamError,
        cancelOnError: false,
      );

      debugPrint('[RobustLocationTracker] Location stream started');
    } catch (e) {
      debugPrint('[RobustLocationTracker] Error starting location stream: $e');
      _handleStreamError(e);
    }
  }

  void _handlePositionUpdate(Position position) {
    _lastPositionTime = DateTime.now();
    _retryCount = 0;

    final locationData = {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'altitude': position.altitude,
      'accuracy': position.accuracy,
      'heading': position.heading,
      'speed': position.speed,
      'speedAccuracy': position.speedAccuracy,
      'time': position.timestamp.millisecondsSinceEpoch.toDouble(),
      'background': true,
      'source': 'robust_tracker',
    };

    debugPrint('[RobustLocationTracker] Position: ${position.latitude}, ${position.longitude} | Speed: ${position.speed.toStringAsFixed(2)} m/s');
    
    _onPositionUpdate?.call(locationData);
    notifyListeners();
  }

  void _handleStreamError(dynamic error) async {
    debugPrint('[RobustLocationTracker] Stream error: $error');

    if (_retryCount < _maxRetries) {
      _retryCount++;
      final delay = Duration(seconds: 5 * _retryCount);
      debugPrint('[RobustLocationTracker] Retry $_retryCount/$_maxRetries in ${delay.inSeconds}s');
      
      await Future.delayed(delay);
      
      if (_isTracking) {
        await _startLocationStream();
      }
    } else {
      debugPrint('[RobustLocationTracker] Max retries reached, stopping tracking');
    }
  }

  void _startHealthCheck() {
    _healthCheckTimer?.cancel();

    _healthCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!_isTracking) {
        timer.cancel();
        return;
      }

      // Verificar si el Foreground Service está realmente corriendo (Android)
      if (Platform.isAndroid) {
        try {
          final isServiceRunning = await FlutterForegroundTask.isRunningService;
          if (!isServiceRunning) {
            debugPrint('[RobustLocationTracker] ⚠️ Health check: Service NOT running! Restarting...');
            _isTracking = false;  // Sincronizar estado
            await _startForegroundService();
            await _startLocationStream();
            _isTracking = true;
            notifyListeners();
            return;
          }
        } catch (e) {
          debugPrint('[RobustLocationTracker] Error checking service status: $e');
        }
      }

      // Verificar si hay posiciones recientes
      final timeSinceLastPosition = _lastPositionTime != null
          ? DateTime.now().difference(_lastPositionTime!)
          : const Duration(minutes: 5);

      if (timeSinceLastPosition.inSeconds > 60) {
        debugPrint('[RobustLocationTracker] Health check: No position in ${timeSinceLastPosition.inSeconds}s, restarting stream...');
        await restartStream();
      } else {
        debugPrint('[RobustLocationTracker] Health check: OK (${timeSinceLastPosition.inSeconds}s since last position)');
      }
    });
  }

  Future<void> restartStream() async {
    debugPrint('[RobustLocationTracker] Restarting location stream...');
    _retryCount = 0;
    await _startLocationStream();
  }

  Future<void> stopTracking({bool preserveCounters = false}) async {
    debugPrint('[RobustLocationTracker] Stopping tracking...');
    
    _isTracking = false;
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
        debugPrint('[RobustLocationTracker] Foreground service stopped');
      }
    } catch (e) {
      debugPrint('[RobustLocationTracker] Error stopping foreground service: $e');
    }

    if (!preserveCounters) {
      _lastPositionTime = null;
      _retryCount = 0;
    }

    notifyListeners();
    debugPrint('[RobustLocationTracker] Tracking stopped');
  }

  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('[RobustLocationTracker] Error getting current position: $e');
      return null;
    }
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
