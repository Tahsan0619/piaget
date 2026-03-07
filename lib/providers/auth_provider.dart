import 'package:flutter/material.dart';
import 'package:piaget/models/user_model.dart';
import 'package:piaget/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = SupabaseService();
  
  UserProfile? _currentUser;
  UserRole? _selectedRole;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _dashboardStats;

  UserProfile? get currentUser => _currentUser;
  UserRole? get selectedRole => _selectedRole;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get dashboardStats => _dashboardStats;

  // Check if user is Student
  bool get isStudent => _currentUser?.role == UserRole.student;
  
  // Check if user is Teacher
  bool get isTeacher => _currentUser?.role == UserRole.teacher;
  
  // Check if user is Admin
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  void setUserRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    debugPrint('📧 AuthProvider.signIn - Starting authentication');
    debugPrint('📧 Email: $email');

    try {
      debugPrint('📧 Calling Supabase signIn...');
      final response = await _supabase.signIn(
        email: email,
        password: password,
      );

      debugPrint('📧 Supabase response received');
      debugPrint('📧 User ID: ${response.user?.id}');
      debugPrint('📧 User email: ${response.user?.email}');

      if (response.user == null) {
        _error = 'Invalid credentials';
        _isLoading = false;
        notifyListeners();
        debugPrint('❌ Login failed: No user in response');
        return false;
      }

      debugPrint('📧 Fetching user profile...');
      // Get user profile
      final profile = await _supabase.getUserProfile(response.user!.id);
      
      debugPrint('📧 Profile fetched: ${profile != null}');
      if (profile != null) {
        debugPrint('📧 Profile role: ${profile.role}');
        debugPrint('📧 Profile active: ${profile.isActive}');
        debugPrint('📧 Profile name: ${profile.name}');
      }
      
      if (profile == null) {
        _error = 'User profile not found';
        _isLoading = false;
        notifyListeners();
        debugPrint('❌ Login failed: Profile not found in database');
        return false;
      }

      // Check if user is active
      if (!profile.isActive) {
        _error = 'Your account has been deactivated. Please contact support.';
        await _supabase.signOut();
        _isLoading = false;
        notifyListeners();
        debugPrint('❌ Login failed: Account deactivated');
        return false;
      }

      _currentUser = profile;
      _isAuthenticated = true;
      _selectedRole = profile.role;

      debugPrint('✅ Login successful!');
      debugPrint('✅ User: ${profile.name}');
      debugPrint('✅ Role: ${profile.role}');

      // Update last login
      await _supabase.updateLastLogin(profile.id);

      // Log activity
      await _supabase.logActivity(
        userId: profile.id,
        action: 'user_login',
        details: {'timestamp': DateTime.now().toIso8601String()},
      );

      // Load dashboard stats
      await _loadDashboardStats();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Login exception: $e');
      debugPrint('❌ Exception type: ${e.runtimeType}');
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign up new user
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    Map<String, dynamic>? additionalData,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase.signUp(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
        additionalData: additionalData,
      );

      if (response.user == null) {
        _error = 'Sign up failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Auto-login after signup
      final profile = await _supabase.getUserProfile(response.user!.id);
      
      if (profile != null) {
        _currentUser = profile;
        _isAuthenticated = true;
        _selectedRole = profile.role;

        // Log activity
        await _supabase.logActivity(
          userId: profile.id,
          action: 'user_signup',
          details: {
            'timestamp': DateTime.now().toIso8601String(),
            'role': role.name,
          },
        );

        // Create welcome notification
        await _supabase.createNotification(
          userId: profile.id,
          title: 'Welcome to MindTrack!',
          message: 'Your account has been successfully created. Start your cognitive assessment journey today!',
          type: 'success',
        );

        // Load dashboard stats
        await _loadDashboardStats();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Legacy login method (for backward compatibility)
  void login(String id, String name, UserRole role, {String? email}) {
    _currentUser = UserProfile(
      id: id,
      name: name,
      role: role,
      email: email,
    );
    _isAuthenticated = true;
    _selectedRole = role;
    notifyListeners();
  }

  // Sign out
  Future<void> logout() async {
    if (_currentUser != null) {
      try {
        // Log activity
        await _supabase.logActivity(
          userId: _currentUser!.id,
          action: 'user_logout',
          details: {'timestamp': DateTime.now().toIso8601String()},
        );
      } catch (e) {
        // Ignore errors during logout
        debugPrint('Error logging logout activity: $e');
      }
    }

    try {
      await _supabase.signOut();
    } catch (e) {
      debugPrint('Error signing out from Supabase: $e');
    }

    _currentUser = null;
    _selectedRole = null;
    _isAuthenticated = false;
    _dashboardStats = null;
    notifyListeners();
  }

  void resetRole() {
    _selectedRole = null;
    notifyListeners();
  }

  // Load user profile
  Future<void> loadUserProfile() async {
    final user = _supabase.getCurrentUser();
    if (user == null) {
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
      return;
    }

    try {
      final profile = await _supabase.getUserProfile(user.id);
      if (profile != null) {
        _currentUser = profile;
        _isAuthenticated = true;
        _selectedRole = profile.role;
        await _loadDashboardStats();
      } else {
        _isAuthenticated = false;
        _currentUser = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _supabase.updateUserProfile(_currentUser!.id, updates);
      
      // Reload profile
      await loadUserProfile();

      // Log activity
      await _supabase.logActivity(
        userId: _currentUser!.id,
        action: 'profile_updated',
        details: {'fields': updates.keys.toList()},
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load dashboard statistics based on role
  Future<void> _loadDashboardStats() async {
    if (_currentUser == null) return;

    try {
      switch (_currentUser!.role) {
        case UserRole.admin:
          _dashboardStats = await _supabase.getAdminDashboardStats();
          break;
        case UserRole.teacher:
          _dashboardStats = await _supabase.getTeacherDashboardStats(_currentUser!.id);
          break;
        case UserRole.student:
          _dashboardStats = await _supabase.getStudentDashboardStats(_currentUser!.id);
          break;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading dashboard stats: $e');
      _dashboardStats = {};
    }
  }

  // Refresh dashboard stats
  Future<void> refreshDashboardStats() async {
    await _loadDashboardStats();
  }

  // Initialize auth state
  Future<void> initializeAuth() async {
    final user = _supabase.getCurrentUser();
    if (user != null) {
      await loadUserProfile();
    }
  }

  // Parse error messages
  String _parseError(dynamic error) {
    debugPrint('🔧 Parsing error: ${error.runtimeType}');
    
    if (error is AuthException) {
      debugPrint('🔧 AuthException - Status: ${error.statusCode}, Message: ${error.message}');
      switch (error.statusCode) {
        case '400':
          return 'Invalid email or password';
        case '422':
          return 'Email already registered';
        case '429':
          return 'Too many attempts. Please try again later';
        default:
          return error.message;
      }
    } else if (error is PostgrestException) {
      debugPrint('🔧 PostgrestException - Code: ${error.code}, Message: ${error.message}');
      return 'Database error: ${error.message}';
    } else {
      debugPrint('🔧 Unknown error: $error');
      return error.toString();
    }
  }
}
