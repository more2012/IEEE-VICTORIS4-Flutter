import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    print('✅ Storage Service initialized');
  }

  // String operations
  static Future<bool> setString(String key, String value) async {
    try {
      return await _prefs?.setString(key, value) ?? false;
    } catch (e) {
      print('⚠️ Error setting string for key $key: $e');
      return false;
    }
  }

  static String? getString(String key) {
    try {
      return _prefs?.getString(key);
    } catch (e) {
      print('⚠️ Error getting string for key $key: $e');
      return null;
    }
  }

  // ✅ NEW: Boolean operations
  static Future<bool> setBool(String key, bool value) async {
    try {
      return await _prefs?.setBool(key, value) ?? false;
    } catch (e) {
      print('⚠️ Error setting bool for key $key: $e');
      return false;
    }
  }

  static bool? getBool(String key) {
    try {
      return _prefs?.getBool(key);
    } catch (e) {
      print('⚠️ Error getting bool for key $key: $e');
      return null;
    }
  }

  // ✅ NEW: Integer operations
  static Future<bool> setInt(String key, int value) async {
    try {
      return await _prefs?.setInt(key, value) ?? false;
    } catch (e) {
      print('⚠️ Error setting int for key $key: $e');
      return false;
    }
  }

  static int? getInt(String key) {
    try {
      return _prefs?.getInt(key);
    } catch (e) {
      print('⚠️ Error getting int for key $key: $e');
      return null;
    }
  }

  // ✅ NEW: Double operations
  static Future<bool> setDouble(String key, double value) async {
    try {
      return await _prefs?.setDouble(key, value) ?? false;
    } catch (e) {
      print('⚠️ Error setting double for key $key: $e');
      return false;
    }
  }

  static double? getDouble(String key) {
    try {
      return _prefs?.getDouble(key);
    } catch (e) {
      print('⚠️ Error getting double for key $key: $e');
      return null;
    }
  }

  // ✅ NEW: String list operations
  static Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _prefs?.setStringList(key, value) ?? false;
    } catch (e) {
      print('⚠️ Error setting string list for key $key: $e');
      return false;
    }
  }

  static List<String>? getStringList(String key) {
    try {
      return _prefs?.getStringList(key);
    } catch (e) {
      print('⚠️ Error getting string list for key $key: $e');
      return null;
    }
  }

  // ✅ NEW: Remove operations
  static Future<bool> remove(String key) async {
    try {
      return await _prefs?.remove(key) ?? false;
    } catch (e) {
      print('⚠️ Error removing key $key: $e');
      return false;
    }
  }

  // ✅ NEW: Clear all data
  static Future<bool> clear() async {
    try {
      return await _prefs?.clear() ?? false;
    } catch (e) {
      print('⚠️ Error clearing all data: $e');
      return false;
    }
  }

  // ✅ NEW: Check if key exists
  static bool containsKey(String key) {
    try {
      return _prefs?.containsKey(key) ?? false;
    } catch (e) {
      print('⚠️ Error checking key $key: $e');
      return false;
    }
  }

  // ✅ NEW: Get all keys
  static Set<String> getAllKeys() {
    try {
      return _prefs?.getKeys() ?? <String>{};
    } catch (e) {
      print('⚠️ Error getting all keys: $e');
      return <String>{};
    }
  }

  // ✅ NEW: Get storage size info
  static int getStorageSize() {
    try {
      final keys = getAllKeys();
      return keys.length;
    } catch (e) {
      print('⚠️ Error getting storage size: $e');
      return 0;
    }
  }

  // ✅ NEW: Debug method to print all stored data
  static void debugPrintAllData() {
    try {
      final keys = getAllKeys();
      print('📋 Storage Debug Info:');
      print('   Total keys: ${keys.length}');

      for (String key in keys) {
        final value = _prefs?.get(key);
        print('   $key: $value');
      }
    } catch (e) {
      print('⚠️ Error debugging storage: $e');
    }
  }
}
