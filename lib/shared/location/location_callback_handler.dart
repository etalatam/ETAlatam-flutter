import 'dart:async';

import 'package:background_locator_2/location_dto.dart';
import 'package:eta_school_app/Pages/providers/location_service_provider.dart';

import 'location_service_repository.dart';

@pragma('vm:entry-point')
class LocationCallbackHandler {
  @pragma('vm:entry-point')
  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    var myLocationCallbackRepository = LocationServiceRepository();
    await myLocationCallbackRepository.init(params);
  }

  @pragma('vm:entry-point')
  static Future<void> disposeCallback() async {
    var myLocationCallbackRepository = LocationServiceRepository();
    await myLocationCallbackRepository.dispose();
  }

  @pragma('vm:entry-point')
  static Future<void> callback(LocationDto locationDto) async {
    try {
      var myLocationCallbackRepository = LocationServiceRepository();
      await myLocationCallbackRepository.callback(locationDto);
    } catch (e) {
      print("invoke.myLocationCallbackRepository.error ${e.toString()}");
    }
    
    try {
     locationServiceProvider.trackingLocationDto(locationDto); 
    } catch (e) {
      print("invoke.locationServiceProvider.trackingLocationDto.error ${e.toString()}");
    }
  }

  @pragma('vm:entry-point')
  static Future<void> notificationCallback() async {
    print('***notificationCallback');
  }
}
