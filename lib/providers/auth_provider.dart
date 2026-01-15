import 'package:flutter/material.dart';
import 'package:piaget/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserProfile? _currentUser;
  UserRole? _selectedRole;
  bool _isAuthenticated = false;

  UserProfile? get currentUser => _currentUser;
  UserRole? get selectedRole => _selectedRole;
  bool get isAuthenticated => _isAuthenticated;

  void setUserRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }

  void login(String id, String name, UserRole role, {String? email}) {
    _currentUser = UserProfile(
      id: id,
      name: name,
      role: role,
      email: email,
    );
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _selectedRole = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  void resetRole() {
    _selectedRole = null;
    notifyListeners();
  }
}
