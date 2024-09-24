import 'package:MediansSchoolDriver/infrastructure/datasources/driver_datasource.dart';
import 'package:MediansSchoolDriver/infrastructure/repositories/driver_repository_impl.dart';

//* cambiar a provider(riverpod,bloc) cuando sea necesario
final driverProvider =
    DriverRepositoryImpl(DriverDatasources());
