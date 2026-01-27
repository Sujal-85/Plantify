import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/preference_service.dart';

enum UserRole { farmer, researcher, plantLover, commonUser }

class UserProvider extends ChangeNotifier {
  final PreferenceService? _prefs;
  UserRole _role = UserRole.farmer; 

  String _name = 'Andrew Ainsley';
  String _email = 'andrew.ainsley@yourdomain.com';
  String _phone = '+1 111 467 378 399';
  String _birthdate = '12/27/1995';
  String _profileImage = '';
  String _uid = '';

  // ... inside UserProvider class

  // Backend URL (Emulator)
  static const String baseUrl = 'http://192.168.1.70:3000/api/users';
  
  UserProvider([this._prefs]) {
    if (_prefs != null) {
      setRoleFromString(_prefs.userRole);
    }
    // Fetch profile on init
    loadUserFromPrefs();
    fetchUserProfile(); 
  }

  void loadUserFromPrefs() {
    if (_prefs == null) return;
    
    final uid = _prefs!.userUid;
    if (uid != null && uid.isNotEmpty) {
      _uid = uid;
      _name = _prefs!.userName ?? _name;
      _email = _prefs!.userEmail ?? _email;
      _profileImage = _prefs!.userPhoto ?? _profileImage;
      notifyListeners();
    }
  }

  Future<void> fetchUserProfile({String? email}) async {
    try {
      final targetEmail = email ?? _email; // Use passed email or current fallback
      // In a real app, you might want to get this from FirebaseAuth:
      // final firebaseUser = FirebaseAuth.instance.currentUser;
      // final targetEmail = email ?? firebaseUser?.email;

      if (targetEmail == null || targetEmail == 'andrew.ainsley@yourdomain.com') return;

      final response = await http.get(Uri.parse('$baseUrl/$targetEmail'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _name = data['name'] ?? _name;
        _email = data['email'] ?? _email;
        _phone = data['phone'] ?? _phone;
        _profileImage = data['profileImage'] ?? _profileImage; 
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  // ... rest of existing methods


  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get birthdate => _birthdate;
  String get profileImage => _profileImage;
  String get uid => _uid;

  void updateProfile({String? name, String? email, String? phone, String? birthdate, String? uid}) {
    if (name != null) _name = name;
    if (email != null) _email = email;
    if (phone != null) _phone = phone;
    if (birthdate != null) _birthdate = birthdate;
    if (uid != null) _uid = uid;

    // Persist changes
    if (_prefs != null && _uid.isNotEmpty) {
        _prefs!.saveUserProfile(uid: _uid, name: _name, email: _email, photoUrl: _profileImage);
    }
    notifyListeners();
  }

  Future<void> clearUser() async {
      _name = 'Guest';
      _email = '';
      _uid = '';
      _profileImage = '';
      await _prefs?.clear();
      notifyListeners();
  }

  UserRole get role => _role;

  bool get isFarmer => _role == UserRole.farmer;
  bool get isPlantLover => _role == UserRole.plantLover;
  bool get isResearcher => _role == UserRole.researcher;

  void setRole(UserRole newRole) {
    if (_role != newRole) {
      _role = newRole;
      _prefs?.setUserRole(_roleToString(newRole));
      notifyListeners();
    }
  }

  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.farmer: return 'Farmer';
      case UserRole.researcher: return 'Researcher';
      case UserRole.plantLover: return 'Plant Lover';
      case UserRole.commonUser: return 'Common User';
    }
  }

  void setRoleFromString(String? roleString) {
    if (roleString == null) return;
    
    UserRole? newRole;
    switch (roleString) {
      case 'Farmer':
        newRole = UserRole.farmer;
        break;
      case 'Researcher':
        newRole = UserRole.researcher;
        break;
      case 'Plant Lover':
        newRole = UserRole.plantLover;
        break;
      case 'Common User':
        newRole = UserRole.commonUser;
        break;
    }

    if (newRole != null && _role != newRole) {
      _role = newRole;
      _prefs?.setUserRole(roleString);
      notifyListeners();
    }
  }

  void toggleRole() {
    _role = (_role == UserRole.farmer) 
        ? UserRole.plantLover 
        : UserRole.farmer;
    notifyListeners();
  }
}
