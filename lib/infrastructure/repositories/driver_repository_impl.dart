import 'package:eta_school_app/domain/datasources/driver_datasource.dart';
import 'package:eta_school_app/domain/entities/user/driver.dart';
import 'package:eta_school_app/domain/repositories/driver_repository.dart';

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
