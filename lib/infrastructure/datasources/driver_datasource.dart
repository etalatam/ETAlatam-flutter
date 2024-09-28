import 'package:MediansSchoolDriver/domain/datasources/driver_datasource.dart';
import 'package:MediansSchoolDriver/domain/entities/user/driver.dart';
import 'package:MediansSchoolDriver/domain/entities/user/login_information.dart';
import 'package:MediansSchoolDriver/infrastructure/services/isar_services.dart';
import 'package:isar/isar.dart';

class DriverDatasources extends DriverDatasource {
  late Future<Isar> db;
  DriverDatasources() {
    db = IsarService.openDB();
  }

  @override
  Future<void> delete(Driver driver) async {
    final isar = await db;
    final Driver? loginToDelete =
        await isar.drivers.filter().isarIdEqualTo(driver.isarId).findFirst();
    if (loginToDelete != null) {
      isar.writeTxnSync(
          () => isar.loginInformations.deleteSync(loginToDelete.isarId!));
    }
  }

  @override
  Future<Driver?> load() async {
    final isar = await db;
    return isar.drivers.where().findFirst();
  }

  @override
  Future<void> save(Driver driver) async {
    final isar = await db;
    final haveDriver =
        await isar.drivers.filter().isarIdEqualTo(driver.driver_id).findFirst();
    print("driver-----------------$haveDriver");
    if (haveDriver != null) {
      isar.writeTxnSync(() => isar.drivers.deleteSync(haveDriver.driver_id!));
      return;
    }
    print("driver---------paso--------$haveDriver");
    isar.writeTxnSync(() => isar.drivers.putSync(driver));
  }
}
