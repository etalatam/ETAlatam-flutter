// To parse this JSON data, do
//
//     final loginInfo = loginInfoFromJson(jsonString);

import 'dart:convert';

LoginInfo loginInfoFromJson(String str) => LoginInfo.fromJson(json.decode(str));

String loginInfoToJson(LoginInfo data) => json.encode(data.toJson());

class LoginInfo {
    final String token;
    final bool avatar;
    final int idUsu;
    final String apeUsu;
    final int? dniUsu;
    final String emaUsu;
    final DateTime fecCre;
    final String nomUsu;
    final String telUsu;
    final dynamic permissions;
    final int relationId;
    final String relationName;

    LoginInfo({
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

    factory LoginInfo.fromJson(Map<String, dynamic> json) => LoginInfo(
        token: json["token"],
        avatar: json["avatar"],
        idUsu: json["id_usu"],
        apeUsu: json["ape_usu"],
        dniUsu: json["dni_usu"],
        emaUsu: json["ema_usu"],
        fecCre: DateTime.parse(json["fec_cre"]),
        nomUsu: json["nom_usu"],
        telUsu: json["tel_usu"],
        permissions: json["permissions"] ?? '',
        relationId: json["relation_id"],
        relationName: json["relation_name"],
    );

    Map<String, dynamic> toJson() => {
        "token": token,
        "avatar": avatar,
        "id_usu": idUsu,
        "ape_usu": apeUsu,
        "dni_usu": dniUsu,
        "ema_usu": emaUsu,
        "fec_cre": fecCre.toIso8601String(),
        "nom_usu": nomUsu,
        "tel_usu": telUsu,
        "permissions": permissions,
        "relation_id": relationId,
        "relation_name": relationName,
    };
}
