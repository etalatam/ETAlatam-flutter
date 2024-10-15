import 'package:MediansSchoolDriver/infrastructure/datasources/driver_datasource.dart';
import 'package:MediansSchoolDriver/infrastructure/repositories/driver_repository_impl.dart';

final driverProvider =
    DriverRepositoryImpl(DriverDatasources());
