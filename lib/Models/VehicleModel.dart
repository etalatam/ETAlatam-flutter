import 'dart:core';

class VehicleModel {
  int? vehicle_id;
  String? vehicle_name;
  String? vehicle_type;
  String? plate_number;
  String? picture;
  int? capacity;
  String? maintenance_status;
  int? driver_id;
  int? route_id;
  double? last_latitude;
  double? last_longitude;

  VehicleModel({
    required this.vehicle_id,
    required this.plate_number,
    this.vehicle_name,
    this.vehicle_type,
    this.picture,
    this.capacity,
    this.maintenance_status,
    this.driver_id,
    this.route_id,
    this.last_latitude,
    this.last_longitude,

  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {

    
    return VehicleModel(
      vehicle_id: json['vehicle_id'] as int?,
      vehicle_name: json['bus_brand'] as String?,
      vehicle_type: json['bus_model'] as String?,
      plate_number: json['bus_plate'] as String?,
      capacity: json['bus_capacity'] as int?,
      driver_id: json['driver_id'] as int?,
      route_id: json['route_id'] as int?,
      picture: json['picture'] as String?,
      last_latitude: json['last_latitude'] == null ? null : double.parse(json['last_latitude']),
      last_longitude: json['last_longitude'] == null ? null : double.parse(json['last_longitude']),
      maintenance_status: json['maintenance_status'] as String?,
    );
  }

}
