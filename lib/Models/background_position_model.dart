import 'dart:convert';

BackgroundLocation backgroundLocationFromJson(String str) => BackgroundLocation.fromJson(json.decode(str));

String backgroundLocationToJson(BackgroundLocation data) => json.encode(data.toJson());

class BackgroundLocation {
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

    BackgroundLocation({
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

    factory BackgroundLocation.fromJson(Map<String, dynamic> json) => BackgroundLocation(
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        accuracy: json["accuracy"],
        altitude: json["altitude"],
        speed: json["speed"],
        speedAccuracy: json["speed_accuracy"]?.toDouble(),
        heading: json["heading"],
        time: json["time"],
        isMocked: json["is_mocked"],
        provider: json["provider"] ?? '',
    );

    Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "accuracy": accuracy,
        "altitude": altitude,
        "speed": speed,
        "speed_accuracy": speedAccuracy,
        "heading": heading,
        "time": time,
        "is_mocked": isMocked,
        "provider": provider ?? '',
    };
}
