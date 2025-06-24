import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefsDebug {
  // Singleton instance
  static final SharedPrefsDebug _instance = SharedPrefsDebug._internal();
  factory SharedPrefsDebug() => _instance;
  SharedPrefsDebug._internal();

  // Check if shared preferences are working correctly
  static Future<bool> checkSharedPreferences() async {
    try {
      print('🔍 Checking shared preferences...');

      // Get shared preferences instance
      final prefs = await SharedPreferences.getInstance();

      // Try to write a test value
      final testKey =
          'shared_prefs_test_${DateTime.now().millisecondsSinceEpoch}';
      final testValue = 'test_value_${DateTime.now().millisecondsSinceEpoch}';

      print('📝 Writing test value: $testKey = $testValue');
      await prefs.setString(testKey, testValue);

      // Try to read the test value
      final readValue = prefs.getString(testKey);
      print('📖 Read test value: $testKey = $readValue');

      // Validate the read value
      if (readValue == testValue) {
        print('✅ Shared preferences test passed!');

        // Clean up test key
        await prefs.remove(testKey);
        return true;
      } else {
        print('❌ Shared preferences test failed: Value mismatch');
        return false;
      }
    } catch (e) {
      print('❌ Shared preferences test failed with error: $e');
      return false;
    }
  }

  // Dump all shared preferences for debugging
  static Future<void> dumpAllPreferences() async {
    try {
      print('📋 Dumping all shared preferences:');

      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      if (keys.isEmpty) {
        print('   No shared preferences found.');
        return;
      }

      for (final key in keys) {
        final value = prefs.get(key);
        String valueString;

        // Format value for better readability
        if (value is String) {
          try {
            // Check if it's a JSON string
            final jsonValue = json.decode(value);
            valueString = json.encode(jsonValue); // Pretty print
          } catch (_) {
            valueString = value;
          }
        } else {
          valueString = value.toString();
        }

        print('   $key = $valueString');
      }

      print('📋 End of shared preferences dump');
    } catch (e) {
      print('❌ Error dumping shared preferences: $e');
    }
  }

  // Clear all shared preferences (for troubleshooting)
  static Future<bool> clearAllPreferences() async {
    try {
      print('🧹 Clearing all shared preferences...');

      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.clear();

      if (result) {
        print('✅ Successfully cleared all shared preferences');
      } else {
        print('❌ Failed to clear shared preferences');
      }

      return result;
    } catch (e) {
      print('❌ Error clearing shared preferences: $e');
      return false;
    }
  }
}
