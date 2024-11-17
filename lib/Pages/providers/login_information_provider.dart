import 'package:eta_school_app/infrastructure/datasources/login_information_datasource.dart';
import 'package:eta_school_app/infrastructure/repositories/login_information_repository_impl.dart';

final loginInformationProvider =
    LoginInformationRepositoryImpl(LoginInformationDatasource());
