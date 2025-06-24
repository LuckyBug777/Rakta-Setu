import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'auth_service.dart';
import 'otp_verification_screen.dart';
import 'register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onLoginSuccess;

  const LoginScreen({
    Key? key,
    required this.authService,
    required this.onLoginSuccess,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  void _validatePhone(String phone) {
    setState(() {
      _isPhoneValid =
          phone.length == 10 && RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
    });
  }

  void _sendOTP() async {
    if (!_isPhoneValid) {
      _showToast('Please enter a valid phone number');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final phoneNumber = '+91${_phoneController.text.trim()}';

    try {
      await widget.authService.sendOTP(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification completed (rarely happens)
          setState(() {
            _isLoading = false;
          });
          widget.onLoginSuccess();
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
          });

          String errorMessage = 'Failed to send OTP';
          if (e.code == 'phone-blocked') {
            errorMessage =
                'Phone number is temporarily blocked. Please try after 24 hours.';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many requests. Please try again later.';
          } else if (e.message != null) {
            errorMessage = e.message!;
          }

          _showToast(errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                phoneNumber: phoneNumber,
                verificationId: verificationId,
                isLogin: true,
                onVerificationComplete: () {
                  widget.onLoginSuccess();
                },
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle timeout - usually nothing special needed here
          print('Auto retrieval timeout for verification ID: $verificationId');
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showToast('Error: $e');
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: const Color(0xFFFF3838),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Color(0xFFFF6B6B),
              Color(0xFFFF3838),
              Color(0xFFDC143C),
              Color(0xFFFFE5E5),
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),

                    // Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFF3838).withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/rakta_setu.png',
                              width: 50,
                              height: 50,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Login to continue saving lives',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80),

                    // Phone Number Input
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF3838).withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Phone Number',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 15),

                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7FAFC),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: _isPhoneValid
                                    ? const Color(0xFF00FF41)
                                    : const Color(0xFFE2E8F0),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF3838)
                                        .withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(13),
                                      bottomLeft: Radius.circular(13),
                                    ),
                                  ),
                                  child: const Text(
                                    '+91',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFF3838),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    onChanged: _validatePhone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: const InputDecoration(
                                      hintText: 'Enter your phone number',
                                      hintStyle: TextStyle(
                                        color: Color(0xFFA0AEC0),
                                        fontSize: 16,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 20,
                                      ),
                                      counterText: '',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                ),
                                if (_isPhoneValid)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 16),
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF00FF41),
                                      size: 24,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          if (_phoneController.text.isNotEmpty &&
                              !_isPhoneValid)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Please enter a valid 10-digit phone number',
                                style: TextStyle(
                                  color: Color(0xFFFF3838),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                          const SizedBox(height: 30),

                          // Login Button
                          Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isPhoneValid
                                    ? [
                                        const Color(0xFFFF3838),
                                        const Color(0xFFFF6B6B)
                                      ]
                                    : [
                                        const Color(0xFFE2E8F0),
                                        const Color(0xFFA0AEC0)
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: _isPhoneValid
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFFF3838)
                                            .withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: _isPhoneValid && !_isLoading
                                    ? _sendOTP
                                    : null,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.red,
                                            ),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Send OTP',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Register Link
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterScreen(
                                    onRegistrationSuccess:
                                        widget.onLoginSuccess,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: Colors.greenAccent.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'Register Now',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
