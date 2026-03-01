import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _loggedInKey = 'is_logged_in';
  static const _emailKey = 'user_email';
  static const _nameKey = 'user_display_name';

  static bool _isLoggedIn = false;
  static String? _email;
  static String? _displayName;

  static bool get isLoggedIn => _isLoggedIn;
  static String? get email => _email;
  static String? get displayName => _displayName;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_loggedInKey) ?? false;
    _email = prefs.getString(_emailKey);
    _displayName = prefs.getString(_nameKey);
  }

  static Future<void> signUp({required String email, required String password, String? name}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
    await prefs.setString(_emailKey, email);
    if (name != null) await prefs.setString(_nameKey, name);
    _isLoggedIn = true;
    _email = email;
    _displayName = name;
  }

  static Future<void> signIn({required String email, required String password}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, true);
    await prefs.setString(_emailKey, email);
    _isLoggedIn = true;
    _email = email;
  }

  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, false);
    _isLoggedIn = false;
  }

  static Future<void> updateDisplayName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    _displayName = name;
  }

  static Future<void> resetPassword(String email) async {
    // Placeholder - would send email in production
  }
}
