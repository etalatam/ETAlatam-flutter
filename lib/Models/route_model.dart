import 'dart:core';
import 'package:eta_school_app/Models/VehicleModel.dart';
import 'package:eta_school_app/Models/driver_model.dart';
import 'package:eta_school_app/Models/PickupLocationModel.dart';
import 'package:eta_school_app/Models/DestinationModel.dart';

class RouteModel {
  int? route_id;
  String? route_name;
  String? description;
  double? latitude;
  double? longitude;
  List<PickupLocationModel> pickup_locations;
  List<DestinationModel>? destinations;
  DriverModel? driver;
  VehicleModel? vehicle;
  int? schedule_id;

  RouteModel({
    required this.route_id,
    required this.route_name,
    this.description,
    this.latitude,
    this.longitude,
    required this.pickup_locations,
    this.destinations,
    this.driver,
    this.vehicle,
    this.schedule_id
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    DriverModel driver = DriverModel(driver_id: json['driver_id'], first_name: '');
    try {
      driver = DriverModel.fromJson(json);
    } catch (e) {
      print(e.toString());
    }

    VehicleModel vehicle = VehicleModel(vehicle_id: 0, plate_number: json['bus_plate']);
    try {
      vehicle = VehicleModel.fromJson(json);
    } catch (e) {
      print(e.toString());
    }

    List<PickupLocationModel> pickupLocations = [];
    try {
      // print("[RouteModel.fromJson.pickup_points] ${json['pickup_points']}");
      if (json['pickup_points'] != null )
      {
          Iterable l = json["pickup_points"];
          pickupLocations = List<PickupLocationModel>.from(l.map((model)=> PickupLocationModel.fromJson(model)));
          print('pickup_points of RouteModel proccessed');
      }      
    } catch (e) {
      print("[RouteModel.fromJson.error] ${e.toString()}");
    }

    List<DestinationModel>? destinations = [];
    try {
      if (json['destinations'] != null )
      {
        Iterable l = json["destinations"];
        destinations = List<DestinationModel>.from(l.map((model)=> DestinationModel.fromJson(model)));
      }
    } catch (e) {
      print(e.toString());
    }
    
    return RouteModel(
      route_id: json['route_id'] as int?,
      route_name: json['route_description'] as String?,
      description: "${json['schedule_start_time']} - ${json['schedule_end_time']}",
      // latitude: double.parse(json['latitude']),
      // longitude: double.parse(json['longitude']),
      latitude: 0,
      longitude: 0,      
      pickup_locations: pickupLocations,
      driver: driver,
      vehicle: vehicle,
      destinations: destinations,
      schedule_id: json['schedule_id'] as int?,
    );
  }
}