import 'dart:core';
import 'package:eta_school_app/Models/PickupLocationModel.dart';
import 'package:eta_school_app/Models/emitter_keygen.dart';
import 'package:eta_school_app/Pages/providers/emitter_service_provider.dart';
import 'package:eta_school_app/controllers/helpers.dart';

class StudentModel {
  int? student_id;
  int? parent_id;
  String? first_name;
  String? last_name;
  String? student_name;
  String? parent_name;
  String? date_of_birth;
  String? picture;
  String? contact_number;
  String? transfer_status;
  String? gender;
  String? status;
  int? trips_count;
  List<PickupLocationModel> pickup_points = [];
  //DestinationModel? destination;
  //RouteModel? route;
  int? schoolId;
  String? statusCode;
  bool isEmitterSubcribedToTracking = false;
  EmitterKeyGenModel? emitterKeyGenModelTracking;

  StudentModel(
      {required this.student_id,
      required this.parent_id,
      this.first_name,
      this.last_name,
      this.student_name,
      this.parent_name,
      this.date_of_birth,
      this.picture,
      this.contact_number,
      this.transfer_status,
      this.gender,
      this.status,
      required this.pickup_points,
      // this.destination,
      // this.route,
      this.trips_count,
      this.schoolId,
      this.statusCode});

  // Convert the instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      "student_id": student_id,
      "parent_id": parent_id,
      "first_name": first_name,
      "last_name": last_name,
      "student_name": student_name,
      "parent_name": parent_name,
      "date_of_birth": date_of_birth,
      "picture": picture,
      "contact_number": contact_number,
      "transfer_status": transfer_status,
      "gender": gender,
      "status": status,
      "trips_count": trips_count,
      "pickup_location": pickup_points,
      // "destination": destination!.toJson(),
      "schoolId": schoolId,
      "statuscode": statusCode
      // "route" : route!.toJson(),
    };
  }

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    List<PickupLocationModel> _pickupLocations = [];

    try {
      _pickupLocations = json['pickup_points']
          .map((dynamic item) => PickupLocationModel.fromJson(item))
          .toList();
    } catch (e) {
      print("StudentModel.fromJson.parsePickupLocation.error: ${e.toString()}");
    }

    return StudentModel(
      student_id: json['student_id'] as int?,
      parent_id: json['guardian_id'] as int?,
      first_name: json['student_firstname'] as String?,
      last_name: json['student_lastname'] as String?,
      student_name: ("${json['student_firstname']} ${json['student_lastname']}")
          as String?,
      date_of_birth: json['student_birthday'] as String?,
      picture: json['picture'] as String?,
      contact_number: json['student_phonenumber'] as String?,
      transfer_status: json['transfer_status'] as String?,
      gender: json['gender'] as String?,
      trips_count: json['trips_count'] as int?,
      pickup_points: _pickupLocations,
      // destination: destination,
      schoolId: json['school_id'],
      statusCode: json['status_code'],
      // route: route,
    );
  }

  unSubscribeToStudentTracking() async {
    if (isEmitterSubcribedToTracking) return;

    try {
      emitterServiceProvider.client!.unsubscribe(
          "school/$schoolId/tracking/eta.students/",
          key: emitterKeyGenModelTracking!.key);
    } catch (e) {
      print(
          "[StudentModel.unSubscribeToStudentTracking.error] ${e.toString()}");
    }
  }

  subscribeToStudentTracking() async {
    if (!isEmitterSubcribedToTracking) {
      final channel = "school/$schoolId/tracking/eta.students/$student_id/";
      String encodedValue = Uri.encodeComponent(channel);
      emitterKeyGenModelTracking =
          await httpService.emitterKeyGen(encodedValue);
      if (emitterKeyGenModelTracking != null &&
          emitterServiceProvider.client!.isConnected) {
        emitterServiceProvider.client!
            .subscribe(channel, key: emitterKeyGenModelTracking!.key);
        isEmitterSubcribedToTracking = true;
      }
    }
  }
}
