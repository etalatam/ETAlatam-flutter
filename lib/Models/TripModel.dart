import 'dart:core';
import 'package:MediansSchoolDriver/Models/DestinationModel.dart';
import 'package:MediansSchoolDriver/Models/DriverModel.dart';
import 'package:MediansSchoolDriver/Models/StudentModel.dart';
import 'package:MediansSchoolDriver/Models/RouteModel.dart';
import 'package:MediansSchoolDriver/Models/PickupLocationModel.dart';
import 'package:MediansSchoolDriver/Models/VehicleModel.dart';

class TripModel {
  int? trip_id;
  int? driver_id;
  int? route_id;
  int? supervisor_id;
  String? trip_date;
  String? trip_status;
  double? distance;
  String? duration;
  String? date;
  String? short_date;
  int? waiting_locations_count;
  int? moving_locations_count;
  int? done_locations_count;
  List<TripPickupLocation>? pickup_locations;
  List<TripDestinationLocation>? destinations;
  RouteModel? route;
  VehicleModel? vehicle;
  DriverModel? driver;

  TripModel({
    required this.trip_id,
    this.driver_id,
    this.route_id,
    this.supervisor_id,
    this.trip_date,
    this.trip_status,
    this.distance,
    this.duration,
    this.short_date,
    this.date,
    this.waiting_locations_count,
    this.moving_locations_count,
    this.done_locations_count,
    this.pickup_locations,
    this.destinations,
    this.route,
    this.vehicle,
    this.driver,

  });


  factory TripModel.fromJson(Map<String, dynamic> json) {

    Iterable l = json["pickup_locations"] != '[]' ? json["pickup_locations"] : null;
    List<TripPickupLocation> pickupLocations = List<TripPickupLocation>.from(l.map((model)=> TripPickupLocation.fromJson(model)));

    Iterable? o = (json["destinations"] != null ) ? json["destinations"] : null;
    List<TripDestinationLocation>? destinations = o == null ? [] : List<TripDestinationLocation>.from(o.map((model)=> TripDestinationLocation.fromJson(model)));
    RouteModel? route = json['route'] != null  ? RouteModel.fromJson(json['route']) : null;
    VehicleModel? vehicle = json['vehicle']  != null ? VehicleModel.fromJson(json['vehicle']) : null;
    DriverModel? driver = json['driver']  != null ? DriverModel.fromJson(json['driver']) : null;
    
    return TripModel(
      trip_id: json['trip_id'] as int?,
      route_id: json['route_id'] as int?,
      supervisor_id: json['supervisor_id'] as int?,
      driver_id: json['driver_id'] as int?,
      trip_date: json['trip_date'] as String?,
      trip_status: json['trip_status'] as String?,
      distance: double.parse(json['distance'].toString().replaceAll(RegExp(r','), '')),
      duration: json['duration'] as String?,
      short_date: json['short_date'] as String?,
      date: json['date'] as String?,
      moving_locations_count: json['moving_locations_count'] == null ? 0 : json['moving_locations_count'] as int?,
      waiting_locations_count: json['waiting_locations_count']  == null ? 0 : json['waiting_locations_count']  as int?,
      done_locations_count: json['done_locations_count']  == null ? 0 : json['done_locations_count']  as int?,
      pickup_locations: pickupLocations,
      destinations: destinations,
      route: route,
      vehicle: vehicle,
      driver: driver,
    );
  }
}

class TripPickupLocation {
  
  int? trip_pickup_id;
  int? trip_id;
  int? model_id;
  int? pickup_id;
  String? status;
  String? boarding_time;
  String? dropoff_time;
  double? latitude;
  double? longitude;
  PickupLocationModel? location;
  StudentModel? student;

  TripPickupLocation({
    this.trip_pickup_id,
    this.trip_id,
    this.model_id,
    this.pickup_id,
    this.status,
    this.boarding_time,
    this.dropoff_time,
    this.latitude,
    this.longitude,
    this.location,
    this.student,

  });

  
  factory TripPickupLocation.fromJson( json) 
  {
    PickupLocationModel pickupLocation = PickupLocationModel.fromJson(json['location']);
    StudentModel? student = json['model']  != null ? StudentModel.fromJson(json['model']) : null;
    
    return TripPickupLocation(
      trip_pickup_id: json['trip_pickup_id'] as int?,
      trip_id: json['trip_id'] as int?,
      model_id: json['model_id'] as int?,
      pickup_id: json['pickup_id'] as int?,
      status: json['status'] as String?,
      boarding_time: json['boarding_time'] as String?,
      dropoff_time: json['dropoff_time'] as String?,
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      location: pickupLocation,
      student: student,
    );
  }

}



class TripDestinationLocation {
  
  int? trip_destination_id;
  int? trip_id;
  int? model_id;
  int? destination_id;
  String? status;
  String? dropoff_time;
  double? latitude;
  double? longitude;
  DestinationModel? location;
  DestinationModel? destination;
  StudentModel? student;

  TripDestinationLocation({
    this.trip_destination_id,
    this.trip_id,
    this.model_id,
    this.destination_id,
    this.status,
    this.dropoff_time,
    this.latitude,
    this.longitude,
    this.location,
    this.destination,
    this.student,

  });

  
  factory TripDestinationLocation.fromJson( json) 
  {
    DestinationModel? destination = json['destination'] != null ? DestinationModel.fromJson(json['destination']) : null;
    StudentModel? student = json['model']  != null ? StudentModel.fromJson(json['model']) : null;
    
    return TripDestinationLocation(
      trip_destination_id: json['trip_destination_id'] as int?,
      trip_id: json['trip_id'] as int?,
      model_id: json['model_id'] as int?,
      destination_id: json['destination_id'] as int?,
      status: json['status'] as String?,
      dropoff_time: json['dropoff_time'] as String?,
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      location: destination,
      destination: destination,
      student: student,
    );
  }

}