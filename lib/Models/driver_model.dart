import 'dart:core';
import 'package:eta_school_app/Models/VehicleModel.dart';

class DriverModel {
  int? driver_id;
  int? schoolId;
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
    this.schoolId,
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

    final dynamic rawSchoolId = json['school_id'] ?? json['id_esc'] ?? json['id_school'];
    final int? parsedSchoolId = rawSchoolId is int
        ? rawSchoolId
        : int.tryParse('${rawSchoolId ?? ''}');
        
    return DriverModel(
      driver_id: json['driver_id'] as int?,
      schoolId: parsedSchoolId,
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
