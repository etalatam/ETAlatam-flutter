import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/Pages/ResetPasswordPage.dart';
import 'package:eta_school_app/Pages/home_screen.dart';
import 'package:eta_school_app/components/loader.dart';
// import 'package:eta_school_app/components/header.dart';
import 'package:eta_school_app/methods.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eta_school_app/controllers/Helpers.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final HttpService httpService = HttpService();

  final TextEditingController _emailController = TextEditingController();
  String email = '';
  String password = '';

  String? token;
  String? loginResponse;
  bool showLoader = true;

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
                                  lang.translate("Welcome Back") + "👋",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: darkBlueColor,
                                    fontSize: 36,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Text(
                                  lang.translate('login_intro_message'),
                                  style: TextStyle(
                                    color: darkBlueColor,
                                    fontSize: 20,
                                  ),
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
                                        // loginResponse == null ? Center() : Text("${loginResponse}", style: TextStyle(color: activeTheme.main_color),),
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
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              filled: true,
                                              hintStyle: TextStyle(
                                                  color: Colors.grey[800]),
                                              hintText: "",
                                              fillColor: const Color.fromRGBO(
                                                  233, 235, 235, 1)),
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
                                  SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lang.translate("Password"),
                                          style: TextStyle(
                                            color: darkBlueColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          obscureText: true,
                                          enableSuggestions: false,
                                          autocorrect: false,
                                          validator: (String? value) {
                                            if (value!.trim().isEmpty) {
                                              return 'Password is required';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              filled: true,
                                              hintStyle: TextStyle(
                                                  color: Colors.grey[800]),
                                              hintText: "",
                                              fillColor: const Color.fromRGBO(
                                                  233, 235, 235, 1)),
                                          onChanged: (val) => setState(() {
                                            password = val;
                                            // goHome();
                                          }),
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
                                        
                                        loginResponse = await httpService.login(
                                            email, password);
                                        var msg =loginResponse?.split('/');
                                        
                                        setState(() {
                                          showLoader = false;
                                          if(loginResponse == '1'){
                                            goHome();
                                          }else{
                                            showSuccessDialog(
                                              context, 
                                              "${lang.translate('Error')} (${msg![1]})",
                                              lang.translate(msg[0]),
                                              callback);
                                          }
                                        });
                                      },
                                      child: Text(
                                        lang.translate('sign in'),
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
                                child: GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      openNewPage(context, ResetPasswordPage());
                                    });
                                  },
                                  child: Text(
                                    lang.translate('Forgot_password'),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xff959cb5),
                                      fontSize: 16,
                                      letterSpacing: 0.16,
                                    ),
                                  ),
                                )),
                          ],
                        )),
                  )),
              // Positioned(
              //     left: 0,
              //     right: 0,
              //     top: 0,
              //     child: Header(lang.translate('sitename'))),
            ]));
  }

  callback() {
    Get.back();
  }

  ///
  /// Check if already logged in
  ///
  checkSession() async {
    setState(() {
      showLoader = false;
    });

    // Timer(const Duration(seconds: 1), () async {
    //   dynamic driverId = await storage.getItem('driver_id');
    //   setState(() {
    //     driverId = storage.getItem('driver_id');
    //     if (driverId != null) {
    //       goHome();
    //     }
    //   });
    // });
  }

  ///
  /// Redirect to home page
  /// if already logged in
  ///
  goHome() async {
    final token_ = await storage.getItem('token');
    final driverId_ = storage.getItem('driver_id');

    if (token_ != null && driverId_ != null) {
      Get.offAll(HomeScreen());
    } else {
      // Timer(const Duration(seconds: 1), () {
      //   if (storage.getItem('token') == null) {
      //     showLoader = false;
      //   } else {
      //     Get.offAll(HomePage());
      //   }
      // });
    }
  }

  @override
  void initState() {
    super.initState();
    checkSession();
  }
}
