import 'dart:core';

class AttendanceModel {
  String? attendanceDate;
  String? metadata;
  String? notes;
  String? statusCode;
  String? registerTs;
  String? updateTs;
  int idTrip;
  String? startTs;
  String? endTs;
  int? distance;
  String? duration;
  bool running;
  int? schoolId;
  String? schoolName;
  String? schoolAddress;
  String? schoolResponsible;
  String? schoolPhone;
  int idStudent;
  String? firstname;
  String? lastname;
  String? birthday;
  String? address;
  String? email;
  String? phonenumber;

  AttendanceModel({
    this.statusCode,
    required this.idTrip,
    this.startTs,
    this.distance,
    this.duration,
    required this.running,
    required this.idStudent,
    this.firstname,
    this.lastname,
    this.birthday,
    this.address,
    this.email,
    this.attendanceDate,
    this.metadata,
    this.notes,
    this.registerTs,
    this.updateTs,
    this.endTs,
    this.schoolId,
    this.schoolName,
    this.schoolAddress,
    this.schoolResponsible,
    this.schoolPhone,
    this.phonenumber,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      attendanceDate: json['attendance_date'],
      metadata: json['metadata'],
      notes: json['notes'],
      statusCode: json['status_code'],
      registerTs: json['register_ts'],
      updateTs: json['update_ts'],
      idTrip: json['id_trip'],
      startTs: json['start_ts'],
      endTs: json['end_ts'],
      distance: json['distance'] ?? 0,
      duration: json['duration'],
      running: json['running'],
      schoolId: json['school_id'],
      schoolName: json['school_name'],
      schoolAddress: json['school_address'],
      schoolResponsible: json['school_responsible'],
      schoolPhone: json['school_phone'],
      idStudent: json['id_student'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      birthday: json['birthday'],
      address: json['address'],
      email: json['email'],
      phonenumber: json['phonenumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_date': attendanceDate,
      'metadata': metadata,
      'notes': notes,
      'status_code': statusCode,
      'register_ts': registerTs,
      'update_ts': updateTs,
      'id_trip': idTrip,
      'start_ts': startTs,
      'end_ts': endTs,
      'distance': distance,
      'duration': duration,
      'running': running,
      'school_id': schoolId,
      'school_name': schoolName,
      'school_address': schoolAddress,
      'school_responsible': schoolResponsible,
      'school_phone': schoolPhone,
      'id_student': idStudent,
      'firstname': firstname,
      'lastname': lastname,
      'birthday': birthday,
      'address': address,
      'email': email,
      'phonenumber': phonenumber,
    };
  }

  String getFullName() {
    return '$firstname $lastname';
  }

  // Método para verificar si el estudiante abordó el bus
  bool onBoarding() {
    return statusCode != 'WILL_NOT_BOARD' && statusCode != 'NOT_BOARDING';
  }
}
