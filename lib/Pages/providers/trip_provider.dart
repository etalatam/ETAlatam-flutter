// trip_provider.dart
import 'package:flutter/material.dart';
import 'package:eta_school_app/Models/trip_model.dart';

class TripProvider extends ChangeNotifier {
  List<TripModel> _activeTrips = [];

  List<TripModel> get activeTrips => _activeTrips;

  void updateActiveTrips(List<TripModel> trips) {
    _activeTrips = trips;
    notifyListeners();
  }

  void addActiveTrip(TripModel trip) {
    _activeTrips.add(trip);
    notifyListeners();
  }

  void removeActiveTrip(int tripId) {
    _activeTrips.removeWhere((trip) => trip.trip_id == tripId);
    notifyListeners();
  }

  void clearActiveTrips() {
    _activeTrips.clear();
    notifyListeners();
  }
}