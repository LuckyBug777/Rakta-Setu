import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SharedPreferences keys
  static const String _blockedUsersKey = 'blocked_users';
  static const String _userDataKey = 'user_data';
  static const String _loginStateKey = 'login_state';
  static const String _rememberMeKey = 'remember_me';
  static const String _userCredentialsKey = 'user_credentials';
  static const String _lastLoginKey = 'last_login';
  static const String _appSettingsKey = 'app_settings';

  // Cached SharedPreferences instance
  SharedPreferences? _prefs;

  // Get SharedPreferences instance (cached for performance)
  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Initialize auth service and check for existing login
  Future<bool> initializeAuth() async {
    try {
      final prefs = await _preferences;
      final isRemembered = prefs.getBool(_rememberMeKey) ?? false;
      final loginState = prefs.getString(_loginStateKey);

      if (isRemembered && loginState != null) {
        final loginData = json.decode(loginState);
        final lastLoginTime = DateTime.parse(loginData['timestamp']);
        final now = DateTime.now();

        // Check if login is still valid (e.g., within 30 days)
        if (now.difference(lastLoginTime).inDays < 30) {
          // User is still logged in, update last login
          await updateLastLogin();
          return true;
        } else {
          // Login expired, clear stored data
          await clearLoginState();
        }
      }

      return false;
    } catch (e) {
      print('Error initializing auth: $e');
      return false;
    }
  }

  // Save login state for persistent login
  Future<void> saveLoginState({
    required String phoneNumber,
    required bool rememberMe,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final prefs = await _preferences;

      if (rememberMe) {
        final loginData = {
          'phoneNumber': phoneNumber,
          'timestamp': DateTime.now().toIso8601String(),
          'isLoggedIn': true,
          'sessionId': DateTime.now().millisecondsSinceEpoch.toString(),
          if (additionalData != null) ...additionalData,
        };

        await prefs.setString(_loginStateKey, json.encode(loginData));
        await prefs.setBool(_rememberMeKey, true);
        await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
      } else {
        await prefs.setBool(_rememberMeKey, false);
      }
    } catch (e) {
      print('Error saving login state: $e');
      throw Exception('Failed to save login state');
    }
  }

  // Clear login state and all related data
  Future<void> clearLoginState() async {
    try {
      final prefs = await _preferences;
      await Future.wait([
        prefs.remove(_loginStateKey),
        prefs.remove(_rememberMeKey),
        prefs.remove(_userCredentialsKey),
        prefs.remove(_userDataKey),
      ]);
    } catch (e) {
      print('Error clearing login state: $e');
    }
  }

  // Check if user is currently logged in (including persistent login)
  Future<bool>  isUserLoggedIn() async {
    try {
      // Initialize Firebase first if needed
      await Firebase.initializeApp();

      // Check Firebase auth state first
      if (_auth.currentUser != null) {
        // Update last login time to keep session fresh
        await updateLastLogin();
        return true;
      }

      // Check persistent login state
      final prefs = await _preferences;
      final isRemembered = prefs.getBool(_rememberMeKey) ?? false;
      final loginState = prefs.getString(_loginStateKey);

      if (isRemembered && loginState != null) {
        final loginData = json.decode(loginState);
        final lastLoginTime = DateTime.parse(loginData['timestamp']);
        final now = DateTime.now();

        // Check if login is still valid (within 30 days)
        if (now.difference(lastLoginTime).inDays < 30) {
          // Update last login time to keep session fresh
          await updateLastLogin();
          return true;
        } else {
          // Login expired, clear stored data
          await clearLoginState();
        }
      }

      return false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Get stored login phone number
  Future<String?> getStoredPhoneNumber() async {
    try {
      final prefs = await _preferences;
      final loginState = prefs.getString(_loginStateKey);

      if (loginState != null) {
        final loginData = json.decode(loginState);
        return loginData['phoneNumber'];
      }

      return null;
    } catch (e) {
      print('Error getting stored phone number: $e');
      return null;
    }
  }

  // Get last login timestamp
  Future<DateTime?> getLastLoginTime() async {
    try {
      final prefs = await _preferences;
      final lastLoginString = prefs.getString(_lastLoginKey);

      if (lastLoginString != null) {
        return DateTime.parse(lastLoginString);
      }

      return null;
    } catch (e) {
      print('Error getting last login time: $e');
      return null;
    }
  }

  // Check if phone number is blocked
  Future<bool> isPhoneBlocked(String phoneNumber) async {
    try {
      final prefs = await _preferences;
      final blockedUsersJson = prefs.getString(_blockedUsersKey);

      if (blockedUsersJson != null) {
        final Map<String, dynamic> blockedUsers = json.decode(blockedUsersJson);
        final blockData = blockedUsers[phoneNumber];

        if (blockData != null) {
          final blockTime = DateTime.parse(blockData['blockTime']);
          final now = DateTime.now();

          // Check if 24 hours have passed
          if (now.difference(blockTime).inHours < 24) {
            return true;
          } else {
            // Remove expired block
            blockedUsers.remove(phoneNumber);
            await prefs.setString(_blockedUsersKey, json.encode(blockedUsers));
            return false;
          }
        }
      }

      return false;
    } catch (e) {
      print('Error checking if phone is blocked: $e');
      return false;
    }
  }

  // Block a phone number for 24 hours
  Future<void> blockPhoneNumber(String phoneNumber, {String? reason}) async {
    try {
      final prefs = await _preferences;
      final blockedUsersJson = prefs.getString(_blockedUsersKey) ?? '{}';
      final Map<String, dynamic> blockedUsers = json.decode(blockedUsersJson);

      blockedUsers[phoneNumber] = {
        'blockTime': DateTime.now().toIso8601String(),
        'reason': reason ?? 'Too many failed attempts',
        'attempts': (blockedUsers[phoneNumber]?['attempts'] ?? 0) + 1,
      };

      await prefs.setString(_blockedUsersKey, json.encode(blockedUsers));
    } catch (e) {
      print('Error blocking phone number: $e');
      throw Exception('Failed to block phone number');
    }
  }

  // Update last login time
  Future<void> updateLastLogin() async {
    try {
      final prefs = await _preferences;
      await prefs.setString(_lastLoginKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // Save user data locally
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await _preferences;
      await prefs.setString(_userDataKey, json.encode(userData));
    } catch (e) {
      print('Error saving user data: $e');
      throw Exception('Failed to save user data');
    }
  }

  // Get stored user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await _preferences;
      final userDataJson = prefs.getString(_userDataKey);

      if (userDataJson != null) {
        return json.decode(userDataJson);
      }

      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Send OTP for phone verification
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
    int? timeoutSeconds = 60,
  }) async {
    try {
      // Check if phone is blocked
      if (await isPhoneBlocked(phoneNumber)) {
        throw FirebaseAuthException(
          code: 'phone-blocked',
          message:
              'Phone number is temporarily blocked due to too many attempts',
        );
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: (FirebaseAuthException e) {
          // Block phone after too many failed attempts
          if (e.code == 'too-many-requests') {
            blockPhoneNumber(phoneNumber, reason: 'Too many OTP requests');
          }
          verificationFailed(e);
        },
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: Duration(seconds: timeoutSeconds ?? 60),
      );
    } catch (e) {
      print('Error sending OTP: $e');
      rethrow;
    }
  }

  // Verify OTP and sign in
  Future<UserCredential?> verifyOTPAndSignIn({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await updateLastLogin();
      }

      return userCredential;
    } catch (e) {
      print('Error verifying OTP: $e');
      rethrow;
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await clearLoginState();
    } catch (e) {
      print('Error signing out: $e');
      throw Exception('Failed to sign out');
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Save user credentials securely (for remember me functionality)
  Future<void> saveUserCredentials({
    required String phoneNumber,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final prefs = await _preferences;
      final credentials = {
        'phoneNumber': phoneNumber,
        'displayName': displayName,
        'photoURL': photoURL,
        'savedAt': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_userCredentialsKey, json.encode(credentials));
    } catch (e) {
      print('Error saving user credentials: $e');
      throw Exception('Failed to save user credentials');
    }
  }

  // Get saved user credentials
  Future<Map<String, dynamic>?> getSavedUserCredentials() async {
    try {
      final prefs = await _preferences;
      final credentialsJson = prefs.getString(_userCredentialsKey);

      if (credentialsJson != null) {
        return json.decode(credentialsJson);
      }

      return null;
    } catch (e) {
      print('Error getting saved user credentials: $e');
      return null;
    }
  }

  // Save app settings
  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await _preferences;
      await prefs.setString(_appSettingsKey, json.encode(settings));
    } catch (e) {
      print('Error saving app settings: $e');
      throw Exception('Failed to save app settings');
    }
  }

  // Get app settings
  Future<Map<String, dynamic>?> getAppSettings() async {
    try {
      final prefs = await _preferences;
      final settingsJson = prefs.getString(_appSettingsKey);

      if (settingsJson != null) {
        return json.decode(settingsJson);
      }

      return null;
    } catch (e) {
      print('Error getting app settings: $e');
      return null;
    }
  }

  // Check and clean expired blocks
  Future<void> cleanExpiredBlocks() async {
    try {
      final prefs = await _preferences;
      final blockedUsersJson = prefs.getString(_blockedUsersKey);

      if (blockedUsersJson != null) {
        final Map<String, dynamic> blockedUsers = json.decode(blockedUsersJson);
        final now = DateTime.now();
        final expiredUsers = <String>[];

        for (final entry in blockedUsers.entries) {
          final blockTime = DateTime.parse(entry.value['blockTime']);
          if (now.difference(blockTime).inHours >= 24) {
            expiredUsers.add(entry.key);
          }
        }

        for (final user in expiredUsers) {
          blockedUsers.remove(user);
        }

        await prefs.setString(_blockedUsersKey, json.encode(blockedUsers));
      }
    } catch (e) {
      print('Error cleaning expired blocks: $e');
    }
  }

  // Get remaining block time for a phone number
  Future<Duration?> getRemainingBlockTime(String phoneNumber) async {
    try {
      final prefs = await _preferences;
      final blockedUsersJson = prefs.getString(_blockedUsersKey);

      if (blockedUsersJson != null) {
        final Map<String, dynamic> blockedUsers = json.decode(blockedUsersJson);
        final blockData = blockedUsers[phoneNumber];

        if (blockData != null) {
          final blockTime = DateTime.parse(blockData['blockTime']);
          final now = DateTime.now();
          final elapsed = now.difference(blockTime);

          if (elapsed.inHours < 24) {
            return Duration(hours: 24) - elapsed;
          }
        }
      }

      return null;
    } catch (e) {
      print('Error getting remaining block time: $e');
      return null;
    }
  }

  Future<bool> userExists(String phoneNumber) async {
    try {
      final doc = await _firestore.collection('users').doc(phoneNumber).get();

      return doc.exists;
    } catch (e) {
      print('Error checking if user exists: $e');
      return false;
    }
  }

// Optional: Get user data from Firestore
  Future<Map<String, dynamic>?> getUserFromFirestore(String phoneNumber) async {
    try {
      final doc = await _firestore.collection('users').doc(phoneNumber).get();

      if (doc.exists) {
        return doc.data();
      }

      return null;
    } catch (e) {
      print('Error getting user from Firestore: $e');
      return null;
    }
  }

// Optional: Create or update user in Firestore
  Future<void> createOrUpdateUser({
    required String phoneNumber,
    required Map<String, dynamic> userData,
  }) async {
    try {
      await _firestore.collection('users').doc(phoneNumber).set({
        ...userData,
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error creating/updating user: $e');
      throw Exception('Failed to save user data to Firestore');
    }
  }

  // Dispose resources
  void dispose() {
    _prefs = null;
  }
}
