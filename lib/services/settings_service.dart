import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/storage_keys.dart';

class SettingsService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  bool get onboardingComplete =>
      _prefs.getBool(StorageKeys.onboardingComplete) ?? false;

  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(StorageKeys.onboardingComplete, value);

  String get displayName => _prefs.getString(StorageKeys.displayName) ?? '';

  Future<void> setDisplayName(String value) =>
      _prefs.setString(StorageKeys.displayName, value);

  /// Default dark (premium mining look).
  bool get darkMode => _prefs.getBool(StorageKeys.darkMode) ?? true;

  Future<void> setDarkMode(bool value) =>
      _prefs.setBool(StorageKeys.darkMode, value);

  bool get notificationsEnabled =>
      _prefs.getBool(StorageKeys.notificationsEnabled) ?? false;

  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool(StorageKeys.notificationsEnabled, value);

  String get languageCode =>
      _prefs.getString(StorageKeys.languageCode) ?? 'en';

  Future<void> setLanguageCode(String value) =>
      _prefs.setString(StorageKeys.languageCode, value);

  List<String> get bookmarks =>
      _prefs.getStringList(StorageKeys.bookmarkedArticles) ?? [];

  Future<void> toggleBookmark(String articleId) async {
    final list = [...bookmarks];
    if (list.contains(articleId)) {
      list.remove(articleId);
    } else {
      list.add(articleId);
    }
    await _prefs.setStringList(StorageKeys.bookmarkedArticles, list);
  }

  bool isBookmarked(String articleId) => bookmarks.contains(articleId);
}
