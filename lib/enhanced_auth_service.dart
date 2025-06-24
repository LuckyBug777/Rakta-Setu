import 'auth_service.dart';
import 'shared_prefs_debug.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnhancedAuthService extends AuthService {
  // Keys to match the private ones in AuthService
  static const String _rememberMeKey = 'remember_me';
  static const String _loginStateKey = 'login_state';

  // Override the login state saving with enhanced error handling
  @override
  Future<void> saveLoginState({
    required String phoneNumber,
    required bool rememberMe,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      print('📝 Saving login state for $phoneNumber (rememberMe: $rememberMe)');
      await super.saveLoginState(
        phoneNumber: phoneNumber,
        rememberMe: rememberMe,
        additionalData: additionalData,
      );

      // Verify the data was saved correctly using SharedPreferences directly
      final prefs = await SharedPreferences.getInstance();
      final isRemembered = prefs.getBool(_rememberMeKey) ?? false;
      final loginState = prefs.getString(_loginStateKey);

      print(
          '✅ Login state saved: isRemembered=$isRemembered, hasLoginState=${loginState != null}');

      // Dump all preferences for debugging
      await SharedPrefsDebug.dumpAllPreferences();
    } catch (e) {
      print('❌ Error saving login state: $e');
      rethrow;
    }
  }

  // Override the check for login status with better logging
  @override
  Future<bool> isUserLoggedIn() async {
    try {
      print('🔍 Checking if user is logged in...');

      // Check Firebase auth first
      final firebaseUser = super.getCurrentUser();
      if (firebaseUser != null) {
        print('✅ User is logged in via Firebase: ${firebaseUser.uid}');
        await super.updateLastLogin();
        return true;
      }
      // Check shared preferences directly
      final prefs = await SharedPreferences.getInstance();
      final isRemembered = prefs.getBool(_rememberMeKey) ?? false;
      final loginState = prefs.getString(_loginStateKey);

      print(
          '📊 SharedPrefs state: isRemembered=$isRemembered, hasLoginState=${loginState != null}');

      if (isRemembered && loginState != null) {
        print('✅ User has remembered login state in SharedPreferences');
        await super.updateLastLogin();
        return true;
      }

      print('❌ User is not logged in');
      return false;
    } catch (e) {
      print('❌ Error checking login status: $e');
      return false;
    }
  }

  // Override clear login state with better logging
  @override
  Future<void> clearLoginState() async {
    try {
      print('🧹 Clearing login state...');
      await super.clearLoginState();
      print('✅ Login state cleared');

      // Verify the data was cleared correctly
      await SharedPrefsDebug.dumpAllPreferences();
    } catch (e) {
      print('❌ Error clearing login state: $e');
      rethrow;
    }
  }
}
