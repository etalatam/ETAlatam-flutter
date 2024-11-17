import 'package:eta_school_app/domain/datasources/login_datasource.dart';
import 'package:eta_school_app/domain/entities/user/login_information.dart';
import 'package:eta_school_app/infrastructure/services/isar_services.dart';
import 'package:isar/isar.dart';

class LoginInformationDatasource extends LoginDatasource {
  late Future<Isar> db;
  LoginInformationDatasource() {
    db = IsarService.openDB();
  }

  @override
  Future<void> deleteLogin(LoginInformation login) async {
    final isar = await db;
    final LoginInformation? loginToDelete =
        await isar.loginInformations.filter().idEqualTo(login.id).findFirst();
    if (loginToDelete != null) {
      isar.writeTxnSync(
          () => isar.loginInformations.deleteSync(loginToDelete.id!));
    }
  }

  @override
  Future<LoginInformation?> loadLoginInformation() async {
    final isar = await db;
    return isar.loginInformations.where().findFirst();
  }

  @override
  Future<void> saveLogin(LoginInformation login) async {
    final isar = await db;
    isar.writeTxnSync(() => isar.loginInformations.putSync(login));
  }
}
