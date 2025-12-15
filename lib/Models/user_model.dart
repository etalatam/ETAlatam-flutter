import 'dart:core';

class UserModel {
  int? id;
  int? schoolId;
  String? firstName;
  String? lastName;
  String? name;
  String? email;
  String? contactNumber;
  String? relationName;
  String? relationId;
  String? shareProfileUrl;

  UserModel({
    required this.id,
    this.schoolId,
    required this.firstName,
    this.lastName,
    this.name,
    this.email,
    this.contactNumber,
    this.relationName,
    this.relationId,
    this.shareProfileUrl
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawSchoolId = json['id_esc'] ?? json['school_id'];
    final int? parsedSchoolId = rawSchoolId is int
        ? rawSchoolId
        : int.tryParse('${rawSchoolId ?? ''}');

    return UserModel(
      id: json['user_id'] as int?,
      schoolId: parsedSchoolId,
      firstName: "${json['user_firstname']}",
      lastName: "${json['user_lastname']}",
      name: "${json['user_firstname']} ${json['user_lastname']}",
      email: "${json['user_email']}",
      contactNumber: "${json['user_phone']}",
      relationName: "${json['relation_name']}",
      relationId: "${json['relation_id']}",
      shareProfileUrl: "${json['share_profile_url']}"
    );
  }

}
