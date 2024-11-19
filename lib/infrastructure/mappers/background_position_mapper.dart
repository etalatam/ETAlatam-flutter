import 'package:eta_school_app/Models/background_position_model.dart';
import 'package:eta_school_app/domain/entities/background_locator/background_position.dart';

class BackgroundPositionMapper {
  static BackgroundPosition position(BackgroundLocation ldto) => BackgroundPosition(
      latitude: ldto.latitude,
      longitude: ldto.longitude,
      accuracy: ldto.accuracy,
      altitude: ldto.altitude,
      speed: ldto.speed,
      speedAccuracy: ldto.speedAccuracy,
      heading: ldto.heading,
      time: ldto.time,
      isMocked: ldto.isMocked,
      provider: ldto.provider);
}
