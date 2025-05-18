import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  final SharedPreferencesAsync _instance = SharedPreferencesAsync();

  Future<void> set({
    required String key,
    required String value,
  }) {
    return _instance.setString(key, value);
  }

  Future<String?> get({required String key}) {
    return _instance.getString(key);
  }

  Future<void> unset({required String key}) {
    return _instance.remove(key);
  }

  Future<void> setDynamic({required String key, required dynamic value}) {
    return _instance.setString(key, jsonEncode(value));
  }

  Future<dynamic> getMap({required String key}) async {
    try {
      var item = await get(key: key);

      if (item != null) {
        return jsonDecode(item);
      }

      return {};
    } catch (e) {
      return {};
    }
  }

  Future<dynamic> getArray({required String key}) async {
    try {
      var item = await get(key: key);

      if (item != null) {
        return jsonDecode(item);
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}
