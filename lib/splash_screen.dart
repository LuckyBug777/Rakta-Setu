import 'package:flutter/material.dart';
import 'dart:math';
import 'auth_service.dart';

class SplashScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onLoginRequired;
  final VoidCallback onUserLoggedIn;
  final VoidCallback onSplashComplete;

  const SplashScreen({
    Key? key,
    required this.authService,
    required this.onLoginRequired,
    required this.onUserLoggedIn,
    required this.onSplashComplete,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bloodGroupController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _quoteAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  final List<BloodParticle> bloodParticles = [];
  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  bool _animationsCompleted = false;
  bool _authCheckCompleted = false;
  String _statusText = 'Initializing...';
  late final DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // _generateBloodParticles();
    _startAnimationSequence();
    _checkAuthenticationStatus();
  }

  void _initializeAnimations() {
    // Blood particles controller - continuous animation
    _bloodGroupController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Logo entrance controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Text entrance controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Pulse effect controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Shimmer effect controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Logo animations with bounce effect
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Text slide animation
    _textSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.elasticOut,
    ));

    _textOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    ));

    // Quote animation with delay
    _quoteAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    // Pulse animation for logo
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Shimmer animation for text
    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
  }

  void _generateBloodParticles() {
    final random = Random();
    for (int i = 0; i < 20; i++) {
      bloodParticles.add(BloodParticle(
        type: bloodTypes[random.nextInt(bloodTypes.length)],
        x: random.nextDouble(),
        y: random.nextDouble() + 0.5, // Start below screen
        speed: 0.4 + random.nextDouble() * 0.8,
        size: 30 + random.nextDouble() * 25,
        opacity: 0.4 + random.nextDouble() * 0.6,
        rotationSpeed: random.nextDouble() * 2 - 1,
        horizontalDrift: random.nextDouble() * 0.5 - 0.25,
      ));
    }
  }

  void _startAnimationSequence() async {
    // Start logo animation
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _logoController.forward();

    // Start text animation after logo begins
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) _textController.forward();

    // Mark animations as completed
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      setState(() {
        _animationsCompleted = true;
      });
      _checkIfReadyToNavigate();
    }
  }

  void _checkAuthenticationStatus() async {
    try {
      setState(() {
        _statusText = 'Checking authentication...';
      });

      print('🌟 SplashScreen: Starting authentication check...');

      // Initialize auth service and check for existing login
      final isLoggedIn = await widget.authService.isUserLoggedIn();
      print('🌟 SplashScreen: isUserLoggedIn result: $isLoggedIn');

      if (isLoggedIn) {
        setState(() {
          _statusText = 'Verifying user data...';
        });

        print('🌟 SplashScreen: User is logged in, checking user data...');

        // Get user data to verify it exists
        final userData = await widget.authService.getUserData();
        print('🌟 SplashScreen: Retrieved user data: $userData');

        if (userData != null) {
          setState(() {
            _authCheckCompleted = true;
            _statusText = 'Welcome back, ${userData['name'] ?? 'User'}!';
          });
          print('🌟 SplashScreen: User data found, proceeding to home');
          _checkIfReadyToNavigate();
        } else {
          print('🌟 SplashScreen: No user data found, trying Firestore...');
          // Try to fetch from Firestore if local data doesn't exist
          final phoneNumber = await widget.authService.getStoredPhoneNumber();
          print('🌟 SplashScreen: Phone number: $phoneNumber');
          if (phoneNumber != null) {
            final firestoreData =
                await widget.authService.getUserFromFirestore(phoneNumber);
            print('🌟 SplashScreen: Firestore data: $firestoreData');
            if (firestoreData != null) {
              await widget.authService.saveUserData(firestoreData);
              setState(() {
                _authCheckCompleted = true;
                _statusText =
                    'Welcome back, ${firestoreData['name'] ?? 'User'}!';
              });
              _checkIfReadyToNavigate();
              return;
            }
          }

          // Even if no user data, if login state exists, proceed to home
          print('🌟 SplashScreen: No user data found, but login state exists');
          setState(() {
            _authCheckCompleted = true;
            _statusText = 'Welcome back!';
          });
          _checkIfReadyToNavigate();
        }
      } else {
        print('🌟 SplashScreen: User is not logged in');
        setState(() {
          _authCheckCompleted = true;
          _statusText = 'Please sign in to continue';
        });
        _checkIfReadyToNavigate();
      }
    } catch (e) {
      print('🌟 SplashScreen: Error during authentication check: $e');
      // Handle authentication check error
      setState(() {
        _authCheckCompleted = true;
        _statusText = 'Authentication error - Please login';
      });
      _checkIfReadyToNavigate();
    }
  }

  void _checkIfReadyToNavigate() async {
    if (!_animationsCompleted || !_authCheckCompleted) {
      return; // Wait for both animations and auth check to complete
    }

    // Wait for minimum splash time
    await _waitForMinimumSplashTime();
    if (!mounted) return;

    try {
      // Check final auth status
      final isLoggedIn = await widget.authService.isUserLoggedIn();

      if (isLoggedIn) {
        setState(() {
          _statusText = 'Loading your dashboard...';
        });
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          widget.onUserLoggedIn();
        }
      } else {
        setState(() {
          _statusText = 'Redirecting to login...';
        });
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          widget.onLoginRequired();
        }
      }
    } catch (e) {
      // Fallback to login on any error
      setState(() {
        _statusText = 'Redirecting to login...';
      });
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        widget.onLoginRequired();
      }
    }
  }

  Future<void> _waitForMinimumSplashTime() async {
    // Ensure splash screen shows for at least 3 seconds total
    const minimumSplashDuration = Duration(seconds: 3);
    final elapsedTime = DateTime.now().difference(_startTime);

    if (elapsedTime < minimumSplashDuration) {
      await Future.delayed(minimumSplashDuration - elapsedTime);
    }
  }

  @override
  void dispose() {
    _bloodGroupController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.height < 700;
    final double bottomPadding = isSmallScreen ? 140 : 80;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              Color(0xFFFF6B6B), // Bright coral red
              Color(0xFFFF3838), // Vibrant red
              Color(0xFFDC143C), // Crimson
              Color(0xFFFFE5E5), // Very light pink
            ],
            stops: [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated blood particles background
            AnimatedBuilder(
              animation: _bloodGroupController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: BloodParticlePainter(
                    particles: bloodParticles,
                    animationValue: _bloodGroupController.value,
                  ),
                );
              },
            ),

            // Main content with responsive layout
            SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenSize.height -
                        MediaQuery.of(context).padding.top -
                        bottomPadding,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Enhanced logo section
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _logoScaleAnimation,
                          _logoOpacityAnimation,
                          _pulseAnimation
                        ]),
                        builder: (context, child) {
                          return Opacity(
                            opacity: _logoOpacityAnimation.value,
                            child: Transform.scale(
                              scale: _logoScaleAnimation.value *
                                  _pulseAnimation.value,
                              child: Container(
                                width: isSmallScreen ? 120 : 140,
                                height: isSmallScreen ? 120 : 140,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF3838)
                                          .withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 8),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: const Color(0xFFFF3838)
                                        .withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(23),
                                  child: Image.asset(
                                    'assets/images/rakta_setu.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.bloodtype,
                                        size: 70,
                                        color: Color(0xFFFF3838),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),

                      // Enhanced app name with shimmer effect
                      AnimatedBuilder(
                        animation: Listenable.merge([
                          _textOpacityAnimation,
                          _textSlideAnimation,
                          _shimmerAnimation
                        ]),
                        builder: (context, child) {
                          return Opacity(
                            opacity: _textOpacityAnimation.value,
                            child: Transform.translate(
                              offset: Offset(0, _textSlideAnimation.value),
                              child: ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: const [
                                      Color(0xFF00FF41), // Bright matrix green
                                      Color(0xFF00CC33), // Vibrant green
                                      Color(0xFF00FF41), // Bright matrix green
                                    ],
                                    stops: [
                                      (_shimmerAnimation.value - 0.3)
                                          .clamp(0.0, 1.0),
                                      _shimmerAnimation.value.clamp(0.0, 1.0),
                                      (_shimmerAnimation.value + 0.3)
                                          .clamp(0.0, 1.0),
                                    ],
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  'Rakta Setu',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 32 : 38,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 3,
                                    shadows: const [
                                      Shadow(
                                        offset: Offset(2, 2),
                                        blurRadius: 4,
                                        color: Color(0x40000000),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 15),

                      // Subtitle
                      AnimatedBuilder(
                        animation: _textOpacityAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _textOpacityAnimation.value * 0.9,
                            child: Transform.translate(
                              offset:
                                  Offset(0, _textSlideAnimation.value * 0.7),
                              child: const Text(
                                'Bridging Lives Through Blood Donation',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: isSmallScreen ? 40 : 60),

                      // Enhanced quote section
                      AnimatedBuilder(
                        animation: _quoteAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _quoteAnimation.value,
                            child: Transform.translate(
                              offset:
                                  Offset(0, 30 * (1 - _quoteAnimation.value)),
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: isSmallScreen ? 20 : 30),
                                padding:
                                    EdgeInsets.all(isSmallScreen ? 20 : 25),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.95),
                                      Colors.white.withOpacity(0.85),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF3838)
                                          .withOpacity(0.2),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 8),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: const Color(0xFFFF3838)
                                        .withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.format_quote,
                                      color: Color(0xFFFF3838),
                                      size: 30,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Every drop counts, every donation saves a life. Blood bank management ensures hope flows where it\'s needed most.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        fontStyle: FontStyle.italic,
                                        color: const Color(0xFF2D3748),
                                        height: 1.6,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      width: 50,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFFF3838),
                                            Color(0xFFFF6B6B)
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Add extra space after quote section for better separation
                      SizedBox(height: isSmallScreen ? 50 : 30),
                    ],
                  ),
                ),
              ),
            ), // Enhanced loading indicator with dynamic status
            Positioned(
              bottom: bottomPadding,
              left: 0,
              right: 0,
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 0),
                child: AnimatedBuilder(
                  animation: _textOpacityAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textOpacityAnimation.value,
                      child: Column(
                        children: [
                          if (!_authCheckCompleted)
                            const SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 3,
                              ),
                            ),
                          const SizedBox(height: 15),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              _statusText,
                              key: ValueKey(_statusText),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: isSmallScreen ? 12 : 14,
                                fontWeight: FontWeight.w500,
                                shadows: const [
                                  Shadow(
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                    color: Colors.black26,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BloodParticle {
  String type;
  double x;
  double y;
  double speed;
  double size;
  double opacity;
  double rotation;
  double rotationSpeed;
  double horizontalDrift;

  BloodParticle({
    required this.type,
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.rotationSpeed,
    required this.horizontalDrift,
    this.rotation = 0,
  });
}

class BloodParticlePainter extends CustomPainter {
  final List<BloodParticle> particles;
  final double animationValue;

  BloodParticlePainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Calculate vertical movement
      double currentY = particle.y * size.height -
          (animationValue * particle.speed * size.height * 1.2);

      // Calculate horizontal drift
      double currentX = particle.x * size.width +
          sin(animationValue * 2 * pi + particle.x * 10) *
              particle.horizontalDrift *
              50;

      // Update rotation
      particle.rotation += particle.rotationSpeed * 0.1;

      // Reset particle when it goes off screen
      if (currentY < -particle.size) {
        particle.y = 1.3;
        particle.x = Random().nextDouble();
        currentY = particle.y * size.height;
        currentX = particle.x * size.width;
      }

      // Calculate fade out effect
      double fadeStart = size.height * 0.2;
      double currentOpacity = particle.opacity;

      if (currentY < fadeStart) {
        double fadeProgress = (fadeStart - currentY) / fadeStart;
        currentOpacity = particle.opacity * (1 - fadeProgress.clamp(0.0, 1.0));
      }

      if (currentOpacity > 0.05 && currentY > -particle.size) {
        canvas.save();
        canvas.translate(currentX, currentY);
        canvas.rotate(particle.rotation);

        // Draw particle with gradient
        final gradient = RadialGradient(
          colors: [
            const Color(0xFFFF6B6B).withOpacity(currentOpacity),
            const Color(0xFFFF3838).withOpacity(currentOpacity * 0.8),
            const Color(0xFFDC143C).withOpacity(currentOpacity * 0.6),
          ],
        );

        final paint = Paint()
          ..shader = gradient.createShader(
            Rect.fromCircle(center: Offset.zero, radius: particle.size / 2),
          );

        // Draw particle circle
        canvas.drawCircle(Offset.zero, particle.size / 2, paint);

        // Draw border
        final borderPaint = Paint()
          ..color = Colors.white.withOpacity(currentOpacity * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawCircle(Offset.zero, particle.size / 2, borderPaint);

        // Draw text
        final textPainter = TextPainter(
          text: TextSpan(
            text: particle.type,
            style: TextStyle(
              color: Colors.white.withOpacity(currentOpacity),
              fontSize: particle.size * 0.35,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black.withOpacity(currentOpacity * 0.5),
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
