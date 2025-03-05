import 'package:eta_school_app/infrastructure/datasources/driver_datasource.dart';
import 'package:eta_school_app/infrastructure/repositories/driver_repository_impl.dart';

final driverProvider = DriverRepositoryImpl(DriverDatasources());
