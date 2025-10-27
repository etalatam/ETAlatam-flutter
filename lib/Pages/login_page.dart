import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/Pages/reset_password_page.dart';
import 'package:eta_school_app/Pages/home_screen.dart';
import 'package:eta_school_app/components/loader.dart';
// import 'package:eta_school_app/components/header.dart';
import 'package:eta_school_app/methods.dart';
import 'package:eta_school_app/shared/emitterio/emitter_service.dart';
import 'package:eta_school_app/shared/fcm/notification_service.dart';
import 'package:eta_school_app/shared/location/location_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakelock/wakelock.dart';
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

                                        try {
                                          loginResponse = await httpService.login(
                                              email, password)
                                              .timeout(Duration(seconds: 10));
                                          var msg = loginResponse?.split('/');

                                          if (loginResponse == '1') {
                                            print('[Login] Login exitoso');
                                            _saveEmailToHistory(email);

                                            // Reinitialize LocationService for students after successful login
                                            LocationService.instance.reinitializeAfterLogin();

                                            // Esperar un poco más para asegurar que el storage esté sincronizado
                                            // El LocalStorage puede ser asíncrono y necesita tiempo para persistir
                                            await Future.delayed(Duration(milliseconds: 300));

                                            // Verificar que los datos se guardaron correctamente antes de navegar
                                            final token_ = await storage.getItem('token');
                                            final userId = await storage.getItem('id_usu');
                                            final relationName = await storage.getItem('relation_name');

                                            print('[Login] Verificando datos guardados:');
                                            print('  - token: ${token_ != null ? "✓" : "✗"}');
                                            print('  - id_usu: ${userId ?? "✗"}');
                                            print('  - relation_name: ${relationName ?? "✗"}');

                                            setState(() {
                                              showLoader = false;
                                            });

                                            if (token_ != null && userId != null && relationName != null) {
                                              print('[Login] ✓ Todos los datos presentes, navegando a home...');
                                              goHome();
                                            } else {
                                              print('[Login] ✗ ERROR: Datos incompletos después del login!');
                                              showSuccessDialog(
                                                  context,
                                                  lang.translate('Error'),
                                                  'Error al guardar la sesión. Por favor intente nuevamente.',
                                                  null);
                                            }
                                          } else {
                                            setState(() {
                                              showLoader = false;
                                            });
                                            showSuccessDialog(
                                                context,
                                                "${lang.translate('Error')} (${msg![1]})",
                                                lang.translate(msg[0]),
                                                null);
                                          }
                                        } catch (e) {
                                          setState(() {
                                            showLoader = false;
                                          });
                                          print('[Login] Error en login: $e');
                                          showSuccessDialog(
                                              context,
                                              lang.translate('Error'),
                                              lang.translate('Connection error. Please try again.'),
                                              null);
                                        }
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
    final relationName = await storage.getItem('relation_name');

    print("[LoginPage.checkSession] Verificando datos de sesión:");
    print("  - token: ${token_ != null ? 'PRESENTE' : 'NULL'}");
    print("  - userId: $userId");
    print("  - relationName: $relationName");

    // IMPORTANTE: Verificar que todos los datos necesarios estén presentes
    // HomeScreen requiere relation_name para funcionar correctamente
    if (token_ != null && userId != null && relationName != null) {
      print("[LoginPage.checkSession] ✓ Sesión válida completa");
      return true;
    }

    if (token_ != null && userId != null && relationName == null) {
      print("[LoginPage.checkSession] ⚠️  WARNING: Sesión incompleta - falta relation_name");
    }

    return false;
  }

  ///
  /// Redirect to home page
  goHome() async {
    print('[Login.goHome] Verificando sesión...');
    final hasSession = await checkSession();
    print('[Login.goHome] hasSession: $hasSession');

    if (hasSession) {
      print('[Login.goHome] Navegando a HomeScreen...');
      Get.offAll(() => HomeScreen());
    } else {
      print('[Login.goHome] No hay sesión válida!');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadEmailHistory();
    _cleanupResourcesIfNoSession();
    goHome();
  }

  /// Limpiar todos los recursos si no hay sesión activa
  Future<void> _cleanupResourcesIfNoSession() async {
    try {
      final token = await storage.getItem('token');
      final userId = await storage.getItem('id_usu');

      // Si no hay token o userId, limpiar todos los recursos
      if (token == null || userId == null) {
        print('[Login] No active session found, cleaning up resources...');

        // Detener servicios de ubicación
        try {
          LocationService.instance.stopLocationService();
          print('[Login] LocationService stopped');
        } catch (e) {
          print('[Login] Error stopping LocationService: $e');
        }

        // Desconectar EmitterService
        try {
          EmitterService.instance.disconnect();
          print('[Login] EmitterService disconnected');
        } catch (e) {
          print('[Login] Error disconnecting EmitterService: $e');
        }

        // Limpiar NotificationService
        try {
          await NotificationService.instance.close();
          print('[Login] NotificationService closed');
        } catch (e) {
          print('[Login] Error closing NotificationService: $e');
        }

        // Deshabilitar Wakelock
        try {
          await Wakelock.disable();
          print('[Login] Wakelock disabled');
        } catch (e) {
          print('[Login] Error disabling Wakelock: $e');
        }

        print('[Login] Resource cleanup completed');
      }
    } catch (e) {
      print('[Login] Error during resource cleanup: $e');
    }
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
