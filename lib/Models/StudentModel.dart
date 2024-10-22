import 'dart:core';
import 'package:MediansSchoolDriver/Models/DestinationModel.dart';
import 'package:MediansSchoolDriver/Models/PickupLocationModel.dart';
import 'package:MediansSchoolDriver/Models/RouteModel.dart';


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
  PickupLocationModel? pickup_location;
  DestinationModel? destination;
  RouteModel? route;

  StudentModel({
    required this.student_id,
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
    this.pickup_location,
    this.destination,
    this.route,
    this.trips_count,

  });

  
  // Convert the instance to a JSON object
  Map<String, dynamic> toJson() {
    return {
      "student_id" : student_id,
      "parent_id" : parent_id,
      "first_name" :first_name,
      "last_name" : last_name,
      "student_name" : student_name,
      "parent_name" : parent_name,
      "date_of_birth" : date_of_birth,
      "picture" :picture,
      "contact_number" :contact_number,
      "transfer_status" : transfer_status,
      "gender" : gender,
      "status" : status,
      "trips_count" : trips_count,
      "pickup_location": pickup_location!.toJson(),
      "destination" : destination!.toJson(),
      // "route" : route!.toJson(),
    };
  }


  factory StudentModel.fromJson(Map<String, dynamic> json) {

    PickupLocationModel? pickupLocation = json['pickup_location'] != null ? PickupLocationModel.fromJson(json['pickup_location']) : PickupLocationModel();
    DestinationModel? destination = json['destination'] != null ? DestinationModel.fromJson(json['destination']) : DestinationModel();
    // RouteModel? route = json['route'] != null ? RouteModel.fromJson(json['route']) : RouteModel(pickup_locations: [],route_id: 0, route_name: '');

    return StudentModel(
      student_id: json['student_id'] as int?,
      parent_id: json['parent_id'] as int?,
      first_name: json['firstname'] as String?,
      last_name: json['lastname'] as String?,
      student_name: ("${json['firstname']} ${json['lastname']}") as String?,
      date_of_birth: json['birthday'] as String?,
      picture: json['picture'] as String?,
      contact_number: json['phonenumber'] as String?,
      transfer_status: json['transfer_status'] as String?,
      gender: json['gender'] as String?,
      trips_count: json['trips_count'] as int?,
      pickup_location: pickupLocation,
      destination: destination,
      // route: route,
    );
  }

}
