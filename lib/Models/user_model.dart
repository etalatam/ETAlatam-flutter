import 'dart:core';

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

  factory UserModel.fromJson(Map<String, dynamic> json) {
        
    return UserModel(
      id: json['user_id'] as int?,
      firstName: "${json['user_firstname']}",
      lastName: "${json['user_lastname']}",
      name: "${json['user_firstname']} ${json['user_lastname']}",
      email: "${json['user_email']}",
      contactNumber: "${json['user_phone']}",
    );
  }

}
