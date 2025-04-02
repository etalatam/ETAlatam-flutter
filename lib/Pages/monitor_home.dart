import 'package:eta_school_app/Pages/attendance_page.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/Models/trip_model.dart';

class MonitorHome extends StatelessWidget {
  const MonitorHome({super.key, required this.trip});
  final TripModel trip;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AttendancePage(trip: trip, isMonitor: true),
    );
  }
}