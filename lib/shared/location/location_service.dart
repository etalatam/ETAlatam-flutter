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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'package:workmanager/workmanager.dart';
import 'location_callback_handler.dart';
import 'location_service_repository.dart';
import 'package:synchronized/synchronized.dart';

class LocationService extends ChangeNotifier {
  String? domain;

  static Map<String, dynamic>? _locationData;

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

  factory LocationService() {
    print('[LocationService] Getting instance with ID: ${_instance._instanceId}');
    return _instance;
  }
  
  // Campo de instancia para el ID único (no estático)
  late final String _instanceId;
  
  // Obtener el ID de instancia (solo lectura)
  String get instanceId => _instanceId;

  // Modificar el constructor para generar el ID
  LocationService._internal() {
    _instanceId = 'loc-${DateTime.now().millisecondsSinceEpoch}';
    print('[LocationService] Singleton instance created: $_instanceId');
  }

  double get totalDistance => _totalDistance;

  bool _shouldCalculateDistance = true;

  // Contador de posiciones enviadas
  int _positionsSent = 0;
  DateTime? _lastPositionSentTime;
  
  // Getters para acceder al contador
  int get positionsSent => _positionsSent;
  DateTime? get lastPositionSentTime => _lastPositionSentTime;

  // Añadir un lock para prevenir concurrencia
  final _distanceLock = Lock(); // Usar package:async

  static LocationService get instance => _instance;

  init() async {
    if (initialization) {
      print('[LocationService.$_instanceId.init] Already initialized, skipping...');
      return;
    }

    try {
      _userId = await storage.getItem('id_usu');
      
      // Cancelar suscripción existente si existe
      if (_portSubscription != null) {
        print('[LocationService.$_instanceId.init] Canceling existing port subscription...');
        await _portSubscription!.cancel();
        _portSubscription = null;
      }
      
      // Cerrar y recrear el puerto para asegurar un estado limpio
      port.close();
      port = ReceivePort();
      
      // Configurar el puerto de comunicación
      IsolateNameServer.removePortNameMapping(LocationServiceRepository.isolateName);
      IsolateNameServer.registerPortWithName(
        port.sendPort, 
        LocationServiceRepository.isolateName
      );

      // Crear nueva suscripción
      _portSubscription = port.listen((data) {
        print('[LocationService.$_instanceId.listen] Received data: $data');

        if (data != null) {
         trackingDynamic(data); 
        }
      });

      // Inicializar el localizador
      await BackgroundLocator.initialize();
      
      // Configurar Workmanager
      Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
      Workmanager().cancelAll();
      
      initialization = true;
      _startTimer();
      requestDozeModeExclusion();
      
      print('[LocationService.$_instanceId.init] Initialization complete');
      
    } catch (e) {
      print('Initialization error: $e');
      initialization = false;
      _handleServiceError(e);
    }
  }

  void _handleServiceError(dynamic error) async {
    print('Service error: $error');
    if (error is PlatformException) {
      if (error.code == 'SERVICE_NOT_INITIALIZED') {
        await init();
      } else if (error.code == 'PERMISSION_DENIED') {
        await askPermission();
      }
    }
    // stopLocationService();
    // await Future.delayed(Duration(seconds: 2));
    // await startLocationService(calculateDistance: _shouldCalculateDistance);
  }

  void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) {
      final now = DateTime.now();
      final difference = now.difference(_lastPositionDate!);
      print("[LocationService.timer.difference] ${difference.inSeconds}s.");
      if (difference.inSeconds >= 60) {
        print(
            "[LocationService.timer] restaring... [_shouldCalculateDistance: $_shouldCalculateDistance]");
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


  Future<void> startLocationService({bool calculateDistance = false}) async {
    print('[LocationService-$_instanceId.startLocationService] calculateDistance: $calculateDistance');

    // Asegurarse de que los permisos están concedidos
    final hasPermission = await askPermission();
    if (!hasPermission) {
      print('Location permissions denied');
      return;
    }

    // Esperar a que el servicio de ubicación esté disponible
    final serviceEnabled = await Location().serviceEnabled();
    if (!serviceEnabled) {
      final enabled = await Location().requestService();
      if (!enabled) {
        print('Location service disabled');
        return;
      }
    }

    if (!initialization) init();

    try {
      _shouldCalculateDistance = calculateDistance;
      _loadLocalData();
      _saveShouldCalculateDistance();
    } catch (e) {
      //
    }

    var data = <String, dynamic>{
      'countInit': 1,
      'calculateDistance': calculateDistance
    };

    // Configuración mejorada del servicio
    final androidSettings = AndroidSettings(
      accuracy: LocationAccuracy.NAVIGATION,
      distanceFilter: 0,
      client: LocationClient.google,
      androidNotificationSettings: AndroidNotificationSettings(
        notificationChannelName: 'Location tracking',
        notificationTitle: 'Seguimiento de ubicación',
        notificationMsg: 'Seguimiento de la ubicación en segundo plano',
        notificationBigMsg: 'La ubicación en segundo plano está activada para mantener la aplicación actualizada con su ubicación.',
        notificationIcon: 'mipmap/ic_launcher',
        notificationIconColor: Colors.grey,
      ),
    );

    try {
      await BackgroundLocator.registerLocationUpdate(
        LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        iosSettings: const IOSSettings(
          accuracy: LocationAccuracy.NAVIGATION,
          showsBackgroundLocationIndicator: true,
          distanceFilter: 100,
          stopWithTerminate: true,
        ),
        androidSettings: androidSettings,
        autoStop: false,
      );
    } catch (e) {
      print('Error starting location service: $e');
      try {
          // Intentar reiniciar el servicio
        stopLocationService();
        await Future.delayed(Duration(seconds: 1));
        await startLocationService(calculateDistance: calculateDistance);
      } catch (e) {
        //
      }
    }
  }

  Future<bool> askPermission() async {
    print('[LocationService-$_instanceId.askPermission]');
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
    print('[LocationService-$_instanceId.permissionGranted] $permissionGranted');
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await Location().requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('[LocationService-$_instanceId.permissionGranted] $permissionGranted');
        return false;
      }
    }

    return true;
  }

  trackingDynamic(dynamic locationInfo) async {
    print('[LocationService-$_instanceId.trackingDynamic] ${locationInfo.toString()}');

    try {

      _lastPositionDate = DateTime.now();

      // Solo calcular distancia si está habilitado
      await _distanceLock.synchronized(() async {
        if (!_shouldCalculateDistance) return;
        try {
          // Calcular velocidad si existe
          double speed = 0;
          if (locationInfo['speed'] != null) {
            speed = double.tryParse(locationInfo['speed'].toString()) ?? 0;
          }
          
          // Solo calcular distancia si hay movimiento significativo (velocidad > 0.5 m/s)
          if (speed > 0.5) {
            print('[LocationService.trackingDynamic._distanceLock.synchronized] Speed: $speed m/s');
            _calculateDistance(
                locationInfo['latitude'], locationInfo['longitude']);

            print("Total distance: $_totalDistance meters");
          }
        } catch (e) {
          print('[LocationService-$_instanceId.trackingDynamic.distanceCalculation.error] ${e.toString()}');
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
        'time': locationInfo['time'],
        'distance': _totalDistance,
        'background': false
      };
      _locationData = jsonData;
      notifyListeners();
      await httpService.sendTracking(position: jsonData, userId: _userId);
      
      // Incrementar contador de posiciones enviadas
      _positionsSent++;
      _lastPositionSentTime = DateTime.now();
    } catch (e) {
      print('[LocationService.trackingDynamic.error] ${e.toString()}');
    }
  }

  trackingLocationDto(LocationDto locationInfo) async {
    print('[LocationService-$_instanceId.trackingLocationDto] ${locationInfo.toString()}');

    _lastPositionDate = DateTime.now();
    print(
        "[LocationService-$_instanceId.trackingLocationDto] [_shouldCalculateDistance: $_shouldCalculateDistance]");

    // Solo calcular distancia si está habilitado
    await _distanceLock.synchronized(() async {
      if (!_shouldCalculateDistance) return;
      try {
        if (locationInfo.speed > 1) {
          print('[LocationService-$_instanceId.trackingLocationDto._distanceLock.synchronized]');
          _calculateDistance(
              locationInfo.latitude, locationInfo.longitude);
        }
      } catch (e) {
        print('[LocationService-$_instanceId.trackingLocationDto.distanceCalculation.error] ${e.toString()}');
      }
    });

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
    print('[LocationService-$_instanceId.trackingLocationDto.notifyListeners()] [_locationData: $_locationData]');
    await httpService.sendTracking(position: jsonData, userId: _userId);
    
    // Incrementar contador de posiciones enviadas
    _positionsSent++;
    _lastPositionSentTime = DateTime.now();
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
    print('[LocationService-$_instanceId.stopLocationService]');
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
      _shouldCalculateDistance = false;
      _saveDistance();
      _saveShouldCalculateDistance();
      
      // Reset position counter
      _positionsSent = 0;
      _lastPositionSentTime = null;
    } catch (e) {
      print('[LocationService.stopLocationService.error] ${e.toString()}');
    }
  }

  bool _isValidCoordinate(double lat, double lon) {
    return lat >= -90 && lat <= 90 && 
          lon >= -180 && lon <= 180 &&
          !lat.isNaN && !lon.isNaN;
  }

  void _checkAndResetDistance() {
    // Si la distancia acumulada excede un límite razonable (ej. 1000 km)
    if (_totalDistance > 1000 * 1000) { // 1000 km en metros
      _totalDistance = 0;
      _saveDistance();
    }
  }

  double _distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    // Cálculo rápido aproximado
    const double approxFactor = 111319.9; // metros por grado
    return sqrt(pow((lat2 - lat1) * approxFactor, 2) + 
              pow((lon2 - lon1) * approxFactor * cos(_toRadians(lat1)), 2));
  }

  void _saveDistance() async {
    try {
      await storage.setItem('last_calculated_distance', _totalDistance.toString());
    } catch (e) {
      //
    }
  }

  void _saveShouldCalculateDistance() async {
    try {
      await storage.setItem('should_calculate_distance', _shouldCalculateDistance.toString());
    } catch (e) {
      //
    }
  }

  // Al iniciar el servicio
  void _loadLocalData() async {
    
    try {
      String? savedDistance = await storage.getItem('last_calculated_distance');
      if (savedDistance != null) {
      _totalDistance = double.parse(savedDistance);
      } else if (_locationData?['distance'] != null) {
        // Usar valor del servidor como respaldo
        _totalDistance = double.parse(_locationData!['distance'].toString());
      } 
    } catch (e) {
      //
    }

    try {
      String? savedShouldCalculateDistance = await storage.getItem('should_calculate_distance');
      if (savedShouldCalculateDistance != null) {
      _shouldCalculateDistance = bool.parse(savedShouldCalculateDistance);
      } 
    } catch (e) {
      //
    }
  }

  _calculateDistance(double lat2, double lon2) {
    // Validar coordenadas
    if (!_isValidCoordinate(_lastLatitude, _lastLongitude) || !_isValidCoordinate(lat2, lon2)) {
      return 0.0;
    }
    
    // Si es la primera vez, inicializar las coordenadas pero no calcular distancia
    if (_lastLatitude == 0 && _lastLongitude == 0) {
      _lastLatitude = lat2;
      _lastLongitude = lon2;
      return 0.0;
    }
    
    const double earthRadius = 6371000; // Radio de la Tierra en metros

    double dLat = _toRadians(lat2 - _lastLatitude);
    double dLon = _toRadians(lon2 - _lastLongitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(_lastLatitude)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;

    // Solo agregar distancia si es razonable (menos de 500 metros entre actualizaciones)
    // Esto filtra saltos de GPS erróneos
    if (!distance.isNaN && distance >= 0 && distance < 500) {
      _totalDistance += distance;
      _saveDistance(); // Guardar después de cada actualización
      
      print('[LocationService._calculateDistance] Distance added: ${distance.toStringAsFixed(2)}m, Total: ${_totalDistance.toStringAsFixed(2)}m');
    } else if (distance >= 500) {
      print('[LocationService._calculateDistance] Distance ignored (too large): ${distance.toStringAsFixed(2)}m');
    }

    _lastLatitude = lat2;
    _lastLongitude = lon2;

    _checkAndResetDistance();
    
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}
