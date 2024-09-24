import 'package:MediansSchoolDriver/domain/datasources/local_storage_datasource.dart';
import 'package:MediansSchoolDriver/domain/entities/background_locator/background_position.dart';
import 'package:MediansSchoolDriver/infrastructure/services/isar_services.dart';
import 'package:isar/isar.dart';

class IsarDatasource extends LocalSotrageDatasource {
  late Future<Isar> db;
  IsarDatasource() {
    db = IsarService.openDB();
  }

  @override
  Future<void> deletePosition(BackgroundPosition position) async {
    final isar = await db;
    final BackgroundPosition? positionToDelete = await isar.backgroundPositions
        .filter()
        .idEqualTo(position.id)
        .findFirst();
    if (positionToDelete != null) {
      isar.writeTxnSync(
          () => isar.backgroundPositions.deleteSync(positionToDelete.id!));
    }
  }

  @override
  Future<List<BackgroundPosition>> loadPositions(
      {int limit = 10, int offsset = 0}) async {
    final isar = await db;
    return isar.backgroundPositions
        .where()
        .offset(offsset)
        .limit(limit)
        .findAll();
  }

  @override
  Future<void> savePosition(BackgroundPosition position) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.backgroundPositions.putSync(position));
  }
}
