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

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with TickerProviderStateMixin {
  final HttpService httpService = HttpService();

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmedPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String email = '';
  String password = '';
  String? response;
  bool showLoader = false;
  bool activeResetPassword = false;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Focus node
  final FocusNode _emailFocusNode = FocusNode();

  // Form validation
  final _formKey = GlobalKey<FormState>();
  bool _isSendPressed = false;

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
                      top: -80,
                      left: -80,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0xFF4A90E2).withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -100,
                      right: -50,
                      child: Container(
                        width: 250,
                        height: 250,
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
                    resetPassword(),

                    // Back button
                    Positioned(
                      top: 16,
                      left: 16,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => Navigator.pop(context),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: darkBlueColor,
                                  size: 20,
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
            ),
          );
  }

  Widget resetPassword() {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon section with animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Hero(
                    tag: 'reset_icon',
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color(0xFF4A90E2).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_reset,
                        size: 50,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Title and description with slide animation
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.translate("forgot password"),
                        style: TextStyle(
                          color: darkBlueColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        lang.translate('forgot_password_message'),
                        style: TextStyle(
                          color: darkBlueColor.withOpacity(0.7),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Email field or display
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(widget.defaultMail!.isEmpty) ...[
                      Text(
                        lang.translate('Email'),
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
                          boxShadow: _emailFocusNode.hasFocus
                            ? [
                                BoxShadow(
                                  color: Color(0xFF4A90E2).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                )
                              ]
                            : [],
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          style: TextStyle(
                            fontSize: 16,
                            color: darkBlueColor,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su correo electrónico';
                            }
                            // Validación mejorada que permite '+' en el email
                            final emailRegex = RegExp(r'^[\w\-\.\+]+@([\w\-]+\.)+[\w\-]{2,4}$');
                            if (!emailRegex.hasMatch(value)) {
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
                                color: Color(0xFF4A90E2),
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
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.red.shade300,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: _emailFocusNode.hasFocus
                                ? Colors.white
                                : Color(0xFFF5F7FA),
                            hintText: "email@example.com",
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 15,
                            ),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: _emailFocusNode.hasFocus
                                  ? Color(0xFF4A90E2)
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
                            _handleSendReset();
                          },
                        ),
                      ),
                    ] else ...[
                      // Display predefined email
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFF4A90E2).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Color(0xFF4A90E2).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              color: Color(0xFF4A90E2),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.defaultMail!,
                                style: TextStyle(
                                  color: darkBlueColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Send button with animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: _isSendPressed
                          ? [Color(0xFF2A5298), Color(0xFF1E3C72)]
                          : [Color(0xFF4A90E2), Color(0xFF357ABD)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF4A90E2).withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _handleSendReset,
                      onTapDown: (_) {
                        setState(() {
                          _isSendPressed = true;
                        });
                        _scaleController.forward();
                      },
                      onTapUp: (_) {
                        setState(() {
                          _isSendPressed = false;
                        });
                        _scaleController.reverse();
                      },
                      onTapCancel: () {
                        setState(() {
                          _isSendPressed = false;
                        });
                        _scaleController.reverse();
                      },
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              lang.translate('Send now'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Info section
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.shade100,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          lang.translate('Password reset instructions will be sent to your email'),
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer removido - no se muestran créditos
            ],
          ),
        ),
      ),
    );
  }

  void _handleSendReset() async {
    // Validate form if email is not predefined
    if (widget.defaultMail == null || widget.defaultMail!.isEmpty) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    setState(() {
      showLoader = true;
    });

    try {
      final emailToSend = widget.defaultMail?.isNotEmpty == true
          ? widget.defaultMail!
          : email;

      response = await httpService.resetPassword(emailToSend);

      setState(() {
        showLoader = false;
      });

      if (response == '1') {
        // Success: show animated success dialog
        _showSuccessDialog();
      } else {
        // Error: show error message
        var msg = response!.split('/');
        String errorMessage = msg[0];
        String statusCode = msg.length > 1 ? msg[1] : '';

        // More specific error messages
        if (statusCode == '404') {
          errorMessage = lang.translate('Email not found. Please check and try again.');
        } else if (statusCode == '400') {
          errorMessage = lang.translate('Invalid email format. Please check and try again.');
        } else {
          errorMessage = lang.translate(errorMessage);
        }

        _showErrorDialog(errorMessage);
      }
    } catch (error) {
      print('[ResetPasswordPage] Error: $error');
      setState(() {
        showLoader = false;
      });

      // Connection error
      _showErrorDialog(
        lang.translate('Could not connect to server. Please check your internet connection and try again.')
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  lang.translate('Success'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkBlueColor,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Se ha enviado un correo de recuperación',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: darkBlueColor.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to login
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      lang.translate('Back to Login'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  lang.translate('Error'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkBlueColor,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: darkBlueColor.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog only
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      lang.translate('Try Again'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Not used anymore, replaced by changePassword widget
  Widget changePassword() {
    return Container();
  }

  callback() {
    Get.back();
  }

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
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
      begin: Offset(0, 0.05),
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

    // Add listener for focus changes
    _emailFocusNode.addListener(() {
      setState(() {});
    });

    // Initialize email with predefined value if exists
    if (widget.defaultMail != null && widget.defaultMail!.isNotEmpty) {
      email = widget.defaultMail!;
      _emailController.text = email;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _emailFocusNode.dispose();
    _emailController.dispose();
    currentPasswordController.dispose();
    passwordController.dispose();
    confirmedPasswordController.dispose();
    super.dispose();
  }
}