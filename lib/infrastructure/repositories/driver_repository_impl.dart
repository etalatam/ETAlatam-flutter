import 'package:MediansSchoolDriver/domain/datasources/driver_datasource.dart';
import 'package:MediansSchoolDriver/domain/entities/user/driver.dart';
import 'package:MediansSchoolDriver/domain/repositories/driver_repository.dart';

class DriverRepositoryImpl extends DriverRepository {
  final DriverDatasource datasource;
  DriverRepositoryImpl(this.datasource);

  @override
  Future<void> delete(Driver driver) {
    return datasource.delete(driver);
  }

  @override
  Future<Driver?> load() {
    return datasource.load();
  }

  @override
  Future<void> save(Driver driver) {
    return datasource.save(driver);
  }
}
