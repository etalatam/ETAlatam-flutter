import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:android_intent_plus/android_intent.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:workmanager/workmanager.dart';
import 'location_callback_handler.dart';
import 'location_service_repository.dart';

class LocationService extends ChangeNotifier {
  String? domain;

  Map<String, dynamic>? _locationData;

  Map<String, dynamic>? get locationData => _locationData;

  String _currentAddress = '';

  String get currentAddress => _currentAddress;

  ReceivePort port = ReceivePort();

  bool initialization = false;

  int _userId = 0;

  Timer? _timer;

  DateTime? _lastPositionDate = DateTime.now();

  double _totalDistance = 0.0;

  double _lastLatitude = 0;

  double _lastLongitude = 0;

  StreamSubscription? _portSubscription;

  static final LocationService _instance = LocationService._internal();

  factory LocationService() => _instance;

  LocationService._internal();

  double get totalDistance => _totalDistance;

  bool _shouldCalculateDistance = false;

  init() async {
    print("[LocationService.init]");
    _userId = await storage.getItem('id_usu');

    if (_timer == null) {
      _startTimer();
    }

    askPermission().then((value) async {
      print("[LocationService.askPermission.callback] $value");
      if (value) {
        if (!initialization) {
          print('[LocationService.initialization...]');

          try {
            try {
              // Clean up any existing port mapping and subscription
              if (IsolateNameServer.lookupPortByName(
                      LocationServiceRepository.isolateName) !=
                  null) {
                print(
                    '[LocationService.removePortNameMapping] ${LocationServiceRepository.isolateName}');
                IsolateNameServer.removePortNameMapping(
                    LocationServiceRepository.isolateName);
              }
            } catch (e) {
              //
            }

            try {
              // Cancel any existing subscription
              await _portSubscription?.cancel();
              _portSubscription = null;
            } catch (e) {
              //
            }

            try {
              IsolateNameServer.registerPortWithName(
                  port.sendPort, LocationServiceRepository.isolateName);
            } catch (e) {
              //
            }

            // Set up new listener
            _portSubscription = port.listen((dynamic data) async {
              print('[LocationService.port.listen.callback] $data');
              if (data != null &&
                  (_locationData?['latitude'] != data['latitude']) &&
                  (_locationData?['longitude'] != data['longitude'])) {
                _locationData = data;
                try {
                  _lastPositionDate = DateTime.now();
                  await trackingDynamic(_locationData);
                  notifyListeners();
                } catch (e) {
                  print(
                      '[LocationService.notifyListeners.error] ${e.toString()}');
                }
              }
            });

            BackgroundLocator.initialize();
            initialization = true;
            Workmanager().initialize(
              callbackDispatcher,
              isInDebugMode: true,
            );
            Workmanager().cancelAll();
            Workmanager().registerPeriodicTask(
              "1",
              "simplePeriodicTask",
              frequency: Duration(minutes: 15),
            );

            requestDozeModeExclusion();
            print("[LocationService._startTimer]");
          } catch (e) {
            print('[LocationService.init.error] $e');
          }
        } else {
          print('[LocationService.init] already initialized');
        }
      }
    });
  }

  void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) {
      final now = DateTime.now();
      final difference = now.difference(_lastPositionDate!);
      print("[LocationService.timer.difference] ${difference.inSeconds}s.");
      if (difference.inSeconds >= 60) {
        print("[LocationService.timer] restaring... ");
        _lastPositionDate = DateTime.now();
        stopLocationService();
        startLocationService(calculateDistance: _shouldCalculateDistance);
      }
      return Future.value(true);
    });
  }

  void requestDozeModeExclusion() {
    final AndroidIntent intent = AndroidIntent(
      action: 'action_request_ignore_battery_optimizations',
      data: 'package:com.etalatam.schoolapp',
    );
    intent.launch();
  }

  // saveLastPosition(data) async {
  //     await storage.setItem('lastPosition', data);
  // }

  Future<void> startLocationService({bool calculateDistance = false}) async {
    print('[LocationService.startLocationService]');
    _shouldCalculateDistance =
        calculateDistance; // Establecer si se debe calcular la distancia
    var data = <String, dynamic>{'countInit': 1};
    final relationNameLocal = await storage.getItem('relation_name');

    init();

    return await BackgroundLocator.registerLocationUpdate(
        LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        iosSettings: const IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            showsBackgroundLocationIndicator: true,
            distanceFilter: 100,
            stopWithTerminate: true),
        autoStop: false,
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            // interval: relationNameLocal.contains('eta.drivers') ? 5 : 10,
            distanceFilter: 0,
            client: LocationClient.google,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Seguimiento de ubicación',
                notificationMsg: 'Seguimiento de la ubicación en segundo plano',
                notificationBigMsg:
                    'La ubicación en segundo plano está activada para mantener la aplicación actualizada con su ubicación. Esto es necesario para el seguimiento en vivo.',
                // notificationIconColor: Colors.grey,
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
  }

  Future<bool> askPermission() async {
    print('[LocationService.askPermission]');
    PermissionStatus permissionGranted;
    bool serviceEnabled;

    serviceEnabled = await Location().serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Location().requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    permissionGranted = await Location().hasPermission();
    print('[LocationService.permissionGranted] $permissionGranted');
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await Location().requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('[LocationService.permissionGranted] $permissionGranted');
        return false;
      }
    }

    return true;
  }

  trackingDynamic(dynamic locationInfo) async {
    print('[LocationService.trackingDynamic] ${locationInfo.toString()}');

    try {
      final now = DateTime.now();
      // final difference = now.difference(_lastPositionDate!);

      // Verificar si la posición es diferente y si el tiempo es mayor a 5 segundos
      if ((_locationData?['latitude'] != locationInfo['latitude'] ||
              _locationData?['longitude'] != locationInfo['longitude'])
              //  && difference.inSeconds > 5
          ) {
        _lastPositionDate = now;

        if (_shouldCalculateDistance) {
          // Solo calcular distancia si está habilitado
          try {
            if (double.parse(_locationData?['speed'] ?? '0') > 0.5) {
              _totalDistance += _calculateDistance(
                  _lastLatitude,
                  _lastLongitude,
                  locationInfo['latitude'],
                  locationInfo['longitude']);
            }
          } catch (e) {
            print(
                '[LocationService.distanceCalculation.error] ${e.toString()}');
          }
        }

        _lastLatitude = locationInfo['latitude'];
        _lastLongitude = locationInfo['longitude'];

        final jsonData = {
          'latitude': locationInfo['latitude'],
          'longitude': locationInfo['longitude'],
          'altitude': locationInfo['altitude'],
          'accuracy': locationInfo['accuracy'],
          'heading': locationInfo['heading'],
          'time': locationInfo['time'],
          'distance': _totalDistance,
          'background': false
        };

        await httpService.sendTracking(position: jsonData, userId: _userId);
      } else {
        print('[LocationService.trackingDynamic.some location]');
      }
    } catch (e) {
      print('[LocationService.trackingDynamic.error] ${e.toString()}');
    }
  }

  trackingLocationDto(LocationDto locationInfo) async {
    print('[LocationService.trackingLocationDto] ${locationInfo.toString()}');

    final now = DateTime.now();
    // final difference = now.difference(_lastPositionDate!);

    // Verificar si la posición es diferente y si el tiempo es mayor a 5 segundos
    if ((_locationData?['latitude'] != locationInfo.latitude ||
            _locationData?['longitude'] != locationInfo.longitude) 
            // && difference.inSeconds > 5
        ) {
      _lastPositionDate = now;
      if (_shouldCalculateDistance) {
        // Solo calcular distancia si está habilitado
        try {
          if (locationInfo.speed > 1) {
            _totalDistance += _calculateDistance(_lastLatitude, _lastLongitude,
                locationInfo.latitude, locationInfo.longitude);
          }
        } catch (e) {
          print('[LocationService.distanceCalculation.error] ${e.toString()}');
        }
      }

      final jsonData = {
        'latitude': locationInfo.latitude,
        'longitude': locationInfo.longitude,
        'altitude': locationInfo.altitude,
        'accuracy': locationInfo.accuracy,
        'speed': locationInfo.speed,
        'speedAccuracy': locationInfo.speedAccuracy,
        'heading': locationInfo.heading,
        'time': locationInfo.time,
        'distance': _totalDistance,
        'background': true
      };

      _locationData = jsonData;
      notifyListeners();
      await httpService.sendTracking(position: jsonData, userId: _userId);
    }
    
    _lastLatitude = locationInfo.latitude;
    _lastLongitude = locationInfo.longitude;

  }

  void _startTimer() async {
    final relationNameLocal = await storage.getItem('relation_name');

    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      final now = DateTime.now();
      final difference = now.difference(_lastPositionDate!);
      print("[LocationService.timer.difference] ${difference.inSeconds}s.");
      final max = relationNameLocal.contains('eta.drivers') ? 20 : 30;
      if (difference.inSeconds >= max) {
        print("[LocationService.timer] restaring... ");
        _lastPositionDate = DateTime.now();
        stopLocationService();
        startLocationService();
      }
    });
  }

  void stopLocationService() {
    print('[LocationService.stopLocationService]');
    try {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);

      // Cancel the port subscription
      _portSubscription?.cancel();
      _portSubscription = null;

      BackgroundLocator.unRegisterLocationUpdate();

      if (IsolateNameServer.lookupPortByName(
              LocationServiceRepository.isolateName) !=
          null) {
        IsolateNameServer.removePortNameMapping(
            LocationServiceRepository.isolateName);
      }

      initialization = false;
      _timer?.cancel();
      Workmanager().cancelAll();
      _totalDistance = 0;
    } catch (e) {
      print('[LocationService.stopLocationService.error] ${e.toString()}');
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // Radio de la Tierra en metros

    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    _lastLatitude = lat2;
    _lastLongitude = lon2;

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}
