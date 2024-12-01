import 'dart:core';
import 'package:eta_school_app/Models/VehicleModel.dart';

class UserModel {
  int? id;
  String? firstName;
  String? lastName;
  String? name;
  String? email;
  String? contactNumber;

  UserModel({
    required this.id,
    required this.firstName,
    this.lastName,
    this.name,
    this.email,
    this.contactNumber,
  });

  factory UserModel.fromJson(json) {
        
    return UserModel(
      id: json['user_id'] as int?,
      firstName: json['user_firstname'] as String?,
      lastName: json['user_lastname'] as String?,
      name: json['user_firstname']+' '+json['user_lastname'] as String?,
      email: json['user_email'] as String?,
      contactNumber: json['user_tel_usu'] as String?,
    );
  }

}
