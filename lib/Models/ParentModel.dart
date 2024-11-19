import 'dart:core';
import 'package:eta_school_app/Models/StudentModel.dart';


class ParentModel {
  int? parent_id;
  String? first_name;
  String? last_name;
  String? parent_name;
  String? email;
  String? picture;
  String? contact_number;
  String? status;
  StudentModel? pending_student;
  List<StudentModel> students;

  ParentModel({
    required this.parent_id,
    this.first_name,
    this.last_name,
    this.parent_name,
    this.email,
    this.picture,
    this.contact_number,
    this.status,
    required this.students,
    this.pending_student,

  });

  factory ParentModel.fromJson(Map<String, dynamic> json) {

    StudentModel? pendingStudent = json['pending_student'] != null ? StudentModel.fromJson(json['pending_student']) : StudentModel(student_id: 0, parent_id: json['parent_id']);
    // List<TripPickupLocation>.from(l.map((model)=> TripPickupLocation.fromJson(model)))
    Iterable studentsList = json['students'];
    List<StudentModel>? students = json['students'] != null ?  List<StudentModel>.from(studentsList.map((model)=>  StudentModel.fromJson(model))) : [];


    return ParentModel(
      parent_id: json['parent_id'] as int?,
      first_name: json['first_name'] as String?,
      last_name: json['last_name'] as String?,
      parent_name: json['parent_name'] as String?,
      email: json['email'] as String?,
      picture: json['picture'] as String?,
      contact_number: json['contact_number'] as String?,
      status: json['status'] as String?,
      students: students,
      pending_student: pendingStudent,
    );
  }

}
