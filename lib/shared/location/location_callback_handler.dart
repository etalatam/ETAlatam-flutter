import 'dart:async';
import 'package:background_locator_2/location_dto.dart';
import 'package:eta_school_app/shared/location/location_service.dart';
import 'location_service_repository.dart';

@pragma('vm:entry-point')
class LocationCallbackHandler {

  static bool _shouldCalculateDistance = false;

  @pragma('vm:entry-point')
  static Future<void> initCallback(Map<dynamic, dynamic> params) async {

        // Obtener el parámetro de cálculo de distancia
    if (params.containsKey('calculateDistance')) {
      _shouldCalculateDistance = params['calculateDistance'];
    }

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
    print("LocationCallbackHandler.callback");
    try {
      var myLocationCallbackRepository = LocationServiceRepository();
      await myLocationCallbackRepository.callback(locationDto);

      print(
          "[myLocationCallbackRepository.shouldCalculateDistance: $myLocationCallbackRepository.shouldCalculateDistance]");

      await LocationService.instance.trackingLocationDto(locationDto);
    } catch (e) {
      print("LocationCallbackHandler.callback.error ${e.toString()}");
    }
  }

  @pragma('vm:entry-point')
  static Future<void> notificationCallback() async {
    print("LocationCallbackHandler.notificationCallback");
  }
}
