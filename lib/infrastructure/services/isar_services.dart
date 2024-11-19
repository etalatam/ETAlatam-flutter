import 'package:eta_school_app/domain/entities/user/driver.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:eta_school_app/domain/entities/user/login_information.dart';
import 'package:eta_school_app/domain/entities/background_locator/background_position.dart';

class IsarService {
  static Future<Isar> openDB() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      return await Isar.open(
        [LoginInformationSchema, BackgroundPositionSchema, DriverSchema],
        directory: dir.path,
      );
    }
    return Future.value(Isar.getInstance());
  }
}
