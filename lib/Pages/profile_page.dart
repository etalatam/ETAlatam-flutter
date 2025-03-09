import 'package:eta_school_app/Models/user_model.dart';
import 'package:eta_school_app/Pages/reset_password_page.dart';
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

  String? profilePicture;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: showLoader
          ? Loader()
          : Scaffold(
              body: Stack(children: <Widget>[
                Center(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height / 1.2,
                      child: QrImageView(                        
                        data: "Nombre: ${user.firstName} ${user.lastName}, Telefono: ${user.contactNumber}, Correo: ${user.email}",
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
                                        child: CircleAvatar(
                                            radius: 50,
                                            backgroundColor: Color.fromARGB(
                                                255, 234, 244, 243),
                                            foregroundImage: NetworkImage(
                                                httpService.getAvatarUrl(
                                                    user.relationId,
                                                    user.relationName),
                                                headers: {
                                                  'Accept': 'image/png'
                                                }))),
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
                                        setState(() {
                                          showLoader = true;
                                        });
                                        await httpService.logout();
                                        await Future.delayed(
                                            const Duration(seconds: 1));
                                        Get.offAll(Login());
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
              ]),
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

  Future updateProfileBGImage() async {
    final relationName = await storage.getItem('relation_name');

    setState(() {
      profilePicture = "assets/$relationName.jpg";
    });
  }

  @override
  void initState() {
    super.initState();
    loadUser();
    updateProfileBGImage();
  }
}
