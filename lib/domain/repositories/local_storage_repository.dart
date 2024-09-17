import 'package:MediansSchoolDriver/domain/entities/background_locator/background_position.dart';

abstract class LocalStorageRepository {
  Future<void> savePosition(BackgroundPosition position);
  Future<List<BackgroundPosition>> loadPositions({int limit = 10, int offsset = 0});
  Future<void> deletePosition(BackgroundPosition position);
}
