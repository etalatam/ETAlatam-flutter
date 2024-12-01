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

  factory ParentModel.fromJson(json) {

    StudentModel? pendingStudent;
    try {
     pendingStudent = json['pending_student'] != null ? StudentModel.fromJson(json['pending_student']) : StudentModel(student_id: 0, parent_id: json['parent_id']); 
    } catch (e) {
      print("ParentModel.fromJson.pendingStudentParseError: ${e.toString()}");
    }

    List<StudentModel> students = [];
    try {
      Iterable studentsList = json['students'];
      students = json['students'] != null ?  List<StudentModel>.from(studentsList.map((model)=>  StudentModel.fromJson(model))) : [];      
    } catch (e) {
      print("ParentModel.fromJson.studentsParseError: ${e.toString()}");
    }

    return ParentModel(
      parent_id: json['guardian_id'] as int?,
      first_name: json['guardian_firstname'] as String?,
      last_name: json['guardian_lastname'] as String?,
      parent_name: "${json['guardian_firstname']} ${json['guardian_lastname']}",
      email: json['guardian_email'] as String?,
      picture: json['picture'] as String?,
      contact_number: json['guardian_phonenumber'] as String?,
      status: json['status'] as String?,
      students: students,
      pending_student: pendingStudent,
    );
  }

}
