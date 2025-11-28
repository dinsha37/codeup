import 'package:shared_preferences/shared_preferences.dart';

/// A helper class to simplify SharedPreferences operations
class SharedPrefsHelper {
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences instance
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance (initialize if needed)
  static Future<SharedPreferences> get _instance async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ==================== String Operations ====================

  /// Save a string value
  static Future<bool> setString(String key, String value) async {
    final prefs = await _instance;
    return await prefs.setString(key, value);
  }

  /// Get a string value
  static Future<String?> getString(String key) async {
    final prefs = await _instance;
    return prefs.getString(key);
  }

  // ==================== Int Operations ====================

  /// Save an integer value
  static Future<bool> setInt(String key, int value) async {
    final prefs = await _instance;
    return await prefs.setInt(key, value);
  }

  /// Get an integer value
  static Future<int?> getInt(String key) async {
    final prefs = await _instance;
    return prefs.getInt(key);
  }

  // ==================== Double Operations ====================

  /// Save a double value
  static Future<bool> setDouble(String key, double value) async {
    final prefs = await _instance;
    return await prefs.setDouble(key, value);
  }

  /// Get a double value
  static Future<double?> getDouble(String key) async {
    final prefs = await _instance;
    return prefs.getDouble(key);
  }

  // ==================== Bool Operations ====================

  /// Save a boolean value
  static Future<bool> setBool(String key, bool value) async {
    final prefs = await _instance;
    return await prefs.setBool(key, value);
  }

  /// Get a boolean value
  static Future<bool?> getBool(String key) async {
    final prefs = await _instance;
    return prefs.getBool(key);
  }

  // ==================== List<String> Operations ====================

  /// Save a list of strings
  static Future<bool> setStringList(String key, List<String> value) async {
    final prefs = await _instance;
    return await prefs.setStringList(key, value);
  }

  /// Get a list of strings
  static Future<List<String>?> getStringList(String key) async {
    final prefs = await _instance;
    return prefs.getStringList(key);
  }

  // ==================== Utility Operations ====================

  /// Check if a key exists
  static Future<bool> containsKey(String key) async {
    final prefs = await _instance;
    return prefs.containsKey(key);
  }

  /// Remove a specific key
  static Future<bool> remove(String key) async {
    final prefs = await _instance;
    return await prefs.remove(key);
  }

  /// Clear all stored data
  static Future<bool> clear() async {
    final prefs = await _instance;
    return await prefs.clear();
  }

  /// Get all keys
  static Future<Set<String>> getAllKeys() async {
    final prefs = await _instance;
    return prefs.getKeys();
  }

  /// Reload preferences from storage
  static Future<void> reload() async {
    final prefs = await _instance;
    await prefs.reload();
  }
}
