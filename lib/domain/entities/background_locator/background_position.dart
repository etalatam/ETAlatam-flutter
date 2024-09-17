import 'package:isar/isar.dart';
part 'background_position.g.dart';
@collection
class BackgroundPosition {
  Id? id; //isar id
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final double speedAccuracy;
  final double heading;
  final double time;
  final bool isMocked;
  final String? provider;

  BackgroundPosition({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.speed,
    required this.speedAccuracy,
    required this.heading,
    required this.time,
    required this.isMocked,
    this.provider,
  });
}
