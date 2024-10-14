import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:MediansSchoolDriver/controllers/Helpers.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart' hide LocationAccuracy;
import 'location_callback_handler.dart';
import 'location_service_repository.dart';

class ETALocationService extends ChangeNotifier {
  String? domain;

  Map<String, dynamic>? _locationData;

  Map<String, dynamic>? get locationData => _locationData;

  String _currentAddress = '';

  String get currentAddress => _currentAddress;

  ReceivePort port = ReceivePort();

  ETALocationService() {
    askPermission().then((value) {
      if (value) {
        if (IsolateNameServer.lookupPortByName(
                LocationServiceRepository.isolateName) !=
            null) {
          IsolateNameServer.removePortNameMapping(
              LocationServiceRepository.isolateName);
        }

        IsolateNameServer.registerPortWithName(
            port.sendPort, LocationServiceRepository.isolateName);

        port.listen((dynamic data) async {
          print('[ETALocationService.listen] $data');
          if ((_locationData?['latitude'] != data['latitude']) &&
              (_locationData?['longitude'] != data['longitude'])) {
            _locationData = data;
            await tracking(_locationData);
            notifyListeners();
          }
        });

        BackgroundLocator.initialize();
        _startLocator().then((value) => null);
      }
    });
  }
  Future<void> _startLocator() async {
    var data = <String, dynamic>{'countInit': 1};
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
            // accuracy: LocationAccuracy.NAVIGATION,
            interval: 30,
            distanceFilter: 0,
            client: LocationClient.google,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Start Location Tracking',
                notificationMsg: 'Track location in background',
                notificationBigMsg:
                    'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
                // notificationIconColor: Colors.grey,
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
  }

  Future<bool> askPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await Location().serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Location().requestService();
      if (!serviceEnabled) {
        return false;
      }
    }

    permissionGranted = await Location().hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await Location().requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    return true;
  }

  Future tracking(dynamic locationInfo) async {
    try {
      final jsonData = {
        'latitude': locationInfo?['latitude'],
        'longitude': locationInfo?['longitude'],
        'altitude': locationInfo?['altitude'],
        'accuracy': locationInfo?['accuracy'],
        'speed': locationInfo?['speed']
      };

      await httpService.sendTracking(position: jsonData);
    } catch (err) {
      print('tracking: $err');
    }
    return null;
  }
}
