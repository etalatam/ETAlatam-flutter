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
      first_name: json['nom_usu'] as String?,
      last_name: json['ape_usu'] as String?,
      name: json['nom_usu']+' '+json['ape_usu'] as String?,
      email: json['email'] as String?,
      picture: json['user_id'],
      contact_number: json['tel_usu'] as String?,
      driver_license_number: json['docid'] as String?,
      vehicle: vehicle,
    );
  }

}
