import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefUtil {
  static const String _tokenKey = 'user_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userFirstNameKey = 'user_first_name';
  static const String _userLastNameKey = 'user_last_name';
  static const String _hasSeenWelcomeKey = 'has_seen_welcome';
  static const String _isFirstTimeKey = 'is_first_time';

  // Token management
  static Future<bool> saveUserToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_tokenKey, token);
  }

  static Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // User data management
  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  static Future<void> saveUserFirstName(String firstName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userFirstNameKey, firstName);
  }

  static Future<void> saveUserLastName(String lastName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userLastNameKey, lastName);
  }

  static Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, email);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<String?> getUserFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userFirstNameKey);
  }

  static Future<String?> getUserLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userLastNameKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Welcome screen management
  static Future<void> setWelcomeScreenSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenWelcomeKey, true);
  }

  static Future<bool> hasSeenWelcomeScreen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenWelcomeKey) ?? false;
  }

  // First time management
  static Future<void> setFirstTime(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstTimeKey, value);
  }

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstTimeKey) ?? true;
  }

  // Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    final token = await getUserToken();
    return token != null && token.isNotEmpty;
  }

  // Legacy method for compatibility
  static Future<bool> isLoggedIn() async {
    return isUserLoggedIn();
  }

  // Clear user data
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userFirstNameKey);
    await prefs.remove(_userLastNameKey);
    await prefs.remove(_userEmailKey);
  }

  // Clear all data (for logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Reset welcome screen flag
  static Future<void> resetWelcomeScreenFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasSeenWelcomeKey);
  }

  // Remove user token (logout)
  static Future<bool> removeUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(_tokenKey);
  }

  // Dark mode preference
  static Future<bool> getDarkModePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('dark_mode') ?? false;
  }

  static Future<void> setDarkModePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
  }
}
