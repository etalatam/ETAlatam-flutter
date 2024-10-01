import 'dart:core';
import 'package:MediansSchoolDriver/Models/DestinationModel.dart';
import 'package:MediansSchoolDriver/Models/StudentModel.dart';
import 'package:MediansSchoolDriver/Models/RouteModel.dart';
import 'package:MediansSchoolDriver/Models/PickupLocationModel.dart';
import 'package:MediansSchoolDriver/Models/VehicleModel.dart';
import 'package:MediansSchoolDriver/domain/entities/user/driver.dart';

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
  Driver? driver;
  String? busPlate;

  TripModel(
      {required this.trip_id,
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
      this.busPlate});

  static Future<TripModel> fromJson(Map<String, dynamic> json) async {
    // Iterable l = json["pickup_locations"] ? json["pickup_locations"] : [];
    // List<TripPickupLocation> pickupLocations = List<TripPickupLocation>.from(l.map((model)=> TripPickupLocation.fromJson(model)));

    // Iterable? o = (json["destinations"] != null ) ? json["destinations"] : null;
    // List<TripDestinationLocation>? destinations = o == null ? [] : List<TripDestinationLocation>.from(o.map((model)=> TripDestinationLocation.fromJson(model)));
    RouteModel? route = await RouteModel.fromJson(json);
    final veh = {
      "vehicle_id": 123,
      "vehicle_name": "Bus Escolar",
      "vehicle_type": "Bus",
      "plate_number": "XYZ-1234",
      "picture": "https://example.com/vehicle_image.png",
      "capacity": 50,
      "maintenance_status": "En servicio",
      "driver_id": 456,
      "route_id": 789,
      "last_latitude": "10.4912",
      "last_longitude": "-66.9028"
    };
    final vehicle = VehicleModel.fromJson(veh);
    List<Map<String, dynamic>> test = [
      {
        "id": 2,
        "id_route": 1,
        "id_pickup_point": 2,
        "register_ts": "2024-08-24T12:47:00.693317",
        "name": "Parada1",
        "address": null,
        "lon": null,
        "lat": null
      },
      {
        "id": 3,
        "id_route": 1,
        "id_pickup_point": 4,
        "register_ts": "2024-08-24T13:39:45.310855",
        "name": "Parada2",
        "address": null,
        "lon": null,
        "lat": null
      },
      {
        "id": 4,
        "id_route": 1,
        "id_pickup_point": 6,
        "register_ts": "2024-08-24T13:39:45.310855",
        "name": "Parada3",
        "address": null,
        "lon": null,
        "lat": null
      }
    ];

    final List<TripPickupLocation> pickupLocation =
        test.map((dynamic item) => TripPickupLocation.fromJson(item)).toList();
 final List<TripDestinationLocation> destinationLocation =
        test.map((dynamic item) => TripDestinationLocation.fromJson(item)).toList();
    // VehicleModel? vehicle = json['vehicle']  != null ? VehicleModel.fromJson(json['vehicle']) : null;
    // DriverModel? driver = json['driver']  != null ? DriverModel.fromJson(json['driver']) : null;

    return TripModel(
      trip_id: json['id_trip'] as int?,
      route_id: json['id_route'] as int?,
      supervisor_id: json['supervisor_id'] as int?,
      driver_id: json['id_driver'] as int?,
      trip_date: json['trip_date'] as String?,
      trip_status: json['running'] == true ? "true" : "false",
      distance: double.parse(
          json['distance'].toString().replaceAll(RegExp(r','), '')),
      duration: json['duration'] as String?,
      short_date: json['short_date'] as String?,
      date: json['date'] as String?,
      moving_locations_count: json['moving_locations_count'] == null
          ? 0
          : json['moving_locations_count'] as int?,
      waiting_locations_count: json['waiting_locations_count'] == null
          ? 0
          : json['waiting_locations_count'] as int?,
      done_locations_count: json['done_locations_count'] == null
          ? 0
          : json['done_locations_count'] as int?,
      busPlate: json['bus_plate'] ?? '',
      route: route,
      pickup_locations: pickupLocation,
      destinations: destinationLocation,
      vehicle: vehicle,
      driver: route.driver,
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

  factory TripPickupLocation.fromJson(json) {
    List<Map<String, dynamic>> test = [
      {
        "id": 2,
        "id_route": 1,
        "id_pickup_point": 2,
        "register_ts": "2024-08-24T12:47:00.693317",
        "name": "Parada1",
        "address": null,
        "lon": null,
        "lat": null
      },
      {
        "id": 3,
        "id_route": 1,
        "id_pickup_point": 4,
        "register_ts": "2024-08-24T13:39:45.310855",
        "name": "Parada2",
        "address": null,
        "lon": null,
        "lat": null
      },
      {
        "id": 4,
        "id_route": 1,
        "id_pickup_point": 6,
        "register_ts": "2024-08-24T13:39:45.310855",
        "name": "Parada3",
        "address": null,
        "lon": null,
        "lat": null
      }
    ];

    PickupLocationModel pickupLocation = PickupLocationModel.fromJson(test[0]);
    StudentModel? student =
        json['model'] != null ? StudentModel.fromJson(json['model']) : null;

    return TripPickupLocation(
      trip_pickup_id: json['id'] as int?,
      trip_id: json['id_route'] as int?,
      model_id: json['model_id'] as int?,
      pickup_id: json['id_pickup_point'] as int?,
      status: json['status'] as String?,
      boarding_time: json['boarding_time'] as String?,
      dropoff_time: json['dropoff_time'] as String?,
      latitude: double.parse(json['latitude'].toString().isEmpty ? "10" : "10"),
      longitude:
          double.parse(json['longitude'].toString().isEmpty ? "-66" : "-66"),
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

  factory TripDestinationLocation.fromJson(json) {
    List<Map<String, dynamic>> test = [
      {
        "id": 2,
        "id_route": 1,
        "id_pickup_point": 2,
        "register_ts": "2024-08-24T12:47:00.693317",
        "name": "Parada1",
        "address": null,
        "lon": null,
        "lat": null
      },
      {
        "id": 3,
        "id_route": 1,
        "id_pickup_point": 4,
        "register_ts": "2024-08-24T13:39:45.310855",
        "name": "Parada2",
        "address": null,
        "lon": null,
        "lat": null
      },
      {
        "id": 4,
        "id_route": 1,
        "id_pickup_point": 6,
        "register_ts": "2024-08-24T13:39:45.310855",
        "name": "Parada3",
        "address": null,
        "lon": null,
        "lat": null
      }
    ];
    json['destination'] = {
      "destination_id": 101,
      "route_id": 202,
      "location_name": "Colegio Central",
      "address": "Av. Principal, Caracas, Venezuela",
      "latitude": "10.48801",
      "longitude":" -66.87919",
      "distance": "5 km",
      "contact_number": "+58 212-5551234",
      "picture": "https://example.com/school_image.png",
      "status": "Pendiente",
      "student_name": "Juan Pérez"
    };

    PickupLocationModel pickupLocation = PickupLocationModel.fromJson(test[0]);
    DestinationModel? destination = json['destination'] != null
        ? DestinationModel.fromJson(json['destination'])
        : null;
    StudentModel? student =
        json['model'] != null ? StudentModel.fromJson(json['model']) : null;

    return TripDestinationLocation(
      trip_destination_id: json['trip_destination_id'] as int?,
      trip_id: json['trip_id'] as int?,
      model_id: json['model_id'] as int?,
      destination_id: json['destination_id'] as int?,
      status: json['status'] as String?,
      dropoff_time: json['dropoff_time'] as String?,
      latitude: double.parse(json['latitude'] ?? "10"),
      longitude: double.parse(json['longitude'] ?? "-66"),
      location: destination,
      destination: destination,
      student: student,
    );
  }
}
