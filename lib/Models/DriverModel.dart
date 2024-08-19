import 'dart:core';
import 'package:MediansSchoolDriver/Models/VehicleModel.dart';

class DriverModel {
  int? driver_id;
  String? first_name;
  String? last_name;
  String? name;
  String? email;
  String? picture;
  String? contact_number;
  String? driver_license_number;
  VehicleModel? vehicle;

  DriverModel({
    required this.driver_id,
    required this.first_name,
    this.last_name,
    this.name,
    this.email,
    this.picture,
    this.contact_number,
    this.driver_license_number,
    this.vehicle,

  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {

    VehicleModel vehicle = json['vehicle'] != null ? VehicleModel.fromJson(json['vehicle']) : VehicleModel(vehicle_id: 0, plate_number: '');
    
    return DriverModel(
      driver_id: json['driver_id'] as int?,
      first_name: json['first_name'] as String?,
      last_name: json['last_name'] as String?,
      name: json['first_name']+' '+json['last_name'] as String?,
      email: json['email'] as String?,
      picture: json['picture'] as String?,
      contact_number: json['contact_number'] as String?,
      driver_license_number: json['driver_license_number'] as String?,
      vehicle: vehicle,
    );
  }

}
