import 'dart:core';
import 'package:MediansSchoolDriver/Models/VehicleModel.dart';
import 'package:MediansSchoolDriver/Models/DriverModel.dart';
import 'package:MediansSchoolDriver/Models/PickupLocationModel.dart';
import 'package:MediansSchoolDriver/Models/DestinationModel.dart';

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

  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {

    DriverModel driver = json['driver'] != null ? DriverModel.fromJson(json['driver']) : DriverModel(driver_id: 0, first_name: '');
    VehicleModel vehicle = json['vehicle'] != null ? VehicleModel.fromJson(json['vehicle']) : VehicleModel(vehicle_id: 0,plate_number: '');

    List<PickupLocationModel>? pickupLocations = [];
    if (json['pickup_locations'] != null )
    {
      Iterable l = json["pickup_locations"];
      pickupLocations = List<PickupLocationModel>.from(l.map((model)=> PickupLocationModel.fromJson(model)));
    }

    List<DestinationModel>? destinations = [];
    if (json['destinations'] != null )
    {
      Iterable l = json["destinations"];
      destinations = List<DestinationModel>.from(l.map((model)=> DestinationModel.fromJson(model)));
    }
    
    return RouteModel(
      route_id: json['route_id'] as int?,
      route_name: json['route_name'] as String?,
      description: json['description'] as String?,
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      pickup_locations: pickupLocations,
      driver: driver,
      vehicle: vehicle,
      destinations: destinations,
    );
  }
}
