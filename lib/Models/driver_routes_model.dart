// To parse this JSON data, do
//
//     final driverRoutes = driverRoutesFromJson(jsonString);

import 'dart:convert';

List<DriverRoutes> driverRoutesFromJson(String str) => List<DriverRoutes>.from(json.decode(str).map((x) => DriverRoutes.fromJson(x)));

String driverRoutesToJson(List<DriverRoutes> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DriverRoutes {
    final String scheduleStartTime;
    final String scheduleEndTime;
    final int routeId;
    final String routeDescription;
    final String busPlate;
    final String busModel;
    final int busYear;
    final int driverId;
    final int monitorId;
    final String relationNameMonitor;

    DriverRoutes({
        required this.scheduleStartTime,
        required this.scheduleEndTime,
        required this.routeId,
        required this.routeDescription,
        required this.busPlate,
        required this.busModel,
        required this.busYear,
        required this.driverId,
        required this.monitorId,
        required this.relationNameMonitor,
    });

    factory DriverRoutes.fromJson(Map<String, dynamic> json) => DriverRoutes(
        scheduleStartTime: json["schedule_start_time"],
        scheduleEndTime: json["schedule_end_time"],
        routeId: json["route_id"],
        routeDescription: json["route_description"],
        busPlate: json["bus_plate"],
        busModel: json["bus_model"],
        busYear: json["bus_year"],
        driverId: json["driver_id"],
        monitorId: json["monitor_id"],
        relationNameMonitor: json["relation_name_monitor"],
    );

    Map<String, dynamic> toJson() => {
        "schedule_start_time": scheduleStartTime,
        "schedule_end_time": scheduleEndTime,
        "route_id": routeId,
        "route_description": routeDescription,
        "bus_plate": busPlate,
        "bus_model": busModel,
        "bus_year": busYear,
        "driver_id": driverId,
        "monitor_id": monitorId,
        "relation_name_monitor": relationNameMonitor,
    };
}
