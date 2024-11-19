import 'package:eta_school_app/domain/datasources/login_datasource.dart';
import 'package:eta_school_app/domain/entities/user/login_information.dart';
import 'package:eta_school_app/domain/repositories/login_information_repository.dart';

class LoginInformationRepositoryImpl extends LoginInformationRepository {
  final LoginDatasource datasource;
  LoginInformationRepositoryImpl(this.datasource);

  @override
  Future<void> deleteLogin(LoginInformation login) {
    return datasource.deleteLogin(login);
  }

  @override
  Future<LoginInformation?> loadLoginInformation() {
    return datasource.loadLoginInformation();
  }

  @override
  Future<void> saveLogin(LoginInformation login) {
    return datasource.saveLogin(login);
  }
}
