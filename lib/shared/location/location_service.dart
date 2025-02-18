import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator_2/location_dto.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart' hide LocationAccuracy;
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
    
  DateTime? _lastPositionDate;

  static final LocationService _instance = LocationService._internal();

  factory LocationService() => _instance;

  LocationService._internal();

  init() async {
    print("[LocationService.init]");
    _userId = await storage.getItem('id_usu');

    askPermission().then((value) async{
      print("[LocationService.askPermission.callback] $value");
      if (value) {
        
        if(!initialization){
          print('[LocationService.initialization...]');
          if (IsolateNameServer.lookupPortByName(
                  LocationServiceRepository.isolateName) != null) {
            IsolateNameServer.removePortNameMapping(
                LocationServiceRepository.isolateName);
          }

          IsolateNameServer.registerPortWithName(
              port.sendPort, LocationServiceRepository.isolateName);

          // ubicacion en foreground
          port.listen((dynamic data) async {
            print('[LocationService.port.listen.callback] $data');
            if (data != null &&
                (_locationData?['latitude'] != data['latitude']) &&
                (_locationData?['longitude'] != data['longitude'])) {
              _locationData = data;
              
              try {
                _lastPositionDate = DateTime.now();
                notifyListeners();
              } catch (e) {
                print(
                    '[LocationService.notifyListeners.error] ${e.toString()}');
              }

              try {
                // await trackingDynamic(_locationData);
              } catch (e) {
                print ('[LocationService.tracking.error] ${e.toString()}');
              }

            }
          });
          BackgroundLocator.initialize();
          initialization = true;
          print("[LocationService._startTimer]");
          _startTimer();
        }

      }else{
        print('[LocationService.init] allready initialize');
      }
    });
  }

  // saveLastPosition(data) async {
  //     await storage.setItem('lastPosition', data);
  // }

  Future<void> startLocationService() async {
    print('[LocationService.startLocationService]');
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
        androidSettings:  AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: relationNameLocal == 'wta.drivers' ? 5 : 60,
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
      _lastPositionDate = DateTime.now();
      final jsonData = {
        'latitude': locationInfo?['latitude'],
        'longitude': locationInfo?['longitude'],
        'altitude': locationInfo?['altitude'],
        'accuracy': locationInfo?['accuracy'],
        'heading': locationInfo?['heading'],
        'time': locationInfo?['time']
      };
      await httpService.sendTracking(position: jsonData, userId: _userId);
    } catch (e) {
      print('[LocationService.trackingDynamic.error] ${e.toString()}');
    }
  }


  trackingLocationDto(LocationDto locationInfo) async {
    print('[LocationService.trackingLocationDto] ${locationInfo.toString()}');
    _lastPositionDate = DateTime.now();

    if ((_locationData?['latitude'] != locationInfo.latitude) &&
    (_locationData?['longitude'] != locationInfo.longitude)) {

      try {
        final jsonData = {
          'latitude': locationInfo.latitude,
          'longitude': locationInfo.longitude,
          'altitude': locationInfo.altitude,
          'accuracy': locationInfo.accuracy,
          'speed': locationInfo.speed,
          'speedAccuracy': locationInfo.speedAccuracy,
          'heading': locationInfo.heading,
          'time': locationInfo.time
        };
        // _locationData = jsonData;
        // notifyListeners();
        await httpService.sendTracking(position: jsonData, userId: _userId);
      } catch (e) {
        print('[LocationService.trackingLocationDto.error] ${e.toString()}');
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_lastPositionDate != null) {
        final now = DateTime.now();
        final difference = now.difference(_lastPositionDate!);
        print("[LocationService.timer.difference] ${difference.inSeconds}s.");
        if (difference.inSeconds >= 30) {
          print("[LocationService.timer] restaring... ");
          stopLocationService();
          startLocationService();
        }
      }else{
        print("[LocationService.timer] _lastPositionDate is null");
      }
    });
  }

  void stopLocationService() {
    print('[LocationService.stopLocationService]');
    try {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
      BackgroundLocator.unRegisterLocationUpdate();
      initialization = false;
      _timer?.cancel();
    } catch (e) {
      print('[LocationService.stopLocationService.error] ${e.toString()}');
    }
  }
}
