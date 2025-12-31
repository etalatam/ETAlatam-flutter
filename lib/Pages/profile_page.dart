import 'dart:async';

import 'package:eta_school_app/Models/user_model.dart';
import 'package:eta_school_app/Pages/reset_password_page.dart';
import 'package:eta_school_app/components/image_default.dart';
import 'package:eta_school_app/shared/emitterio/emitter_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/Pages/login_page.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/components/custom_row.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  // final UserModel? user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool showLoader = true;

  UserModel user = UserModel(id: 0, firstName: '');
  
  static Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: showLoader
          ? Loader()
          : Scaffold(
              body: LayoutBuilder(
                builder: (context, constraints) {

                  return Stack(children: <Widget>[
                    // if (constraints.maxHeight > constraints.maxWidth)
                    Center(
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height / 1.2,
                          child: QrImageView(                        
                            data: "${user.shareProfileUrl}",
                            version: QrVersions.auto,
                            size: MediaQuery.of(context).size.height / 4,
                            // backgroundColor: Colors.green,
                          ),
                      ),
                    ),
                    DraggableScrollableSheet(
                      snapAnimationDuration: const Duration(seconds: 1),
                      initialChildSize: .7,
                      minChildSize: 0.7,
                      maxChildSize: 0.7,
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        return Stack(children: [
                          Container(
                            margin: const EdgeInsets.only(top: 50),
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: activeTheme.main_bg,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0),
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                              controller: scrollController,
                              child: Stack(children: [
                                Row(
                                    textDirection: isRTL()
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Stack(children: [
                                        Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: SizedBox(
                                              width: 100,
                                              height: 100,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(50),
                                                child: Image.network(
                                                    httpService.getImage(
                                                      user.relationId,
                                                      user.relationName,
                                                    ),
                                                    headers: {
                                                      'Accept': 'image/png'
                                                    },
                                                    loadingBuilder: (context, child, loadingProgress){
                                                      if (loadingProgress == null) {
                                                        return child;
                                                      }
                                                      return CircularProgressIndicator();
                                                    },
                                                    errorBuilder: (context, error, stackTrace) => ImageDefault(name: user.firstName!, height: 100, width: 100),
                                                  ),
                                              ),
                                            ),
                                            
                                            /*CircleAvatar(
                                                radius: 50,
                                                backgroundColor: Color.fromARGB(
                                                    255, 234, 244, 243),
                                                foregroundImage: NetworkImage(
                                                    httpService.getAvatarUrl(
                                                        user.relationId,
                                                        user.relationName),
                                                    headers: {
                                                      'Accept': 'image/png'
                                                    },
                                                    ))*/
                                        ),
                                        Consumer<EmitterService>(builder:
                                            (context, emitterService, child) {
                                          return Positioned(
                                            bottom: 5,
                                            right: 15,
                                            child: Container(
                                              width: 15,
                                              height: 15,
                                              decoration: BoxDecoration(
                                                color: emitterService.isConnected()
                                                    ? Colors.green
                                                    : Colors.red,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: Colors.white, width: 2),
                                              ),
                                            ),
                                          );
                                        }),
                                      ]),
                                      // Column(
                                      //   textDirection: isRTL()
                                      //       ? TextDirection.rtl
                                      //       : TextDirection.ltr,
                                      //   crossAxisAlignment: CrossAxisAlignment.start,
                                      //   children: [
                                      //     Container(
                                      //       padding: const EdgeInsets.only(top: 15),
                                      //       child: Text("${user.firstName}",
                                      //           style: TextStyle(
                                      //               fontSize: activeTheme.h5.fontSize,
                                      //               fontWeight:
                                      //                   activeTheme.h4.fontWeight,
                                      //               color: Colors.white)),
                                      //     ),
                                      //   ],
                                      // ),
                                      // const Expanded(child: Center()),
                                    ]),
                                Container(
                                    // margin: const EdgeInsets.symmetric(horizontal: 10),
                                    // height: 1,
                                    // color: activeTheme.main_color.withOpacity(.2),
                                    ),
                                Container(
                                  margin: const EdgeInsets.only(top: 80),
                                  padding: const EdgeInsets.all(20),
                                  width: double.infinity,
                                  child: Column(
                                    crossAxisAlignment: isRTL()
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      CustomRow(lang.translate('First Name'),
                                          user.firstName),
                                      Container(
                                        height: 1,
                                        color:
                                            activeTheme.main_color.withOpacity(.3),
                                      ),
                                      CustomRow(lang.translate('Last Name'),
                                          user.lastName),
                                      Container(
                                        height: 1,
                                        color:
                                            activeTheme.main_color.withOpacity(.3),
                                      ),
                                      Column(
                                        textDirection: isRTL()
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            lang.translate('email'),
                                            style: activeTheme.h5,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.symmetric(
                                                    vertical: 20),
                                                child: Text("${user.email}",
                                                    style: activeTheme.h6),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Container(
                                        height: 1,
                                        color:
                                            activeTheme.main_color.withOpacity(.3),
                                      ),
                                      CustomRow(lang.translate('Contact number'),
                                          user.contactNumber),
                                      Container(
                                        height: 1,
                                        color:
                                            activeTheme.main_color.withOpacity(.3),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      GestureDetector(
                                          onTap: () async {
                                            openNewPage(
                                                context,
                                                ResetPasswordPage(
                                                  defaultMail: user.email,
                                                ));
                                          },
                                          child: Text(
                                              lang.translate('Change password'),
                                              style: TextStyle(
                                                fontSize: activeTheme.h5.fontSize,
                                                fontFamily:
                                                    activeTheme.h6.fontFamily,
                                                fontWeight:
                                                    activeTheme.h6.fontWeight,
                                                color: Colors.red,
                                              ))),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      GestureDetector(
                                          onTap: () async {
                                            // Mostrar dialog de carga que bloquea toda la UI
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false, // No se puede cerrar tocando afuera
                                              builder: (BuildContext context) {
                                                return PopScope(
                                                  canPop: false, // Bloquear botón de atrás
                                                  child: Center(
                                                    child: Card(
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(20.0),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            CircularProgressIndicator(),
                                                            SizedBox(height: 16),
                                                            Text(lang.translate('logging_out')),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );

                                            // Ejecutar logout
                                            await httpService.logout();

                                            // Limpiar controladores GetX para detener listeners
                                            Get.deleteAll(force: true);

                                            // Navegar al login destruyendo todas las rutas anteriores
                                            // Usar Get.offAll con predicate para asegurar limpieza completa
                                            Get.offAll(
                                              () => Login(),
                                              predicate: (route) => false, // Eliminar TODAS las rutas anteriores
                                            );
                                          },
                                          child: Text(lang.translate('Logout'),
                                              style: TextStyle(
                                                fontSize: activeTheme.h5.fontSize,
                                                fontFamily:
                                                    activeTheme.h6.fontFamily,
                                                fontWeight:
                                                    activeTheme.h6.fontWeight,
                                                color: Colors.red,
                                              ))),
                                      const SizedBox(
                                        height: 50,
                                      ),
                                    ],
                                  ),
                                )
                              ]))
                        ]);
                      },
                    ),
                  ]);
                })
            ),
    );
  }

  loadUser() async {
    final userQuery = await httpService.userInfo();
    setState(() {
      user = userQuery!;
      showLoader = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadUser();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    // si existe un timer activo se cancela
    if (_timer != null) {
      _timer?.cancel();
    }

    // Comentado temporalmente - No es necesario actualizar el perfil tan seguido
    // _timer = Timer.periodic(Duration(seconds: 60), (timer) {
    //   loadUser();
    // });
  }
}
