import 'package:MediansSchoolDriver/infrastructure/datasources/login_information_datasource.dart';
import 'package:MediansSchoolDriver/infrastructure/repositories/login_information_repository_impl.dart';

//TODO cambiar a provider cuando sea necesario
final loginInformationProvider =
    LoginInformationRepositoryImpl(LoginInformationDatasource());
