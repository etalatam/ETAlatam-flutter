import 'package:isar/isar.dart';
part 'login_information.g.dart';

@collection
class LoginInformation {
  Id? id; //isar id
  final String token;
  final bool avatar;
  final int idUsu;
  final String apeUsu;
  final int? dniUsu;
  final String emaUsu;
  final DateTime fecCre;
  final String nomUsu;
  final String telUsu;
  final String? permissions;
  final int relationId;
  final String relationName;

  LoginInformation({
    required this.token,
    required this.avatar,
    required this.idUsu,
    required this.apeUsu,
    this.dniUsu,
    required this.emaUsu,
    required this.fecCre,
    required this.nomUsu,
    required this.telUsu,
    this.permissions,
    required this.relationId,
    required this.relationName,
  });
}
