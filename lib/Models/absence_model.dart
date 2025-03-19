import 'dart:core';

class AbsenceModel {
  int? idSchool;
  DateTime absenceDate;
  int idSchedule;
  int idStudent;
  int? idGuardian;
  String? notes;
  String? metadata;
  String? registerTs;
  String? updateTs;
  String? scheduleStartTime;
  String? scheduleEndTime;
  String? routeName;
  String? busName;
  String? busPlate;
  String? driverFullname;

  AbsenceModel({
    required this.absenceDate,
    required this.idSchedule,
    required this.idStudent,
    this.notes,
    this.idSchool,
    this.idGuardian,
    this.metadata,
    this.registerTs,
    this.updateTs,
    this.scheduleStartTime,
    this.scheduleEndTime,
    this.routeName,
    this.busName,
    this.busPlate,
    this.driverFullname,
  });

  factory AbsenceModel.fromJson(Map<String, dynamic> json) {
    return AbsenceModel(
      idSchool: json['id_school'],
      absenceDate: DateTime.parse(json['absence_date']),
      idSchedule: json['id_schedule'],
      idStudent: json['id_student'],
      idGuardian: json['id_guardian'],
      notes: json['notes'],
      metadata: json['metadata'],
      registerTs: json['register_ts'],
      updateTs: json['update_ts'],
      scheduleStartTime: json['schedule_start_time'],
      scheduleEndTime: json['schedule_end_time'],
      routeName: json['route_name'],
      busName: json['bus_name'],
      busPlate: json['bus_plate'],
      driverFullname: json['driver_fullname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_student_id': idStudent,
      '_absence_date': absenceDate.toIso8601String(),
      '_id_schedule': idSchedule,
      '_notes': notes
    };
  }
}
