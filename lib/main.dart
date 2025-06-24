import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // This will be generated
import 'splash_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart'; // Your separate home screen
import 'auth_service.dart'; // The AuthService we created
import 'shared_prefs_debug.dart'; // For debugging shared preferences
import 'enhanced_auth_service.dart'; // Enhanced AuthService with better logging

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Debug shared preferences
  final prefsWorking = await SharedPrefsDebug.checkSharedPreferences();
  if (!prefsWorking) {
    print('⚠️ WARNING: Shared preferences not working correctly!');
    await SharedPrefsDebug.clearAllPreferences();
    await SharedPrefsDebug.checkSharedPreferences();
  } else {
    print('✅ Shared preferences working correctly');
    await SharedPrefsDebug.dumpAllPreferences();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rakta Setu',
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF3838),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF3838),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AuthService _authService = EnhancedAuthService();
  AppState _currentState = AppState.splash;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // Clean up any expired blocks
      await _authService.cleanExpiredBlocks();

      // Always start with splash screen
      if (mounted) {
        setState(() {
          _currentState = AppState.splash;
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing app: $e');
      if (mounted) {
        setState(() {
          _currentState = AppState.splash;
          _isInitialized = true;
        });
      }
    }
  }

  void _handleLoginRequired() {
    if (mounted) {
      setState(() {
        _currentState = AppState.login;
      });
    }
  }

  void _handleUserLoggedIn() {
    if (mounted) {
      setState(() {
        _currentState = AppState.home;
      });
    }
  }

  void _handleSplashComplete() {
    if (mounted) {
      setState(() {
        _currentState = AppState.login;
      });
    }
  }

  Future<void> _handleLoginSuccess() async {
    try {
      // Update last login time
      await _authService.updateLastLogin();

      if (mounted) {
        setState(() {
          _currentState = AppState.home;
        });
      }
    } catch (e) {
      print('Error handling login success: $e');
      // Still navigate to home even if there's an error updating login time
      if (mounted) {
        setState(() {
          _currentState = AppState.home;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();

      if (mounted) {
        setState(() {
          _currentState = AppState.login;
        });
      }
    } catch (e) {
      print('Error during logout: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while initializing
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFF6B6B),
                  Color(0xFFFF3838),
                  Color(0xFFDC143C),
                ],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bloodtype,
                    size: 100,
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Initializing Rakta Setu...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    switch (_currentState) {
      case AppState.splash:
        return SplashScreen(
          authService: _authService,
          onLoginRequired: _handleLoginRequired,
          onUserLoggedIn: _handleUserLoggedIn,
          onSplashComplete: _handleSplashComplete,
        );

      case AppState.login:
        return LoginScreen(
          authService: _authService,
          onLoginSuccess: _handleLoginSuccess,
        );

      case AppState.home:
        return HomeScreen(
          authService: _authService,
          onLogout: _handleLogout,
        );

      default:
        return SplashScreen(
          authService: _authService,
          onLoginRequired: _handleLoginRequired,
          onUserLoggedIn: _handleUserLoggedIn,
          onSplashComplete: _handleSplashComplete,
        );
    }
  }
}

// Enum to track app state
enum AppState {
  splash,
  login,
  home,
}

// Error handling widget for display errors
class ErrorScreen extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorScreen({
    Key? key,
    required this.error,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6B6B),
              Color(0xFFFF3838),
              Color(0xFFDC143C),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  error,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF3838),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
