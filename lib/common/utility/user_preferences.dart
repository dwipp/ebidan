import 'package:shared_preferences/shared_preferences.dart';

enum UserPrefs { bannerDismissedAt, intro }

class UserPreferences {
  static final UserPreferences _instance = UserPreferences._internal();

  factory UserPreferences() {
    return _instance;
  }

  UserPreferences._internal();

  Future<void> setBool(UserPrefs userPref, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(userPref.name, value);
  }

  Future<bool> getBool(UserPrefs userPref) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(userPref.name);
    if (value == null) {
      return false;
    } else {
      return value;
    }
  }

  Future<void> setString(UserPrefs userPref, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(userPref.name, value);
  }

  Future<String?> getString(UserPrefs userPref) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(userPref.name);
    return value;
  }

  Future<void> setInt(UserPrefs userPref, int value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(userPref.name, value);
  }

  Future<int?> getInt(UserPrefs userPref) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(userPref.name);
    return value;
  }

  Future<void> remove(UserPrefs userPref) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(userPref.name);
  }
}
