import 'package:eta_school_app/Models/UserModel.dart';
import 'package:eta_school_app/Pages/reset_password_page.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/Models/DriverModel.dart';
import 'package:eta_school_app/Pages/login_page.dart';
// import 'package:eta_school_app/components/bottom_menu.dart';
import 'package:eta_school_app/components/loader.dart';
// import 'package:eta_school_app/components/header.dart';
import 'package:eta_school_app/components/custom_row.dart';
import 'package:eta_school_app/controllers/helpers.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.driver});

  final DriverModel? driver;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool showLoader = true;
 
  UserModel user = UserModel(id: 0, firstName: '');

  final String profilePicture = "assets/profile.avif";

  @override
  Widget build(BuildContext context) {
    return Material(
      child: showLoader
          ? Loader()
          : Scaffold(
              body: Stack(children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  decoration: ShapeDecoration(
                    image: DecorationImage(
                      image: AssetImage(profilePicture),
                      fit: BoxFit.fitHeight,
                    ),
                    shape: const RoundedRectangleBorder(),
                  ),
                ),
                DraggableScrollableSheet(
                  snapAnimationDuration: const Duration(seconds: 1),
                  initialChildSize: .7,
                  minChildSize: 0.7,
                  maxChildSize: 0.7,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Container(
                        child: Stack(children: [
                      // Container(
                      //   width: double.infinity,
                      //   height: 75,
                      //   clipBehavior: Clip.antiAlias,
                      //   decoration: BoxDecoration(
                      //       gradient: LinearGradient(
                      //     begin: Alignment.topCenter,
                      //     end: Alignment.bottomCenter,
                      //     colors: [
                      //       Colors.black.withOpacity(0),
                      //       Colors.black.withOpacity(.5),
                      //     ],
                      //   )),
                      // ),
                      Container(
                        margin: const EdgeInsets.only(top: 50),
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: activeTheme.main_bg,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            topRight: Radius.circular(20.0),
                          ),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.black.withOpacity(0.2),
                          //     offset: const Offset(0.0, -3.0),
                          //     blurRadius: 5.0,
                          //   ),
                          // ],
                        ),
                      ),
                      SingleChildScrollView(
                        controller: scrollController,
                        child: Container(
                            child: Stack(children: [
                          Container(
                              child: Row(
                                  textDirection: isRTL()
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                GestureDetector(
                                    onTap: () {
                                      // uploadPicture();
                                      // openNewPage(context, UploadPicturePage());
                                    },
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: CircleAvatar(
                                            radius: 50,
                                            backgroundColor: Color(0xFF123456),
                                            foregroundImage: NetworkImage(
                                                httpService.getAvatarUrl(user.id),
                                                headers: {'Accept': 'image/png'}
                                            )
                                ))),
                                Column(
                                  textDirection: isRTL()
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: Text("${user.firstName}",
                                          style: TextStyle(
                                              fontSize: activeTheme.h5.fontSize,
                                              fontWeight:
                                                  activeTheme.h4.fontWeight,
                                              color: Colors.white)),
                                    ),
                                    // Container(
                                    //   padding: const EdgeInsets.symmetric(
                                    //       horizontal: 10, vertical: 4),
                                    //   decoration: BoxDecoration(
                                    //       color: activeTheme.buttonBG,
                                    //       borderRadius: const BorderRadius.all(
                                    //           Radius.circular(10))),
                                    //   margin: const EdgeInsets.only(top: 15),
                                    //   child: Text("${user.contact_number}",
                                    //       style: TextStyle(
                                    //         color: activeTheme.buttonColor,
                                    //         fontWeight: FontWeight.bold,
                                    //       )),
                                    // ),
                                  ],
                                ),
                                const Expanded(child: Center()),
                                // Column(
                                //   children: [
                                //     const SizedBox(height: 50),
                                //     Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.spaceBetween,
                                //         crossAxisAlignment:
                                //             CrossAxisAlignment.start,
                                //         mainAxisSize: MainAxisSize.max,
                                //         children: [
                                //           GestureDetector(
                                //             onTap: () {
                                //               launchCall(user.contact_number);
                                //             },
                                //             child: Padding(
                                //               padding: const EdgeInsets.only(
                                //                   top: 10, right: 20, left: 20),
                                //               child: Icon(
                                //                 Icons.call,
                                //                 color: activeTheme.icon_color,
                                //               ),
                                //             ),
                                //           ),
                                //           GestureDetector(
                                //             onTap: () {
                                //               launchWP(user.contact_number);
                                //             },
                                //             child: Padding(
                                //               padding: const EdgeInsets.only(
                                //                   top: 10, right: 20, left: 20),
                                //               child: Icon(
                                //                 Icons.maps_ugc_outlined,
                                //                 color: activeTheme.icon_color,
                                //               ),
                                //             ),
                                //           ),
                                //         ])
                                //   ],
                                // )
                              ])),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            height: 1,
                            color: activeTheme.main_color.withOpacity(.2),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 120),
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
                                  color: activeTheme.main_color.withOpacity(.3),
                                ),
                                CustomRow(lang.translate('Last Name'),
                                    user.lastName),
                                Container(
                                  height: 1,
                                  color: activeTheme.main_color.withOpacity(.3),
                                ),
                                CustomRow(
                                    lang.translate('email'), user.email),
                                Container(
                                  height: 1,
                                  color: activeTheme.main_color.withOpacity(.3),
                                ),
                                CustomRow(lang.translate('Contact number'),
                                    user.contactNumber),
                                Container(
                                  height: 1,
                                  color: activeTheme.main_color.withOpacity(.3),
                                ),
                                GestureDetector(
                                    onTap: () {
                                      // openNewPage(
                                      //     context, ChangePasswordPage());
                                      openNewPage(context, ResetPasswordPage(defaultMail: user.email,));
                                    },
                                    child: CustomRow(
                                        lang.translate('Change password'), '')),
                                Container(
                                  height: 1,
                                  color: activeTheme.main_color.withOpacity(.3),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                    onTap: () async {
                                      await httpService.logout();
                                      Get.offAll(Login());
                                    },
                                    child: Text(lang.translate('Logout'),
                                        style: TextStyle(
                                          fontSize: activeTheme.h6.fontSize,
                                          fontFamily: activeTheme.h6.fontFamily,
                                          fontWeight: activeTheme.h6.fontWeight,
                                          color: Colors.red,
                                        ))),
                                const SizedBox(
                                  height: 50,
                                ),
                              ],
                            ),
                          )
                        ])),
                      )
                    ]));
                  },
                ),
                // Positioned(
                //     top: 0,
                //     left: 0,
                //     right: 0,
                //     child: Header(lang.translate('sitename'))),
                // Positioned(
                //     bottom: 20,
                //     left: 20,
                //     right: 20,
                //     child: BottomMenu('profile', openNewPage))
              ]),
            ),
    );
  }

  ///
  /// Load devices through API
  ///
  loadUser() async {
    final userQuery =
        await httpService.userInfo();
    setState(() {
      user = userQuery!;
      showLoader = false;
    });
  }

  /// Open map to set location
  // uploadPicture() async {
  //   await Navigator.push(
  //       context, MaterialPageRoute(builder: (context) => UploadPicturePage()));
  //   setState(() {
  //     loadUser();
  //   });
  // }

  @override
  void initState() {
    super.initState();
    loadUser();
  }
}
