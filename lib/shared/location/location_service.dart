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

  bool _shouldCalculateDistance = false;  // Por defecto false, solo true para conductores con viaje activo

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

      // Inicializar el localizador solo para roles que lo necesitan
      // Primero verificar si hay un usuario autenticado
      String? token;
      String? relationName;
      try {
        token = await storage.getItem('token');
        relationName = await storage.getItem('relation_name');
      } catch (e) {
        print('[LocationService] Could not get user data from storage: $e');
      }

      // Si no hay token, el usuario no está autenticado, no inicializar nada
      if (token == null || token.isEmpty) {
        print('[LocationService] No authenticated user - skipping BackgroundLocator init');
        print('[LocationService] Will initialize after login if needed for the user role');
        // NO inicializar BackgroundLocator hasta que el usuario haga login
      } else {
        // Solo inicializar para conductores con viaje activo o estudiantes
        // Los guardianes (eta.guardians) no necesitan tracking GPS
        bool shouldInitializeLocator = false;

        if (relationName != null && relationName.isNotEmpty) {
          if (relationName == 'eta.students') {
            // Los estudiantes necesitan tracking
            shouldInitializeLocator = true;
            print('[LocationService] Student role detected - will initialize locator');
          } else if (relationName == 'eta.drivers') {
            // Los conductores solo lo necesitan con viaje activo
            // Esto se inicializará cuando comience un viaje
            shouldInitializeLocator = false;
            print('[LocationService] Driver role detected - locator will init on trip start');
          } else if (relationName == 'eta.guardians') {
            // Los guardianes/representantes NO necesitan tracking
            shouldInitializeLocator = false;
            print('[LocationService] Guardian role detected - locator not needed');
          }
        } else {
          print('[LocationService] User authenticated but no role found - defaulting to no tracking');
        }

        if (shouldInitializeLocator) {
          try {
            await BackgroundLocator.initialize();
            print('[LocationService] BackgroundLocator initialized successfully');
          } catch (e) {
            print('[LocationService] Error initializing BackgroundLocator: $e');
            // Continuar sin el servicio si falla (ej: Android 15)
          }
        }
      }
      
      // Configurar Workmanager (comentado temporalmente por incompatibilidad con Android 14+)
      // Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
      // Workmanager().cancelAll();

      initialization = true;
      _startTimer();

      // Solicitar exclusión del modo Doze (solo si hay una Activity disponible)
      try {
        requestDozeModeExclusion();
      } catch (e) {
        print('[LocationService] Could not request doze mode exclusion: $e');
        // Continuar sin la exclusión - no es crítico
      }
      
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
      // print("[LocationService.timer.difference] ${difference.inSeconds}s.");
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

  /// Reinitialize location service after login if needed for the user role
  Future<void> reinitializeAfterLogin() async {
    print('[LocationService] Reinitializing after login...');

    // Get user role from storage
    String? relationName;
    try {
      relationName = await storage.getItem('relation_name');
    } catch (e) {
      print('[LocationService] Could not get relation_name after login: $e');
      return;
    }

    // Only initialize for students (drivers will init on trip start)
    if (relationName == 'eta.students') {
      print('[LocationService] Student logged in - initializing BackgroundLocator');
      try {
        // Check if already running
        bool isRunning = await BackgroundLocator.isServiceRunning();
        if (!isRunning) {
          await BackgroundLocator.initialize();
          print('[LocationService] BackgroundLocator initialized for student after login');
        } else {
          print('[LocationService] BackgroundLocator already running');
        }
      } catch (e) {
        print('[LocationService] Error initializing BackgroundLocator after login: $e');
      }
    } else if (relationName == 'eta.drivers') {
      print('[LocationService] Driver logged in - will init locator on trip start');
    } else if (relationName == 'eta.guardians') {
      print('[LocationService] Guardian logged in - no location tracking needed');
    }
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

    // Configuración mejorada del servicio con soporte para Android 14+
    final androidSettings = AndroidSettings(
      accuracy: LocationAccuracy.NAVIGATION,
      distanceFilter: 10, // Cambiar de 0 a 10 metros para reducir peticiones al API
      client: LocationClient.google,
      androidNotificationSettings: AndroidNotificationSettings(
        notificationChannelName: 'Location tracking',
        notificationTitle: 'Seguimiento de ubicación',
        notificationMsg: 'Seguimiento de la ubicación en segundo plano',
        notificationBigMsg: 'La ubicación en segundo plano está activada para mantener la aplicación actualizada con su ubicación.',
        notificationIcon: 'mipmap/ic_launcher',
        notificationIconColor: Colors.grey,
      ),
      wakeLockTime: 60, // Tiempo para mantener despierto el dispositivo
    );

    // Para conductores, inicializar BackgroundLocator si aún no está inicializado
    String? relationName;
    try {
      relationName = await storage.getItem('relation_name');
    } catch (e) {
      print('[LocationService] Could not get relation_name in startTracking: $e');
    }

    if (relationName == 'eta.drivers' && !await BackgroundLocator.isServiceRunning()) {
      try {
        print('[LocationService] Initializing BackgroundLocator for driver on trip start');
        await BackgroundLocator.initialize();
      } catch (e) {
        print('[LocationService] Error initializing BackgroundLocator for driver: $e');
        // Continuar sin el servicio si falla
      }
    }

    try {
      // Agregar un pequeño delay para asegurar que la Activity esté en primer plano
      await Future.delayed(Duration(milliseconds: 500));

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
      print('[LocationService] BackgroundLocator started successfully');
    } catch (e) {
      print('[LocationService] Error starting BackgroundLocator: $e');

      // En Android 14+, si falla por restricciones de foreground service,
      // usar Location package en cambio (solo foreground tracking)
      if (e.toString().contains('ForegroundServiceStartNotAllowedException') ||
          e.toString().contains('mAllowStartForeground false')) {
        print('[LocationService] ⚠️ Android 14+ restriction detected');
        print('[LocationService] ℹ️ Continuing with foreground-only tracking');
        print('[LocationService] ℹ️ Location will be tracked via Mapbox location puck');
        // No reintentar, ya que fallaría de nuevo
        // La app funcionará con location puck de Mapbox en su lugar
        // NO hacer nada más - dejar que la app continúe normalmente
        return; // Salir del método sin reintentar
      }
      // Para otros errores, NO reintentar automáticamente para evitar loops
      print('[LocationService] ❌ Background location service could not start');
      print('[LocationService] ℹ️ App will continue with limited location tracking');
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

            print("Total distance: ${_totalDistance.toStringAsFixed(2)} meters");
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
      print('[LocationService] Position sent with distance: ${_totalDistance.toStringAsFixed(2)} m');
      
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
          print("Total distance: ${_totalDistance.toStringAsFixed(2)} meters");
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
    print('[LocationService] Background position sent with distance: ${_totalDistance.toStringAsFixed(2)} m');
    
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
      // print("[LocationService.timer.difference] ${difference.inSeconds}s.");
      final max = relationNameLocal.contains('eta.drivers') ? 20 : 30;
      if (difference.inSeconds >= max) {
        // print("[LocationService.timer] restaring...");
        _lastPositionDate = DateTime.now();
        final currentCalculateDistance = _shouldCalculateDistance;
        stopLocationService();
        startLocationService(calculateDistance: currentCalculateDistance);
      }
    });
  }

  void stopLocationService() {
    print('[LocationService-$_instanceId.stopLocationService]');
    print('[LocationService] Stopping service - Total distance: ${_totalDistance.toStringAsFixed(2)} m');
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
      
      // Limpiar estado de distancia
      _totalDistance = 0;
      _lastLatitude = 0;
      _lastLongitude = 0;
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
      print('[LocationService] Saved distance: ${_totalDistance.toStringAsFixed(2)} m');
    } catch (e) {
      print('[LocationService] Error saving distance: $e');
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
      if (savedDistance != null && _shouldCalculateDistance) {
        _totalDistance = double.parse(savedDistance);
        print('[LocationService] Loaded saved distance: ${_totalDistance.toStringAsFixed(2)} m');
      } else {
        _totalDistance = 0;
        print('[LocationService] Starting with distance: 0 m');
      }
    } catch (e) {
      _totalDistance = 0;
      print('[LocationService] Error loading distance: $e');
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
      print('[LocationService._calculateDistance] Invalid coordinates');
      return 0.0;
    }
    
    // Si es la primera vez, inicializar las coordenadas pero no calcular distancia
    if (_lastLatitude == 0 && _lastLongitude == 0) {
      _lastLatitude = lat2;
      _lastLongitude = lon2;
      print('[LocationService._calculateDistance] First position initialized');
      return 0.0;
    }
    
    // Fórmula de Haversine para calcular distancia entre dos puntos en la Tierra
    const double earthRadius = 6371000; // Radio de la Tierra en metros

    double lat1Rad = _toRadians(_lastLatitude);
    double lat2Rad = _toRadians(lat2);
    double deltaLat = _toRadians(lat2 - _lastLatitude);
    double deltaLon = _toRadians(lon2 - _lastLongitude);

    double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLon / 2) * sin(deltaLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c; // Distancia en metros

    // Filtros para mejorar la precisión:
    // 1. Ignorar distancias muy pequeñas (menos de 2 metros - ruido GPS)
    // 2. Ignorar distancias muy grandes (más de 200 metros entre actualizaciones - salto GPS)
    // 3. Solo contar si el vehículo se está moviendo (distancia > 2m)
    
    if (!distance.isNaN && distance >= 2 && distance < 200) {
      _totalDistance += distance;
      _saveDistance(); // Guardar después de cada actualización
      
      print('[LocationService._calculateDistance] Distance added: ${distance.toStringAsFixed(2)}m, Total: ${_totalDistance.toStringAsFixed(2)}m');
    } else if (distance < 2) {
      print('[LocationService._calculateDistance] Distance ignored (too small/noise): ${distance.toStringAsFixed(2)}m');
    } else if (distance >= 200) {
      print('[LocationService._calculateDistance] Distance ignored (GPS jump): ${distance.toStringAsFixed(2)}m');
    }

    // Actualizar última posición solo si la distancia fue válida o muy pequeña
    if (distance < 200) {
      _lastLatitude = lat2;
      _lastLongitude = lon2;
    }

    _checkAndResetDistance();
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}
