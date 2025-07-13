import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final bool isLogin;
  final Map<String, dynamic>? userData;
  final VoidCallback? onVerificationComplete;

  const OTPVerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.verificationId,
    required this.isLogin,
    this.userData,
    this.onVerificationComplete,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 60;
  Timer? _timer;
  String _otpCode = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _startResendTimer();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
    });
  }

  void _startResendTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  // FIXED: Corrected the OTP verification logic
  void _verifyOTP() async {
    if (_otpCode.length != 6) {
      _showToast('Please enter complete OTP');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use the corrected AuthService method
      final userCredential = await _authService.verifyOTPAndSignIn(
        verificationId: widget.verificationId,
        smsCode: _otpCode,
      );
      if (userCredential != null && userCredential.user != null) {
        // OTP verification successful
        if (!widget.isLogin && widget.userData != null) {
          // Registration flow - save user data to both Firestore and local storage
          try {
            // Save to Firestore
            await _authService.createOrUpdateUser(
              phoneNumber: widget.phoneNumber,
              userData: widget.userData!,
            );

            // Save to local storage
            await _authService.saveUserData(widget.userData!);

            // Save login state for persistence
            await _authService.saveLoginState(
              phoneNumber: widget.phoneNumber,
              rememberMe: true,
              additionalData: widget.userData,
            );

            _showToast('Registration successful!');
          } catch (e) {
            _showToast('Registration failed: $e');
            setState(() {
              _isLoading = false;
            });
            return;
          }
        } else {
          // Login flow - handle existing users
          await _authService.updateLastLogin();

          try {
            // Try to fetch user data from Firestore first
            print(
                '🔐 OTP: Attempting to fetch user data from Firestore for ${widget.phoneNumber}');
            final firestoreUserData =
                await _authService.getUserFromFirestore(widget.phoneNumber);
            print('🔐 OTP: Firestore data received: $firestoreUserData');

            Map<String, dynamic>? userDataToSave = firestoreUserData;

            // If no Firestore data exists, try to get from local storage
            if (firestoreUserData == null) {
              print('🔐 OTP: No Firestore data, checking local storage...');
              final localUserData = await _authService.getUserData();
              userDataToSave = localUserData;
              print('🔐 OTP: Local data: $localUserData');
            }

            // Always save login state regardless of user data availability
            await _authService.saveLoginState(
              phoneNumber: widget.phoneNumber,
              rememberMe: true,
              additionalData: userDataToSave,
            );

            // Cache user data locally if we have it
            if (userDataToSave != null) {
              print(
                  '🔐 OTP: Saving user data to local storage: $userDataToSave');
              await _authService.saveUserData(userDataToSave);
            } else {
              print('🔐 OTP: No user data found, creating minimal data');
              // Create minimal user data if none exists
              final minimalUserData = {
                'phoneNumber': widget.phoneNumber,
                'name': 'User',
                'loginTime': DateTime.now().toIso8601String(),
              };
              await _authService.saveUserData(minimalUserData);
            }

            _showToast('Login successful!');
          } catch (e) {
            print('🔐 OTP: Error in login flow: $e');
            // Even if data fetching fails, save login state with minimal data
            final minimalUserData = {
              'phoneNumber': widget.phoneNumber,
              'name': 'User',
              'loginTime': DateTime.now().toIso8601String(),
            };

            await _authService.saveLoginState(
              phoneNumber: widget.phoneNumber,
              rememberMe: true,
              additionalData: minimalUserData,
            );

            await _authService.saveUserData(minimalUserData);

            _showToast('Login successful!');
            print('Warning: Could not fetch user data, using minimal data: $e');
          }
        }
        setState(() {
          _isLoading = false;
        });

        // Use a slight delay before navigating to ensure messages are displayed
        Future.delayed(const Duration(milliseconds: 800), () {
          // Check if widget is still mounted before using context
          if (!mounted) return;

          // Call the callback to notify parent if provided
          if (widget.onVerificationComplete != null) {
            // Navigate back to root and call callback to trigger state change
            Navigator.of(context).popUntil((route) => route.isFirst);
            widget.onVerificationComplete!();
          } else {
            // Fallback: If no callback provided, pop back to previous screen
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      // Handle verification failure
      setState(() {
        _isLoading = false;
      });

      String errorMessage = 'Invalid OTP. Please try again.';

      // Provide specific error messages based on the error type
      if (e.toString().contains('invalid-verification-code')) {
        errorMessage = 'Invalid OTP. Please check and try again.';
      } else if (e.toString().contains('session-expired')) {
        errorMessage = 'OTP session expired. Please request a new code.';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage =
            'Too many attempts. Phone number may be blocked for 24 hours.';
      }

      _showToast(errorMessage);

      // Clear the OTP field for retry
      _otpController.clear();
      setState(() {
        _otpCode = '';
      });
    }
  }

  void _resendOTP() async {
    if (_isResending || _resendTimer > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      await _authService.sendOTP(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification completed
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isResending = false;
          });
          _showToast('Failed to send OTP: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isResending = false;
            _resendTimer = 60;
          });
          _startResendTimer();
          _showToast('OTP sent successfully');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
        },
      );
    } catch (e) {
      setState(() {
        _isResending = false;
      });
      _showToast('Failed to resend OTP: $e');
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

  String _formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.startsWith('+91')) {
      final number = phoneNumber.substring(3);
      return '+91 ${number.substring(0, 5)}***${number.substring(8)}';
    }
    return phoneNumber;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    _pulseController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.height < 700;

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
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: isSmallScreen ? 20 : 40),

                  // Back Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 30 : 60),

                  // Header with animated icon
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: isSmallScreen ? 90 : 120,
                          height: isSmallScreen ? 90 : 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF3838).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.sms_outlined,
                            size: isSmallScreen ? 45 : 60,
                            color: Color(0xFFFF3838),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 40),

                  Text(
                    'Verify Phone Number',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 24 : 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 10 : 15),

                  Text(
                    'We\'ve sent a verification code to',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    _formatPhoneNumber(widget.phoneNumber),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 30 : 60),

                  // OTP Input Container with responsive padding
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 0),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8 : 25,
                      vertical: isSmallScreen ? 15 : 25,
                    ),
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
                      children: [
                        Text(
                          'Enter Verification Code',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),

                        SizedBox(
                            height: isSmallScreen
                                ? 20
                                : 30), // PIN Code Fields with responsive sizing
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // Calculate optimal field width based on available space
                            final availableWidth = constraints.maxWidth;
                            final spacing = 8.0; // Space between fields
                            final totalSpacing =
                                spacing * 5; // 5 spaces between 6 fields
                            final fieldWidth =
                                (availableWidth - totalSpacing) / 6;

                            // Ensure minimum and maximum field sizes
                            final optimalFieldWidth = fieldWidth.clamp(
                              isSmallScreen ? 28.0 : 35.0, // minimum
                              isSmallScreen ? 40.0 : 50.0, // maximum
                            );

                            return PinCodeTextField(
                              appContext: context,
                              length: 6,
                              controller: _otpController,
                              animationType: AnimationType.fade,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(
                                    isSmallScreen ? 8 : 12),
                                fieldHeight: isSmallScreen ? 35 : 55,
                                fieldWidth: optimalFieldWidth,
                                activeFillColor: const Color(0xFFF7FAFC),
                                inactiveFillColor: const Color(0xFFF7FAFC),
                                selectedFillColor:
                                    const Color(0xFFFF3838).withOpacity(0.1),
                                activeColor: const Color(0xFFFF3838),
                                inactiveColor: const Color(0xFFE2E8F0),
                                selectedColor: const Color(0xFFFF3838),
                                borderWidth: isSmallScreen ? 1.5 : 2,
                              ),
                              enableActiveFill: true,
                              keyboardType: TextInputType.number,
                              textStyle: TextStyle(
                                fontSize: isSmallScreen ? 14 : 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2D3748),
                              ),
                              onCompleted: (value) {
                                setState(() {
                                  _otpCode = value;
                                });
                              },
                              onChanged: (value) {
                                setState(() {
                                  _otpCode = value;
                                });
                              },
                            );
                          },
                        ),
                        SizedBox(height: isSmallScreen ? 15 : 25),

                        // Verify Button
                        Container(
                          width: double.infinity,
                          height: isSmallScreen ? 45 : 55,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _otpCode.length == 6
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
                            boxShadow: _otpCode.length == 6
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
                              onTap: _otpCode.length == 6 && !_isLoading
                                  ? _verifyOTP
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
                                            Colors.white,
                                          ),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Verify OTP',
                                        style: TextStyle(
                                          color: Colors.white,
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

                  // Resend OTP Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive the code? ",
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                      if (_resendTimer > 0)
                        Text(
                          'Resend in ${_resendTimer}s',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: _resendOTP,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: _isResending
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.black,
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Resend OTP',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20), // Help Text
                  Container(
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.only(top: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.white.withOpacity(0.8),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'The verification code will expire in 10 minutes',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.security_outlined,
                              color: Colors.white.withOpacity(0.8),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Never share your OTP with anyone for security',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}
