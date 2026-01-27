import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService extends ChangeNotifier {
  static const String _keyIsRegistered = 'is_registered';
  static const String _keyUserRole = 'user_role';
  static const String _keyHasSeenAIWelcome = 'has_seen_ai_welcome';
  static const String _keySelectedCrops = 'selected_crops';
  static const String _keyLanguageCode = 'language_code';
  // User Profile Keys
  static const String _keyUserUid = 'user_uid';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPhoto = 'user_photo';

  final SharedPreferences _prefs;

  PreferenceService(this._prefs);

  static Future<PreferenceService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferenceService(prefs);
  }

  // Locale Support
  Locale get currentLocale {
    final languageCode = _prefs.getString(_keyLanguageCode) ?? 'en';
    return Locale(languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setString(_keyLanguageCode, locale.languageCode);
    notifyListeners();
  }

  bool get isRegistered => _prefs.getBool(_keyIsRegistered) ?? false;

  Future<void> setRegistered(bool value) async {
    await _prefs.setBool(_keyIsRegistered, value);
    notifyListeners();
  }

  bool get hasSeenAIAssistantWelcome => _prefs.getBool(_keyHasSeenAIWelcome) ?? false;

  Future<void> setSeenAIAssistantWelcome(bool value) async {
    await _prefs.setBool(_keyHasSeenAIWelcome, value);
    notifyListeners();
  }

  List<String> get selectedCrops => _prefs.getStringList(_keySelectedCrops) ?? [];

  Future<void> setSelectedCrops(List<String> crops) async {
    await _prefs.setStringList(_keySelectedCrops, crops);
    notifyListeners();
  }

  String? get userRole => _prefs.getString(_keyUserRole);

  Future<void> setUserRole(String? role) async {
    if (role != null) {
      await _prefs.setString(_keyUserRole, role);
    } else {
      await _prefs.remove(_keyUserRole);
    }
    notifyListeners();
  }

  // User Profile Methods
  String? get userUid => _prefs.getString(_keyUserUid);
  String? get userName => _prefs.getString(_keyUserName);
  String? get userEmail => _prefs.getString(_keyUserEmail);
  String? get userPhoto => _prefs.getString(_keyUserPhoto);

  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    await _prefs.setString(_keyUserUid, uid);
    await _prefs.setString(_keyUserName, name);
    await _prefs.setString(_keyUserEmail, email);
    if (photoUrl != null) {
      await _prefs.setString(_keyUserPhoto, photoUrl);
    }
    notifyListeners();
  }

  Future<void> clear() async {
    await _prefs.remove(_keyUserUid);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserPhoto);
    // Keep other prefs like language or seen welcome if desired, or clear all:
    // await _prefs.clear(); 
    // sticking to clearing specific auth data to allow app reset but keeping settings is usually better, 
    // but the original code cleared everything. Let's revert to clearing everything BUT keep logic clean.
    await _prefs.clear(); 
    notifyListeners();
  }
}
