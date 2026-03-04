import 'package:shared_preferences/shared_preferences.dart';

abstract interface class LocalDatabase {
  Future<void> saveData(String key, String value);

  Future<String?> getData(String key);

  Future<void> deleteData(String key);
}

class PreferencesLocalDatabase implements LocalDatabase {
  late SharedPreferences _prefs;

  Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveData(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<String?> getData(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> deleteData(String key) async {
    await _prefs.remove(key);
  }
}
