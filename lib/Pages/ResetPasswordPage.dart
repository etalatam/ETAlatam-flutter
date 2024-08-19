import 'package:MediansSchoolDriver/API/client.dart';
import 'package:MediansSchoolDriver/components/loader.dart';
import 'package:MediansSchoolDriver/components/header.dart';
import 'package:MediansSchoolDriver/methods.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:MediansSchoolDriver/controllers/Helpers.dart';
import 'package:MediansSchoolDriver/Pages/LoginPage.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final HttpService httpService = HttpService();

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmedPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String email = '';
  String reset_token = '';
  String password = '';
  String confirm_password = '';

  String? token;
  String? response;
  bool showLoader = false;
  bool activeResetPassword = false;

  @override
  Widget build(BuildContext context) {
    return showLoader
        ? Loader()
        : Material(
            color: Colors.white,
            type: MaterialType.transparency,
            child: Stack(children: [
              !activeResetPassword ? resetPassword() : changePassword(),
              Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Header(lang.translate('sitename'))),
            ]));
  }

  Widget resetPassword() {
    return Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 150),
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
                        lang.translate("forgot password") + "🤔",
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
                        lang.translate('forgot_password_message'),
                        style: TextStyle(
                            color: darkBlueColor,
                            fontSize: activeTheme.normalText.fontSize,
                            fontFamily: activeTheme.normalText.fontFamily),
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // response == null ? Center() : Text("${response}", style: TextStyle(color: activeTheme.main_color),),
                              Text(
                                lang.translate('Email'),
                                style: TextStyle(
                                  color: darkBlueColor,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    filled: true,
                                    hintStyle:
                                        TextStyle(color: Colors.grey[800]),
                                    hintText: "Example@email.com",
                                    fillColor:
                                        const Color.fromRGBO(233, 235, 235, 1)),
                                onChanged: (val) {
                                  setState(() {
                                    email = val;
                                    // _emailController.text = email;
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
                              setState(() {
                                showLoader = true;
                              });
                              response = await httpService.resetPassword(email);
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
        ));
  }

  Widget changePassword() {
    return Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 150),
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
                            fontFamily: activeTheme.normalText.fontFamily),
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // response == null ? Center() : Text("${response}", style: TextStyle(color: activeTheme.main_color),),
                              Text(
                                lang.translate('Reset token'),
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
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    filled: true,
                                    hintStyle:
                                        TextStyle(color: Colors.grey[800]),
                                    hintText: "********",
                                    fillColor:
                                        const Color.fromRGBO(233, 235, 235, 1)),
                                onChanged: (val) {
                                  setState(() {
                                    reset_token = val;
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // response == null ? Center() : Text("${response}", style: TextStyle(color: activeTheme.main_color),),
                              Text(
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
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    filled: true,
                                    hintStyle:
                                        TextStyle(color: Colors.grey[800]),
                                    hintText: "******",
                                    fillColor:
                                        const Color.fromRGBO(233, 235, 235, 1)),
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // response == null ? Center() : Text("${response}", style: TextStyle(color: activeTheme.main_color),),
                              Text(
                                lang.translate('Confirm password'),
                                style: TextStyle(
                                  color: darkBlueColor,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: confirmedPasswordController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    filled: true,
                                    alignLabelWithHint: true,
                                    hintStyle:
                                        TextStyle(color: Colors.grey[800]),
                                    hintText: "******",
                                    fillColor:
                                        const Color.fromRGBO(233, 235, 235, 1)),
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
                              response = await httpService.resetChangePassword(
                                  reset_token, password);
                              setState(() {
                                showSuccessDialog(context,
                                    lang.translate('Response'), response, () {
                                  Get.to(Login());
                                });
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
        ));
  }

  callback() {
    Get.back();
  }

  @override
  void initState() {
    super.initState();
  }
}
