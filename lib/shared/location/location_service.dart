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

  // final LocalStorage storage = LocalStorage('tokens.json');

  static final LocationService _instance = LocationService._internal();

  factory LocationService() => _instance;

  LocationService._internal();

  init() async {
    // _locationData = await storage.getItem('lastPosition');
    _userId = await storage.getItem('id_usu');

    // print('[ETALocationService.init] $_locationData');
    // notifyListeners();


    askPermission().then((value) async{
      print("[ETALocationService.askPermission.callback] $value");
      if (value) {

        bool serviceEnabled = await Location().serviceEnabled();
        print('[ETALocationService.serviceEnabled] $serviceEnabled');
        if (!serviceEnabled) {
          serviceEnabled = await Location().requestService();
        }
        BackgroundLocator.initialize();

        if(!initialization){

          if (IsolateNameServer.lookupPortByName(
                  LocationServiceRepository.isolateName) != null) {
            IsolateNameServer.removePortNameMapping(
                LocationServiceRepository.isolateName);
          }

          IsolateNameServer.registerPortWithName(
              port.sendPort, LocationServiceRepository.isolateName);

          // ubicacion en foreground
          port.listen((dynamic data) async {
            print('[ETALocationService.listen] $data');
            if (data != null &&
                (_locationData?['latitude'] != data['latitude']) &&
                (_locationData?['longitude'] != data['longitude'])) {
              _locationData = data;
              
              try {
                notifyListeners();
              } catch (e) {
                print(
                    '[ETALocationService.notifyListeners.error] ${e.toString()}');
              }

              try {
                // await trackingDynamic(_locationData);
              } catch (e) {
                print ('[ETALocationService.tracking.error] ${e.toString()}');
              }

            }
          });
        }
        initialization = true;
      }
    });
  }

  // saveLastPosition(data) async {
  //     await storage.setItem('lastPosition', data);
  // }

  Future<void> startLocationService() async {
    print('[ETALocationService.startLocationService]');
    var data = <String, dynamic>{'countInit': 1};

    if(!initialization){
      init();
    }

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
        androidSettings: const AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 5,
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
    print('[ETALocationService.askPermission]');
    PermissionStatus permissionGranted;

    permissionGranted = await Location().hasPermission();
    print('[ETALocationService.permissionGranted] $permissionGranted');
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await Location().requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print('[ETALocationService.permissionGranted] $permissionGranted');
        return false;
      }
    }

    return true;
  }

  trackingDynamic(dynamic locationInfo) async {
    print('[ETALocationService.trackingDynamic] ${locationInfo.toString()}');
    try {
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
      print('[ETALocationService.trackingDynamic.error] ${e.toString()}');
    }
  }


  trackingLocationDto(LocationDto locationInfo) async {
    print('[ETALocationService.trackingLocationDto] ${locationInfo.toString()}');

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
        print('[ETALocationService.trackingLocationDto.error] ${e.toString()}');
      }
    }
  }

  void stopLocationService() {
    print('[ETALocationService.stopLocationService]');
    try {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
      BackgroundLocator.unRegisterLocationUpdate();
    } catch (e) {
      print('[ETALocationService.stopLocationService.error] ${e.toString()}');
    }
  }
}
