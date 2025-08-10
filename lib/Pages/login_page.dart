import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/Pages/reset_password_page.dart';
import 'package:eta_school_app/Pages/home_screen.dart';
import 'package:eta_school_app/components/loader.dart';
// import 'package:eta_school_app/components/header.dart';
import 'package:eta_school_app/methods.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eta_school_app/controllers/helpers.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final HttpService httpService = HttpService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String email = '';
  String password = '';
  bool _obscurePassword = true;
  List<String> _emailHistory = [];

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
                                        Autocomplete<String>(
                                          optionsBuilder: (TextEditingValue textEditingValue) {
                                            if (textEditingValue.text.isEmpty) {
                                              return _emailHistory;
                                            }
                                            return _emailHistory.where((String option) {
                                              return option.toLowerCase().contains(
                                                  textEditingValue.text.toLowerCase());
                                            });
                                          },
                                          fieldViewBuilder: (BuildContext context,
                                              TextEditingController fieldTextEditingController,
                                              FocusNode fieldFocusNode,
                                              VoidCallback onFieldSubmitted) {
                                            _emailController.text = fieldTextEditingController.text;
                                            return TextField(
                                              controller: fieldTextEditingController,
                                              focusNode: fieldFocusNode,
                                              keyboardType: TextInputType.emailAddress,
                                              autocorrect: false,
                                              enableSuggestions: true,
                                              autofillHints: const [AutofillHints.email],
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(10.0),
                                                  ),
                                                  filled: true,
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey[800]),
                                                  hintText: "email@example.com",
                                                  fillColor: const Color.fromRGBO(
                                                      233, 235, 235, 1)),
                                              onChanged: (val) {
                                                setState(() {
                                                  email = val;
                                                });
                                              },
                                            );
                                          },
                                          onSelected: (String selection) {
                                            setState(() {
                                              email = selection;
                                              _emailController.text = selection;
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
                                          controller: _passwordController,
                                          obscureText: _obscurePassword,
                                          enableSuggestions: false,
                                          autocorrect: false,
                                          autofillHints: const [AutofillHints.password],
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
                                              hintText: "••••••••",
                                              fillColor: const Color.fromRGBO(
                                                  233, 235, 235, 1),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscurePassword
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color: Colors.grey[600],
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscurePassword = !_obscurePassword;
                                                  });
                                                },
                                              )),
                                          onChanged: (val) => setState(() {
                                            password = val;
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
                                      color: activeTheme.buttonBG,
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
                                        var msg = loginResponse?.split('/');

                                        setState(() {
                                          showLoader = false;
                                          if (loginResponse == '1') {
                                            _saveEmailToHistory(email);
                                            goHome();
                                          } else {
                                            showSuccessDialog(
                                                context,
                                                "${lang.translate('Error')} (${msg![1]})",
                                                lang.translate(msg[0]),
                                                null);
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
              //     child: Header()),
            ]));
  }

  Future<bool> checkSession() async {
    setState(() {
      showLoader = false;
    });

    final token_ = await storage.getItem('token');
    final userId = await storage.getItem('id_usu');

    print("LoginPage.userId: $userId");

    if (token_ != null && userId != null) {
      return true;
    }

    return false;
  }

  ///
  /// Redirect to home page
  goHome() async {
    final hasSession = await checkSession();

    if (hasSession) {
      Get.offAll(HomeScreen());
    }
  }

  @override
  void initState() {
    super.initState();
    _loadEmailHistory();
    goHome();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadEmailHistory() async {
    try {
      final savedEmails = await storage.getItem('email_history');
      if (savedEmails != null && savedEmails is List) {
        setState(() {
          _emailHistory = List<String>.from(savedEmails);
        });
      }
    } catch (e) {
      print('Error loading email history: $e');
    }
  }

  Future<void> _saveEmailToHistory(String email) async {
    try {
      if (email.isNotEmpty && !_emailHistory.contains(email)) {
        _emailHistory.insert(0, email);
        if (_emailHistory.length > 5) {
          _emailHistory = _emailHistory.take(5).toList();
        }
        await storage.setItem('email_history', _emailHistory);
      }
    } catch (e) {
      print('Error saving email history: $e');
    }
  }
}
