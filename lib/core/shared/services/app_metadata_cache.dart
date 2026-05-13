import 'package:shared_preferences/shared_preferences.dart';

class AppMetadataCache {
  static const _jsonKey = 'app_metadata_json';

  const AppMetadataCache();

  Future<String?> readRawJson() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_jsonKey);
    if (value == null || value.trim().isEmpty) return null;
    return value;
  }

  Future<void> writeRawJson(String rawJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_jsonKey, rawJson);
  }
}
