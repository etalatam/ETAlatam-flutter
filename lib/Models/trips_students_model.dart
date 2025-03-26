import 'dart:core';

class TripStudentModel {
  int? routeId;
  String? routeName;
  int? scheduleId;
  String? scheduleStartTime;
  String? scheduleEndTime;
  bool? cyclic;
  String? scheduledDate;
  int? busId;
  String? busName;
  String? busPlate;
  String? busColor;
  String? driverDocid;
  String? driverFullname;
  int? dow;
  String? utcScheduledDate;
  String? scheduledDatetime;
  String? startingOn;
  String? scheduledDateEndTime;
  bool? running;

  TripStudentModel({
    this.routeId,
    this.routeName,
    this.scheduleId,
    this.scheduleStartTime,
    this.scheduleEndTime,
    this.cyclic,
    this.scheduledDate,
    this.busId,
    this.busName,
    this.busPlate,
    this.busColor,
    this.driverDocid,
    this.driverFullname,
    this.dow,
    this.utcScheduledDate,
    this.scheduledDatetime,
    this.startingOn,
    this.scheduledDateEndTime,
    this.running,
  });

  factory TripStudentModel.fromJson(Map<String, dynamic> json) {
    return TripStudentModel(
      routeId: json['route_id'],
      routeName: json['route_name'],
      scheduleId: json['schedule_id'],
      scheduleStartTime: json['schedule_start_time'],
      scheduleEndTime: json['schedule_end_time'],
      cyclic: json['cyclic'],
      scheduledDate: json['scheduled_date'],
      busId: json['bus_id'],
      busName: json['bus_name'],
      busPlate: json['bus_plate'],
      busColor: json['bus_color'],
      driverDocid: json['driver_docid'],
      driverFullname: json['driver_fullname'],
      dow: json['dow'],
      utcScheduledDate: json['utc_scheduled_date'],
      scheduledDatetime: json['scheduled_datetime'],
      startingOn: json['starting_on'],
      scheduledDateEndTime: json['scheduled_date_end_time'],
      running: json['running'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'route_name': routeName,
      'schedule_id': scheduleId,
      'schedule_start_time': scheduleStartTime,
      'schedule_end_time': scheduleEndTime,
      'cyclic': cyclic,
      'scheduled_date': scheduledDate,
      'bus_id': busId,
      'bus_name': busName,
      'bus_plate': busPlate,
      'bus_color': busColor,
      'driver_docid': driverDocid,
      'driver_fullname': driverFullname,
      'dow': dow,
      'utc_scheduled_date': utcScheduledDate,
      'scheduled_datetime': scheduledDatetime,
      'starting_on': startingOn,
      'scheduled_date_end_time': scheduledDateEndTime,
      'running': running,
    };
  }

  String getFormattedTime() {
    if (scheduleStartTime != null) {
      return scheduleStartTime!.substring(0, 5);
    }
    return '';
  }
}