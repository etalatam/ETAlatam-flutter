import 'package:MediansSchoolDriver/domain/entities/user/driver.dart';

abstract class DriverRepository {
  Future<void> save(Driver driver);
  Future<Driver?> load();
  Future<void> delete(Driver driver);
}
