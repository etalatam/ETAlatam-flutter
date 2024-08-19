import 'package:MediansSchoolDriver/API/client.dart';
import 'package:MediansSchoolDriver/components/loader.dart';
import 'package:MediansSchoolDriver/components/header.dart';
import 'package:MediansSchoolDriver/methods.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:MediansSchoolDriver/controllers/Helpers.dart';
import 'package:MediansSchoolDriver/Pages/HomePage.dart';
import 'dart:async';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final HttpService httpService = HttpService();

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmedPasswordController = TextEditingController();
  String email = '';
  String password = '';
  String current_password = '';
  String confirm_password = '';

  String? token;
  String? response;
  bool showLoader = true;
  bool activeResetPassword = false;

  @override
  Widget build(BuildContext context) {
    // int? driverid = storage.getItem('driver_id');

    return showLoader
        ? Loader()
        : Material(
            color: Colors.white,
            type: MaterialType.transparency,
            child: Stack(children: [
              Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height,
                  child: SingleChildScrollView(
                    child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 150),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.translate("change password") + "🤔",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: darkBlueColor,
                                    fontSize: activeTheme.h1.fontSize,
                                    fontWeight: activeTheme.h1.fontWeight,
                                    fontFamily: activeTheme.h1.fontFamily,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  lang.translate('change_password_message'),
                                  style: TextStyle(
                                      color: darkBlueColor,
                                      fontSize: activeTheme.normalText.fontSize,
                                      fontFamily:
                                          activeTheme.normalText.fontFamily),
                                ),
                              ],
                            ),
                            const SizedBox(height: 48),
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // response == null ? Center() : Text("${response}", style: TextStyle(color: activeTheme.main_color),),
                                        activeResetPassword
                                            ? const Center()
                                            : Text(
                                                lang.translate(
                                                    'Current password'),
                                                style: TextStyle(
                                                  color: darkBlueColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: currentPasswordController,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              filled: true,
                                              hintStyle: TextStyle(
                                                  color: Colors.grey[800]),
                                              hintText: "******",
                                              fillColor: const Color.fromRGBO(
                                                  233, 235, 235, 1)),
                                          onChanged: (val) {
                                            setState(() {
                                              current_password = val;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // response == null ? Center() : Text("${response}", style: TextStyle(color: activeTheme.main_color),),
                                        activeResetPassword
                                            ? const Center()
                                            : Text(
                                                lang.translate('New password'),
                                                style: TextStyle(
                                                  color: darkBlueColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: passwordController,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              filled: true,
                                              hintStyle: TextStyle(
                                                  color: Colors.grey[800]),
                                              hintText: "******",
                                              fillColor: const Color.fromRGBO(
                                                  233, 235, 235, 1)),
                                          onChanged: (val) {
                                            setState(() {
                                              password = val;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // response == null ? Center() : Text("${response}", style: TextStyle(color: activeTheme.main_color),),
                                        activeResetPassword
                                            ? const Center()
                                            : Text(
                                                lang.translate(
                                                    'Confirm password'),
                                                style: TextStyle(
                                                  color: darkBlueColor,
                                                  fontSize: 16,
                                                ),
                                              ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller:
                                              confirmedPasswordController,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              filled: true,
                                              alignLabelWithHint: true,
                                              hintStyle: TextStyle(
                                                  color: Colors.grey[800]),
                                              hintText: "******",
                                              fillColor: const Color.fromRGBO(
                                                  233, 235, 235, 1)),
                                          onChanged: (val) {
                                            setState(() {
                                              confirm_password = val;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: const Color(0xff1e3050),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    child: GestureDetector(
                                      onTap: () async {
                                        if (password != confirm_password) {
                                          showSuccessDialog(
                                              context,
                                              lang.translate('Error'),
                                              lang.translate(
                                                  'New Password and confirm not matched'),
                                              callback);
                                          return;
                                        }

                                        setState(() {
                                          showLoader = true;
                                        });
                                        response =
                                            await httpService.changePassword(
                                                current_password,
                                                password,
                                                confirm_password);
                                        setState(() {
                                          showSuccessDialog(
                                              context,
                                              lang.translate('Response'),
                                              response,
                                              callback);
                                          showLoader = false;
                                          activeResetPassword = true;
                                        });
                                      },
                                      child: Text(
                                        lang.translate('Confirm'),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          letterSpacing: 0.20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 48),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                lang.translate('login_copyrights'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xff959cb5),
                                  fontSize: 16,
                                  letterSpacing: 0.16,
                                ),
                              ),
                            ),
                          ],
                        )),
                  )),
              Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Header(lang.translate('sitename'))),
            ]));
  }

  callback() {
    Get.back();
  }

  ///
  /// Check if already logged in
  ///
  checkSession() async {
    Timer(const Duration(seconds: 1), () async {
      setState(() {
        showLoader = false;
      });

      dynamic driverId = await storage.getItem('driver_id');
      setState(() {
        driverId = driverId ?? storage.getItem('driver_id');
        goHome();
      });
    });
  }

  ///
  /// Redirect to home page
  /// if already logged in
  ///
  goHome() async {
    final token_ = await storage.getItem('token');
    final driverId_ = await storage.getItem('driver_id');
    if (token_ != null && driverId_ != null) {
      Timer(const Duration(seconds: 1), () {
        openNewPage(context, HomePage());
      });
    } else {
      Timer(const Duration(seconds: 1), () {
        if (storage.getItem('token') == null) {
          showLoader = false;
        } else {
          openNewPage(context, HomePage());
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      showLoader = false;
    });
  }
}
