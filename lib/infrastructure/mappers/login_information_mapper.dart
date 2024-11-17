import 'package:eta_school_app/Models/login_information_model.dart';
import 'package:eta_school_app/domain/entities/user/login_information.dart';

class LoginInformationMapper {
  static LoginInformation information(LoginInfo user) => LoginInformation(
      token: user.token,
      avatar: user.avatar,
      idUsu: user.idUsu,
      apeUsu: user.apeUsu,
      emaUsu: user.emaUsu,
      fecCre: user.fecCre,
      nomUsu: user.nomUsu,
      telUsu: user.telUsu,
      relationId: user.relationId,
      relationName: user.relationName);
}
