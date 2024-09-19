import 'dart:isolate';
import 'dart:async';
import 'dart:ui';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static const String isolateName = 'LocatorIsolate';
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  ReceivePort port = ReceivePort();
  StreamController<LocationDto> _locationStreamController =
      StreamController<LocationDto>.broadcast();
  Stream<LocationDto> get locationStream => _locationStreamController.stream;

  Future<void> init() async {
    if (IsolateNameServer.lookupPortByName(isolateName) != null) {
      IsolateNameServer.removePortNameMapping(isolateName);
    }

    IsolateNameServer.registerPortWithName(port.sendPort, isolateName);
    port.listen((dynamic data) {
      if (data != null) {
        LocationDto location =
            LocationDto.fromJson(Map<String, dynamic>.from(data));
        _locationStreamController.add(location);
      }
    });

    await initPlatformState();
  }

  Future<bool> _checkLocationPermission() async {
    await Permission.location.request();
    final permission = await Permission.locationAlways.request();
    await Permission.notification.request();

    if (permission == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> initPlatformState() async {
    await BackgroundLocator.initialize();
  }

  Future<void> startLocationService() async {
    await _checkLocationPermission();
    await BackgroundLocator.registerLocationUpdate(
      LocationService.callback,
      initCallback: LocationService.initCallback,
      disposeCallback: LocationService.disposeCallback,
      autoStop: false,
      iosSettings:
          IOSSettings(accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 0),
      androidSettings: AndroidSettings(
        accuracy: LocationAccuracy.NAVIGATION,
        interval: 5,
        distanceFilter: 0,
        androidNotificationSettings: AndroidNotificationSettings(
            notificationIcon: 'ic_location',
            notificationTitle: 'Rastreo Activo: Ruta Escolar en Curso',
            notificationMsg: '¡Seguimiento activo! Acompañamos tu ruta escolar',
            notificationBigMsg:
                '¡Ruta escolar en curso! Estamos siguiendo tu ubicación para un viaje seguro.'),
      ),
    );
  }

  void stopLocationService() async {
    await BackgroundLocator.unRegisterLocationUpdate();
  }

  @pragma('vm:entry-point')
  static void callback(LocationDto locationDto) {
    print('location in dart callback LocationDto: $locationDto');
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);

    send?.send(locationDto.toJson());
  }

  @pragma('vm:entry-point')
  static void initCallback(Map<dynamic, dynamic> params) {
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
    print('Servicio de ubicación inicializado.');
  }

  @pragma('vm:entry-point')
  static void disposeCallback() {
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
    print('Servicio de ubicación detenido.');
  }
}
