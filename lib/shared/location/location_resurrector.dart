import 'dart:io';

import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'package:eta_school_app/controllers/helpers.dart';
import 'location_service.dart';

const String locationCheckTask = 'com.etalatam.locationCheck';
const String locationCheckTaskUnique = 'locationCheckUnique';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('[LocationResurrector] WorkManager task ejecutado: $task');

    try {
      String? token = await storage.getItem('token');
      String? relationName = await storage.getItem('relation_name');

      if (token == null || token.isEmpty) {
        debugPrint('[LocationResurrector] No hay usuario autenticado, omitiendo');
        return true;
      }

      bool shouldTrack = false;

      if (relationName == 'eta.students') {
        shouldTrack = true;
      } else if (relationName == 'eta.drivers') {
        String? hasActiveTrip = await storage.getItem('has_active_trip');
        shouldTrack = hasActiveTrip == 'true';
      }

      if (!shouldTrack) {
        debugPrint('[LocationResurrector] No requiere tracking para rol: $relationName');
        return true;
      }

      if (!LocationService.instance.isTracking) {
        debugPrint('[LocationResurrector] Tracker detenido, reiniciando...');
        await LocationService.instance.init();
        await LocationService.instance.startLocationService(calculateDistance: relationName == 'eta.drivers');
        debugPrint('[LocationResurrector] Tracker reiniciado por WorkManager');
      } else {
        debugPrint('[LocationResurrector] Tracker ya está activo');
      }

      return true;
    } catch (e) {
      debugPrint('[LocationResurrector] Error en WorkManager task: $e');
      return false;
    }
  });
}

class LocationResurrector {
  static final LocationResurrector _instance = LocationResurrector._internal();
  static LocationResurrector get instance => _instance;
  factory LocationResurrector() => _instance;

  LocationResurrector._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!Platform.isAndroid) {
      debugPrint('[LocationResurrector] Solo disponible en Android');
      return;
    }

    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );
      _isInitialized = true;
      debugPrint('[LocationResurrector] WorkManager inicializado');
    } catch (e) {
      debugPrint('[LocationResurrector] Error inicializando WorkManager: $e');
    }
  }

  Future<void> startPeriodicCheck() async {
    if (!Platform.isAndroid) return;

    if (!_isInitialized) {
      await initialize();
    }

    try {
      await Workmanager().cancelByUniqueName(locationCheckTaskUnique);

      await Workmanager().registerPeriodicTask(
        locationCheckTaskUnique,
        locationCheckTask,
        frequency: const Duration(minutes: 15),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(minutes: 5),
      );

      debugPrint('[LocationResurrector] Check periódico registrado (cada 15 min)');
    } catch (e) {
      debugPrint('[LocationResurrector] Error registrando task periódico: $e');
    }
  }

  Future<void> stopPeriodicCheck() async {
    if (!Platform.isAndroid) return;

    try {
      await Workmanager().cancelByUniqueName(locationCheckTaskUnique);
      debugPrint('[LocationResurrector] Check periódico cancelado');
    } catch (e) {
      debugPrint('[LocationResurrector] Error cancelando task: $e');
    }
  }
}
