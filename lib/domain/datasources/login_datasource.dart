import 'package:MediansSchoolDriver/domain/entities/user/login_information.dart';

abstract class LoginDatasource {
  Future<void> saveLogin(LoginInformation login);
  Future<LoginInformation?> loadLoginInformation();
  Future<void> deleteLogin(LoginInformation login);
}
