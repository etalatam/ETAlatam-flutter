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

class _LoginState extends State<Login> with TickerProviderStateMixin {
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

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Focus nodes for better keyboard handling
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // Form validation
  final _formKey = GlobalKey<FormState>();
  bool _isLoginPressed = false;

  @override
  Widget build(BuildContext context) {
    return showLoader
        ? Loader()
        : Material(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Color(0xFFF7F9FC),
                  ],
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Background decoration
                    Positioned(
                      top: -100,
                      right: -100,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color.fromARGB(255, 59, 140, 135).withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -150,
                      left: -100,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0xFF1E3050).withOpacity(0.08),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Main content
                    SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 60),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Logo section with animation - Flat design
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Center(
                                  child: Hero(
                                    tag: 'app_logo',
                                    child: SizedBox(
                                      width: 140,
                                      height: 140,
                                      child: Image.asset(
                                        'assets/logo.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Welcome text with slide animation
                              SlideTransition(
                                position: _slideAnimation,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lang.translate("Welcome Back"),
                                        style: TextStyle(
                                          color: darkBlueColor,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        lang.translate('login_intro_message'),
                                        style: TextStyle(
                                          color: darkBlueColor.withOpacity(0.7),
                                          fontSize: 16,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Form fields with animation
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Column(
                                  children: [
                                    // Email field
                                    AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            lang.translate('Email'),
                                            style: TextStyle(
                                              color: darkBlueColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
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
                                              return AnimatedContainer(
                                                duration: Duration(milliseconds: 200),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(16),
                                                  boxShadow: fieldFocusNode.hasFocus
                                                    ? [
                                                        BoxShadow(
                                                          color: Color.fromARGB(255, 59, 140, 135).withOpacity(0.3),
                                                          blurRadius: 8,
                                                          offset: Offset(0, 2),
                                                        )
                                                      ]
                                                    : [],
                                                ),
                                                child: TextFormField(
                                                  controller: fieldTextEditingController,
                                                  focusNode: fieldFocusNode,
                                                  keyboardType: TextInputType.emailAddress,
                                                  autocorrect: false,
                                                  enableSuggestions: true,
                                                  autofillHints: const [AutofillHints.email],
                                                  textInputAction: TextInputAction.next,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: darkBlueColor,
                                                  ),
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'Por favor ingrese su correo electrónico';
                                                    }
                                                    // Validación mejorada que permite '+' en el email
                                                    if (!RegExp(r'^[\w\-\.\+]+@([\w\-]+\.)+[\w\-]{2,4}$')
                                                        .hasMatch(value)) {
                                                      return 'Por favor ingrese un correo electrónico válido';
                                                    }
                                                    return null;
                                                  },
                                                  decoration: InputDecoration(
                                                    contentPadding: EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 16,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(16),
                                                      borderSide: BorderSide.none,
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(16),
                                                      borderSide: BorderSide(
                                                        color: Color.fromARGB(255, 59, 140, 135),
                                                        width: 2,
                                                      ),
                                                    ),
                                                    errorBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(16),
                                                      borderSide: BorderSide(
                                                        color: Colors.red.shade300,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    filled: true,
                                                    fillColor: fieldFocusNode.hasFocus
                                                        ? Colors.white
                                                        : Color(0xFFF5F7FA),
                                                    hintText: "email@example.com",
                                                    hintStyle: TextStyle(
                                                      color: Colors.grey[400],
                                                      fontSize: 15,
                                                    ),
                                                    prefixIcon: Icon(
                                                      Icons.email_outlined,
                                                      color: fieldFocusNode.hasFocus
                                                          ? Color.fromARGB(255, 59, 140, 135)
                                                          : Colors.grey[400],
                                                      size: 20,
                                                    ),
                                                  ),
                                                  onChanged: (val) {
                                                    setState(() {
                                                      email = val;
                                                    });
                                                  },
                                                  onFieldSubmitted: (_) {
                                                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                                                  },
                                                ),
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

                                    const SizedBox(height: 20),

                                    // Password field
                                    AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            lang.translate("Password"),
                                            style: TextStyle(
                                              color: darkBlueColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          AnimatedContainer(
                                            duration: Duration(milliseconds: 200),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: _passwordFocusNode.hasFocus
                                                ? [
                                                    BoxShadow(
                                                      color: Color.fromARGB(255, 59, 140, 135).withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset: Offset(0, 2),
                                                    )
                                                  ]
                                                : [],
                                            ),
                                            child: TextFormField(
                                              controller: _passwordController,
                                              focusNode: _passwordFocusNode,
                                              obscureText: _obscurePassword,
                                              enableSuggestions: false,
                                              autocorrect: false,
                                              autofillHints: const [AutofillHints.password],
                                              textInputAction: TextInputAction.done,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: darkBlueColor,
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Por favor ingrese su contraseña';
                                                }
                                                if (value.length < 6) {
                                                  return 'La contraseña debe tener al menos 6 caracteres';
                                                }
                                                return null;
                                              },
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 16,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                  borderSide: BorderSide.none,
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                  borderSide: BorderSide(
                                                    color: Color.fromARGB(255, 59, 140, 135),
                                                    width: 2,
                                                  ),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                  borderSide: BorderSide(
                                                    color: Colors.red.shade300,
                                                    width: 1,
                                                  ),
                                                ),
                                                filled: true,
                                                fillColor: _passwordFocusNode.hasFocus
                                                    ? Colors.white
                                                    : Color(0xFFF5F7FA),
                                                hintText: "••••••••",
                                                hintStyle: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontSize: 15,
                                                ),
                                                prefixIcon: Icon(
                                                  Icons.lock_outline,
                                                  color: _passwordFocusNode.hasFocus
                                                      ? Color.fromARGB(255, 59, 140, 135)
                                                      : Colors.grey[400],
                                                  size: 20,
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: AnimatedSwitcher(
                                                    duration: Duration(milliseconds: 200),
                                                    child: Icon(
                                                      _obscurePassword
                                                          ? Icons.visibility_off_outlined
                                                          : Icons.visibility_outlined,
                                                      key: ValueKey(_obscurePassword),
                                                      color: _passwordFocusNode.hasFocus
                                                          ? Color.fromARGB(255, 59, 140, 135)
                                                          : Colors.grey[400],
                                                      size: 20,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _obscurePassword = !_obscurePassword;
                                                    });
                                                  },
                                                ),
                                              ),
                                              onChanged: (val) => setState(() {
                                                password = val;
                                              }),
                                              onFieldSubmitted: (_) {
                                                _handleLogin();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 32),

                                    // Login button with scale animation
                                    ScaleTransition(
                                      scale: _scaleAnimation,
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        width: double.infinity,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          gradient: LinearGradient(
                                            colors: _isLoginPressed
                                                ? [Color.fromARGB(255, 45, 105, 100), Color.fromARGB(255, 40, 95, 90)]
                                                : [Color.fromARGB(255, 59, 140, 135), Color.fromARGB(255, 52, 120, 115)],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color.fromARGB(255, 59, 140, 135).withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(16),
                                            onTap: _handleLogin,
                                            onTapDown: (_) {
                                              setState(() {
                                                _isLoginPressed = true;
                                              });
                                              _scaleController.forward();
                                            },
                                            onTapUp: (_) {
                                              setState(() {
                                                _isLoginPressed = false;
                                              });
                                              _scaleController.reverse();
                                            },
                                            onTapCancel: () {
                                              setState(() {
                                                _isLoginPressed = false;
                                              });
                                              _scaleController.reverse();
                                            },
                                            child: Center(
                                              child: Text(
                                                lang.translate('sign in'),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Forgot password link
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) =>
                                              ResetPasswordPage(),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                    child: Text(
                                      lang.translate('Forgot_password'),
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 59, 140, 135),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Footer removido - no se muestran créditos
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      showLoader = true;
    });

    try {
      loginResponse = await httpService.login(email, password)
          .timeout(Duration(seconds: 10));
      var msg = loginResponse?.split('/');

      if (loginResponse == '1') {
        print('[Login] Login exitoso, navegando a home...');
        _saveEmailToHistory(email);
        // Reinitialize LocationService for students after successful login
        LocationService.instance.reinitializeAfterLogin();

        // Navegar directamente sin cambiar el estado del loader
        // Esto evita el parpadeo
        if (mounted) {
          print('[Login] Navegando inmediatamente a HomeScreen...');
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        }
      } else {
        setState(() {
          showLoader = false;
          showSuccessDialog(
              context,
              "${lang.translate('Error')} (${msg![1]})",
              lang.translate(msg[0]),
              null);
        });
      }
    } catch (e) {
      setState(() {
        showLoader = false;
      });
      showSuccessDialog(
          context,
          lang.translate('Error'),
          lang.translate('Connection error. Please try again.'),
          null);
    }
  }

  Future<bool> checkSession() async {
    // Asegurar que el storage está listo antes de leer
    await storage.ready;

    final token_ = await storage.getItem('token');
    final userId = await storage.getItem('id_usu');

    print("LoginPage.userId: $userId");
    print("LoginPage.token: ${token_ != null ? 'exists' : 'null'}");

    if (token_ != null && userId != null && token_.toString().isNotEmpty && userId.toString().isNotEmpty) {
      return true;
    }

    // Solo cambiar el estado si está montado y si realmente necesitamos mostrar el formulario
    if (mounted) {
      setState(() {
        showLoader = false;
      });
    }

    return false;
  }

  ///
  /// Redirect to home page
  goHome() async {
    // Evitar llamadas múltiples
    if (!mounted) return;

    print('[Login.goHome] Verificando sesión...');
    final hasSession = await checkSession();
    print('[Login.goHome] hasSession: $hasSession');

    if (hasSession && mounted) {
      print('[Login.goHome] Navegando a HomeScreen...');
      // Usar pushReplacement en lugar de offAll para evitar limpiar el stack completamente
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      print('[Login.goHome] No hay sesión válida!');
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );

    // Initialize animations
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    );

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    // Add listeners for focus changes
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });

    _loadEmailHistory();
    // Solo verificar sesión después de inicializar
    Future.delayed(Duration(milliseconds: 500), () async {
      if (!mounted) return; // Verificar si el widget todavía está montado
      await _cleanupResourcesIfNoSession();
      if (!mounted) return; // Verificar nuevamente antes de navegar
      goHome();
    });
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
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
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