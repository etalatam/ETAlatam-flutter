import 'package:eta_school_app/API/client.dart';
import 'package:flutter/foundation.dart';
import 'package:eta_school_app/Models/trip_model.dart';

class ActiveTripsProvider with ChangeNotifier {
  List<TripModel> _activeTrips = [];
  
  final HttpService _httpService;

  ActiveTripsProvider(this._httpService);

  List<TripModel> get activeTrips => _activeTrips;
  
  bool get hasActiveTrips => _activeTrips.isNotEmpty;

  // Cargar viajes activos según el rol
  Future<void> loadActiveTrips(String userRole, {int? userId}) async {
    try {
      List<TripModel> trips;
      switch (userRole) {
        case 'eta.drivers':
        case 'eta.students':
          trips = [await _httpService.getActiveTrip()];
          break;
        case 'eta.guardians':
          trips = await _httpService.getGuardianTrips("true");
          break;
        default:
          trips = [];
      }
      _activeTrips = trips.where((trip) => trip.trip_id != 0).toList();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("[ActiveTripsProvider] Error: $e");
    }
  }

  // Actualizar un viaje específico (ej: cambio de estado)
  void updateTrip(TripModel updatedTrip) {
    final index = _activeTrips.indexWhere((t) => t.trip_id == updatedTrip.trip_id);
    if (index >= 0) {
      _activeTrips[index] = updatedTrip;
      notifyListeners();
    }
  }

  // Eliminar un viaje (ej: al finalizar)
  void removeTrip(int tripId) {
    _activeTrips.removeWhere((t) => t.trip_id == tripId);
    notifyListeners();
  }
}