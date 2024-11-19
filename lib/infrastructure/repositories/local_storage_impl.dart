import 'package:eta_school_app/domain/datasources/local_storage_datasource.dart';
import 'package:eta_school_app/domain/entities/background_locator/background_position.dart';
import 'package:eta_school_app/domain/repositories/local_storage_repository.dart';

class LocalStorageRepositoryImpl extends LocalStorageRepository {
  final LocalSotrageDatasource datasource;

  LocalStorageRepositoryImpl(this.datasource);

  @override
  Future<void> deletePosition(BackgroundPosition position) {
    return datasource.deletePosition(position);
  }

  @override
  Future<List<BackgroundPosition>> loadPositions(
      {int limit = 10, int offsset = 0}) {
    return datasource.loadPositions(limit: limit, offsset: offsset);
  }

  @override
  Future<void> savePosition(BackgroundPosition position) {
    return datasource.savePosition(position);
  }
}
