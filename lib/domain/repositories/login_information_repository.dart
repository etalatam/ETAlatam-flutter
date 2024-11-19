import 'package:eta_school_app/domain/entities/user/login_information.dart';

abstract class LoginInformationRepository {
  Future<void> saveLogin(LoginInformation login);
  Future<LoginInformation?> loadLoginInformation();
  Future<void> deleteLogin(LoginInformation login);
}
