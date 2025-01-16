import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/components/header.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/Pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/controllers/helpers.dart';
import 'dart:async';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final HttpService httpService = HttpService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  String firstName = '';
  String lastName = '';
  String email = '';
  String contactNumber = '';
  String gender = 'Male';

  String? token;
  String? loginResponse;
  bool showLoader = true;

  @override
  Widget build(BuildContext context) {
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
                                  lang.translate("Welcome") + "👋",
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
                                          lang.translate('First name'),
                                          style: TextStyle(
                                            color: darkBlueColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: _firstName,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              filled: true,
                                              hintStyle: TextStyle(
                                                  color: Colors.grey[800]),
                                              hintText: "Your first name",
                                              fillColor: const Color.fromRGBO(
                                                  233, 235, 235, 1)),
                                          onChanged: (val) {
                                            setState(() {
                                              firstName = val;
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
                                        // loginResponse == null ? Center() : Text("${loginResponse}", style: TextStyle(color: activeTheme.main_color),),
                                        Text(
                                          lang.translate('last name'),
                                          style: TextStyle(
                                            color: darkBlueColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: _lastName,
                                          decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              filled: true,
                                              hintStyle: TextStyle(
                                                  color: Colors.grey[800]),
                                              hintText: "Your last name",
                                              fillColor: const Color.fromRGBO(
                                                  233, 235, 235, 1)),
                                          onChanged: (val) {
                                            setState(() {
                                              lastName = val;
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
                                          lang.translate("Contact number"),
                                          style: TextStyle(
                                            color: darkBlueColor,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          validator: (String? value) {
                                            if (value!.trim().isEmpty) {
                                              return 'Your mobile is required';
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
                                              hintText: "01*********",
                                              fillColor: const Color.fromRGBO(
                                                  233, 235, 235, 1)),
                                          onChanged: (val) => setState(() {
                                            contactNumber = val;
                                          }),
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
                                          lang.translate("Gender"),
                                          style: TextStyle(
                                              color: darkBlueColor,
                                              fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 10),
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                border: Border.all(
                                                    width: 1,
                                                    color: const Color.fromRGBO(
                                                        0, 0, 0, .6)),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: DropdownButton<String>(
                                              value: gender,
                                              icon: const Icon(
                                                  Icons.arrow_downward),
                                              elevation: 16,
                                              onChanged: (String? value) {
                                                setState(() {
                                                  gender = value!;
                                                });
                                              },
                                              items: [
                                                'Male',
                                                "Female"
                                              ].map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                            )),
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
                                        // final res = await httpService.signup(
                                        //     firstName,
                                        //     lastName,
                                        //     email,
                                        //     contactNumber,
                                        //     gender);
                                        setState(() {
                                          // if (res == '1') {
                                          //   showSuccessDialog(
                                          //       context,
                                          //       lang.translate(
                                          //           'Thanks for subscription'),
                                          //       lang.translate(
                                          //           'Your password sent through the registered email'),
                                          //       callback);
                                          // }
                                          showLoader = false;
                                        });
                                      },
                                      child: Text(
                                        lang.translate('Create account'),
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
              Positioned(left: 0, right: 0, top: 0, child: Header()),
            ]));
  }

  callback() {
    openNewPage(context, Login());
  }

  ///
  /// Check if already logged in
  ///
  checkSession() async {
    dynamic userId = await storage.getItem('user_id');

    Timer(const Duration(seconds: 1), () async {
      setState(() {
        userId = userId ?? storage.getItem('user_id');
        goHome();
      });
    });
  }

  ///
  /// Redirect to home page
  /// if already logged in
  ///
  goHome() {
    if (storage.getItem('token') != null &&
        storage.getItem('user_id') != null) {
      // openNewPage(context, HomePage(userId: storage.getItem('user_id').toString()));
    } else {
      showLoader = false;
    }
  }

  @override
  void initState() {
    super.initState();
    checkSession();
  }
}
