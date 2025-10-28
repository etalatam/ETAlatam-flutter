import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/components/loader.dart';
import 'package:eta_school_app/methods.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eta_school_app/controllers/helpers.dart';

class ResetPasswordPage extends StatefulWidget {
  String? defaultMail;

  ResetPasswordPage({super.key, this.defaultMail=''});

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
  // String reset_token = '';
  String password = '';
  // String confirm_password = '';
  // String? token;
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
              // !activeResetPassword ? resetPassword() : changePassword(),
              resetPassword(),
              // Positioned(
              //     left: 0,
              //     right: 0,
              //     top: 0,
              //     child: Header()),
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
                              if(widget.defaultMail!.isEmpty)
                              Text(
                                lang.translate('Email'),
                                style: TextStyle(
                                  color: darkBlueColor,
                                  fontSize: 16,
                                ),
                              ),
                              if(widget.defaultMail!.isNotEmpty)
                              Text(
                                widget.defaultMail!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: darkBlueColor,
                                  fontSize: activeTheme.h3.fontSize,
                                  fontWeight: activeTheme.h1.fontWeight,
                                  fontFamily: activeTheme.h1.fontFamily,
                                ),
                              ),
                              if(widget.defaultMail!.isNotEmpty)
                              const SizedBox(height: 50),
                              const SizedBox(height: 8),
                              if(widget.defaultMail!.isEmpty)
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    filled: true,
                                    hintStyle:
                                        TextStyle(color: Colors.grey[800]),
                                    hintText: "",
                                    fillColor:
                                        const Color.fromRGBO(233, 235, 235, 1)),
                                onChanged: (val) {
                                  setState(() {
                                    email = val;
                                    _emailController.text = email;
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
                            color: activeTheme.buttonBG,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              // Solo validar si el email NO viene predefinido (viene desde login)
                              if(widget.defaultMail == null || widget.defaultMail!.isEmpty) {
                                // Validar email vacío
                                if(email.isEmpty){
                                  showSuccessDialog(
                                    context,
                                    lang.translate('Attention'),
                                    lang.translate('Please enter your email address'),
                                    () {
                                      Navigator.pop(context);
                                    }
                                  );
                                  return;
                                }
                                
                                // Validar formato de email
                                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if(!emailRegex.hasMatch(email)) {
                                  showSuccessDialog(
                                    context,
                                    lang.translate('Invalid Email'),
                                    lang.translate('Please enter a valid email address'),
                                    () {
                                      Navigator.pop(context);
                                    }
                                  );
                                  return;
                                }
                              }
                              
                              setState(() {
                                showLoader = true;
                              });

                              httpService.resetPassword(email).then((value)  {
                                setState(() {
                                  showLoader = false;
                                  response = value;
                                });
                                
                                if(value == '1') {
                                  // Éxito: mostrar diálogo con instrucciones
                                  showSuccessDialog(
                                    context,
                                    lang.translate('Success'),
                                    '${lang.translate('Recovery password mail sended')}\n\n' +
                                    lang.translate('Please check your email inbox and follow the instructions to reset your password.'),
                                    () {
                                      // Cerrar diálogo y volver a la pantalla anterior
                                      Navigator.pop(context); // Cerrar diálogo
                                      Navigator.pop(context); // Volver a login
                                    }
                                  );
                                } else {
                                  // Error: mostrar mensaje de error pero mantener en la vista
                                  var msg = value.split('/');
                                  String errorMessage = msg[0];
                                  String statusCode = msg.length > 1 ? msg[1] : '';
                                  
                                  // Mensajes de error más específicos
                                  if(statusCode == '404') {
                                    errorMessage = lang.translate('Email not found. Please check and try again.');
                                  } else if(statusCode == '400') {
                                    errorMessage = lang.translate('Invalid email format. Please check and try again.');
                                  } else {
                                    errorMessage = lang.translate(errorMessage);
                                  }
                                  
                                  showSuccessDialog(
                                    context,
                                    lang.translate('Error'),
                                    errorMessage,
                                    () {
                                      Navigator.pop(context); // Solo cerrar el diálogo
                                    }
                                  );
                                }
                              }).catchError((error) {
                                print('[ResetPasswordPage] Error: $error');
                                setState(() {
                                  showLoader = false;
                                });
                                
                                // Error de conexión
                                showSuccessDialog(
                                  context,
                                  lang.translate('Connection Error'),
                                  lang.translate('Could not connect to server. Please check your internet connection and try again.'),
                                  () {
                                    Navigator.pop(context); // Solo cerrar el diálogo
                                  }
                                );
                              });
                            },
                            child: Text(
                              lang.translate('Send now'),
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
                  // const SizedBox(height: 48),
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: Text(
                  //     lang.translate('login_copyrights'),
                  //     textAlign: TextAlign.center,
                  //     style: const TextStyle(
                  //       color: Color(0xff959cb5),
                  //       fontSize: 16,
                  //       letterSpacing: 0.16,
                  //     ),
                  //   ),
                  // ),
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
                              // Text(
                              //   lang.translate('Reset token'),
                              //   style: TextStyle(
                              //     color: darkBlueColor,
                              //     fontSize: 16,
                              //   ),
                              // ),
                              // const SizedBox(height: 8),
                              // TextField(
                              //   controller: currentPasswordController,
                              //   decoration: InputDecoration(
                              //       border: OutlineInputBorder(
                              //         borderRadius: BorderRadius.circular(10.0),
                              //       ),
                              //       filled: true,
                              //       hintStyle:
                              //           TextStyle(color: Colors.grey[800]),
                              //       hintText: "",
                              //       fillColor:
                              //           const Color.fromRGBO(233, 235, 235, 1)),
                              //   onChanged: (val) {
                              //     setState(() {
                              //       reset_token = val;
                              //     });
                              //   },
                              // ),
                            ],
                          ),
                        ),
                        // const SizedBox(height: 24),
                        // SizedBox(
                        //   width: double.infinity,
                        //   child: Column(
                        //     mainAxisSize: MainAxisSize.min,
                        //     mainAxisAlignment: MainAxisAlignment.start,
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       // response == null ? Center() : Text("${response}", style: TextStyle(color: activeTheme.main_color),),
                        //       Text(
                        //         lang.translate('New password'),
                        //         style: TextStyle(
                        //           color: darkBlueColor,
                        //           fontSize: 16,
                        //         ),
                        //       ),
                        //       const SizedBox(height: 8),
                        //       TextField(
                        //         controller: passwordController,
                        //         decoration: InputDecoration(
                        //             border: OutlineInputBorder(
                        //               borderRadius: BorderRadius.circular(10.0),
                        //             ),
                        //             filled: true,
                        //             hintStyle:
                        //                 TextStyle(color: Colors.grey[800]),
                        //             hintText: "",
                        //             fillColor:
                        //                 const Color.fromRGBO(233, 235, 235, 1)),
                        //         onChanged: (val) {
                        //           setState(() {
                        //             password = val;
                        //           });
                        //         },
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // const SizedBox(height: 24),
                        // SizedBox(
                        //   width: double.infinity,
                        //   child: Column(
                        //     mainAxisSize: MainAxisSize.min,
                        //     mainAxisAlignment: MainAxisAlignment.start,
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       // response == null ? Center() : Text("${response}", style: TextStyle(color: activeTheme.main_color),),
                        //       Text(
                        //         lang.translate('Confirm password'),
                        //         style: TextStyle(
                        //           color: darkBlueColor,
                        //           fontSize: 16,
                        //         ),
                        //       ),
                        //       const SizedBox(height: 8),
                        //       TextField(
                        //         controller: confirmedPasswordController,
                        //         decoration: InputDecoration(
                        //             border: OutlineInputBorder(
                        //               borderRadius: BorderRadius.circular(10.0),
                        //             ),
                        //             filled: true,
                        //             alignLabelWithHint: true,
                        //             hintStyle:
                        //                 TextStyle(color: Colors.grey[800]),
                        //             hintText: "******",
                        //             fillColor:
                        //                 const Color.fromRGBO(233, 235, 235, 1)),
                        //         onChanged: (val) {
                        //           setState(() {
                        //             confirm_password = val;
                        //           });
                        //         },
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // const SizedBox(height: 24),
                        // Container(
                        //   width: double.infinity,
                        //   decoration: BoxDecoration(
                        //     borderRadius: BorderRadius.circular(12),
                        //     color: const Color(0xff1e3050),
                        //   ),
                        //   padding: const EdgeInsets.symmetric(
                        //     vertical: 16,
                        //   ),
                        //   child: GestureDetector(
                        //     onTap: () async {
                        //       if (password != confirm_password) {
                        //         showSuccessDialog(
                        //             context,
                        //             lang.translate('Error'),
                        //             lang.translate(
                        //                 'New Password and confirm not matched'),
                        //             callback);
                        //         return;
                        //       }

                        //       setState(() {
                        //         showLoader = true;
                        //       });
                        //       response = await httpService.resetChangePassword(
                        //           reset_token, password);
                        //       setState(() {
                        //         showSuccessDialog(context,
                        //             lang.translate('Response'), response, () {
                        //           Get.to(Login());
                        //         });
                        //         showLoader = false;
                        //         activeResetPassword = true;
                        //       });
                        //     },
                        //     child: Text(
                        //       lang.translate('Confirm'),
                        //       textAlign: TextAlign.center,
                        //       style: const TextStyle(
                        //         color: Colors.white,
                        //         fontSize: 20,
                        //         letterSpacing: 0.20,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 48),
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: Text(
                  //     lang.translate('login_copyrights'),
                  //     textAlign: TextAlign.center,
                  //     style: const TextStyle(
                  //       color: Color(0xff959cb5),
                  //       fontSize: 16,
                  //       letterSpacing: 0.16,
                  //     ),
                  //   ),
                  // ),
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
    // Inicializar email con el valor predefinido si existe
    if(widget.defaultMail != null && widget.defaultMail!.isNotEmpty) {
      email = widget.defaultMail!;
      _emailController.text = email;
    }
  }
}
