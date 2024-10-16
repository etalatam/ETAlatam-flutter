import 'dart:core';
import 'package:MediansSchoolDriver/Models/VehicleModel.dart';
import 'package:get/get.dart';

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
    VehicleModel? vehicle;
    try{
      vehicle = VehicleModel.fromJson(json['vehicle']);
    }catch(e){
      print(e.toString());
    }
        
    return DriverModel(
      driver_id: json['driver_id'] as int?,
      first_name: json['driver_firstname'] as String?,
      last_name: json['driver_lastname'] as String?,
      name: json['driver_firstname']+' '+json['driver_lastname'] as String?,
      email: json['driver_email'] as String?,
      picture: "${json['id_usu']}",
      contact_number: json['driver_tel_usu'] as String?,
      driver_license_number: json['diver_docid'] as String?,
      vehicle: vehicle,
    );
  }

}
