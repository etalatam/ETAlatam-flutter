import 'dart:core';
import 'package:eta_school_app/Models/student_model.dart';


class ParentModel {
  int? parentId;
  int? schoolId;
  String? firstName;
  String? lastName;
  String? parentName;
  String? email;
  // String? picture;
  String? contactNumber;
  // String? status;
  // StudentModel? pending_student;
  List<StudentModel> students;

  ParentModel({
    required this.parentId,
    this.schoolId,
    this.firstName,
    this.lastName,
    this.parentName,
    this.email,
    // this.picture,
    this.contactNumber,
    // this.status,
    required this.students,
    // this.pending_student,

  });

  factory ParentModel.fromJson(Map<String, dynamic> json) {

    // StudentModel? pendingStudent;
    // try {
    //  pendingStudent = json['pending_student'] != null ? StudentModel.fromJson(json['pending_student']) : StudentModel(student_id: 0, parentId: json['parentId']); 
    // } catch (e) {
    //   print("ParentModel.fromJson.pendingStudentParseError: ${e.toString()}");
    // }

    List<StudentModel> students = [];
    try {
      Iterable studentsList = json['students'];
      students = json['students'] != null ?  List<StudentModel>.from(studentsList.map((model)=>  StudentModel.fromJson(model))) : [];      
    } catch (e) {
      print("ParentModel.fromJson.studentsParseError: ${e.toString()}");
    }

    final dynamic rawSchoolId =
        json['school_id'] ?? json['id_esc'] ?? json['id_school'] ?? json['schoolId'];
    final int? parsedSchoolId =
        rawSchoolId is int ? rawSchoolId : int.tryParse('${rawSchoolId ?? ''}');

    return ParentModel(
      parentId: json['guardian_id'] as int?,
      schoolId: parsedSchoolId,
      firstName: json['guardian_firstname'] as String?,
      lastName: json['guardian_lastname'] as String?,
      parentName: "${json['guardian_firstname']} ${json['guardian_lastname']}",
      email: json['guardian_email'] as String?,
      // picture: json['picture'] as String?,
      contactNumber: json['guardian_phonenumber'] as String?,
      // status: json['status'] as String?,
      students: students,
      // pending_student: pendingStudent,
    );
  }

}
