import 'package:MediansSchoolDriver/domain/datasources/local_storage_datasource.dart';
import 'package:MediansSchoolDriver/domain/entities/background_locator/background_position.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarDatasource extends LocalSotrageDatasource {
  late Future<Isar> db;
  IsarDatasource() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open([BackgroundPositionSchema], directory: dir.path);
    }
    return Future.value(Isar.getInstance());
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
