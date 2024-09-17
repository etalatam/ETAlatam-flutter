import 'package:MediansSchoolDriver/Models/background_position_model.dart';
import 'package:MediansSchoolDriver/Pages/providers/local_storage_provider.dart';
import 'package:MediansSchoolDriver/controllers/Helpers.dart';
import 'package:MediansSchoolDriver/domain/repositories/local_storage_repository.dart';
import 'package:MediansSchoolDriver/infrastructure/mappers/background_position_mapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:MediansSchoolDriver/shared/location/location_services.dart'; // Ajusta la ruta según la ubicación real
import 'package:background_locator_2/location_dto.dart';

// Define el estado para el LocationNotifier
class LocationState {
  final LocationDto? location;
  final bool isTracking;

  LocationState({this.location, this.isTracking = false});
}

final locationNotifierProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  final localStorageRepository = ref.watch(localStorageRepositoryProvider);
  return LocationNotifier(localStorageRepository: localStorageRepository);
});

class LocationNotifier extends StateNotifier<LocationState> {
  final LocalStorageRepository localStorageRepository;

  late final LocationService _locationService;

  LocationNotifier({required this.localStorageRepository})
      : super(LocationState()) {
    _locationService =
        LocationService(); // Inicializamos el servicio de ubicación

    // Configuramos el stream para escuchar actualizaciones de ubicación
    _locationService.locationStream.listen((LocationDto locationDto) async {
      // Actualiza el estado con la nueva ubicación
      state =
          LocationState(location: locationDto, isTracking: state.isTracking);
      final json = locationDto.toJson();
      try {
        final position = BackgroundPositionMapper.position(
            BackgroundLocation.fromJson(json));
        await localStorageRepository.savePosition(position);
        // Envía la ubicación al servidor
        await httpService.sendTracking(position: position);
      } catch (e) {
        print('LocationNotifier error listen position: ${e.toString()}');
      }
    });
  }

  Future<void> init() async {
    _locationService.init();
  }

  void stop() {
    _locationService.stopLocationService();
  }

  void startTracking() {
    _locationService.startLocationService();
    state = LocationState(location: state.location, isTracking: true);
  }

  void stopTracking() {
    _locationService.stopLocationService();
    state = LocationState(location: state.location, isTracking: false);
  }
}
