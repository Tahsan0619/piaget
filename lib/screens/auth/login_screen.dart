import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:piaget/models/user_model.dart';
import 'package:piaget/providers/auth_provider.dart';
import 'package:piaget/utils/responsive.dart';
import 'package:piaget/widgets/animations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Additional fields for signup
  UserRole _selectedSignupRole = UserRole.student;
  final _studentIdController = TextEditingController();
  final _teacherIdController = TextEditingController();
  final _adminIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _ageController = TextEditingController();
  final _gradeLevelController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _errorMessage = null;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _confirmPasswordController.dispose();
    _studentIdController.dispose();
    _teacherIdController.dispose();
    _adminIdController.dispose();
    _departmentController.dispose();
    _ageController.dispose();
    _gradeLevelController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = null);

    debugPrint('=== LOGIN ATTEMPT ===');
    debugPrint('Email: ${_emailController.text.trim()}');
    debugPrint('Password length: ${_passwordController.text.length}');
    debugPrint('====================');

    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );

    debugPrint('=== LOGIN RESULT ===');
    debugPrint('Success: $success');
    debugPrint('Error: ${authProvider.error}');
    debugPrint('User: ${authProvider.currentUser?.email}');
    debugPrint('Role: ${authProvider.currentUser?.role}');
    debugPrint('====================');

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else if (mounted) {
      setState(() => _errorMessage = authProvider.error);
    }
  }

  Future<void> _handleSignUp(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() => _errorMessage = null);

    final role = _selectedSignupRole;
    
    // Prepare additional data based on role
    Map<String, dynamic> additionalData = {};
    
    switch (role) {
      case UserRole.student:
        additionalData = {
          'student_id': _studentIdController.text.isNotEmpty 
              ? _studentIdController.text 
              : 'STD${DateTime.now().millisecondsSinceEpoch}',
          'age': int.tryParse(_ageController.text) ?? 10,
          'grade_level': _gradeLevelController.text.isNotEmpty 
              ? _gradeLevelController.text 
              : null,
        };
        break;
      case UserRole.teacher:
        additionalData = {
          'teacher_id': _teacherIdController.text.isNotEmpty 
              ? _teacherIdController.text 
              : 'TCH${DateTime.now().millisecondsSinceEpoch}',
          'department': _departmentController.text.isNotEmpty 
              ? _departmentController.text 
              : null,
        };
        break;
      case UserRole.admin:
        additionalData = {
          'admin_id': _adminIdController.text.isNotEmpty 
              ? _adminIdController.text 
              : 'ADM${DateTime.now().millisecondsSinceEpoch}',
          'department': _departmentController.text.isNotEmpty 
              ? _departmentController.text 
              : null,
        };
        break;
      default:
        break;
    }

    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      role: role,
      additionalData: additionalData,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else if (mounted) {
      setState(() => _errorMessage = authProvider.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.deepPurple.shade700,
              Colors.indigo.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: ResponsiveLayout(
            mobile: _buildMobileLayout(context, authProvider),
            tablet: _buildTabletLayout(context, authProvider),
            desktop: _buildDesktopLayout(context, authProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: MediaQuery.of(context).padding.top + 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeader(context),
          const SizedBox(height: 32),
          _buildAuthForm(context, authProvider),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, AuthProvider authProvider) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 48),
              _buildAuthForm(context, authProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AuthProvider authProvider) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        padding: const EdgeInsets.all(48),
        child: Row(
          children: [
            Expanded(
              child: _buildHeader(context),
            ),
            const SizedBox(width: 80),
            Expanded(
              child: _buildAuthForm(context, authProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    
    return FadeInAnimation(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PulseAnimation(
            child: Container(
              padding: EdgeInsets.all(isMobile ? 20 : 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology_outlined,
                size: isMobile ? 50 : 80,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          Text(
            'MindTrack',
            style: TextStyle(
              fontSize: isMobile ? 32 : 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            'Piaget Assessment System',
            style: TextStyle(
              color: Colors.white70,
              fontSize: isMobile ? 14 : 18,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthForm(BuildContext context, AuthProvider authProvider) {
    final isMobile = Responsive.isMobile(context);
    
    return FadeInAnimation(
      delay: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 20 : 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tabs for Login/Sign Up
              Container(
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade700.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade700,
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Login'),
                    Tab(text: 'Sign Up'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Error message
              if (_errorMessage != null || authProvider.error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage ?? authProvider.error ?? '',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Tab views
              SizedBox(
                height: _tabController.index == 0 ? 250 : 520,
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildLoginTab(authProvider),
                    _buildSignUpTab(authProvider),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab(AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            decoration: _inputDecoration('Email', Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: _inputDecoration('Password', Icons.lock_outlined).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Login button
          AnimatedButton(
            text: authProvider.isLoading ? 'Logging in...' : 'Login',
            onPressed: () => _handleLogin(authProvider),
            backgroundColor: Colors.blue.shade700,
            icon: Icons.login,
            isLoading: authProvider.isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpTab(AuthProvider authProvider) {
    final role = _selectedSignupRole;
    
    return ClipRect(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Full Name
            TextFormField(
              controller: _fullNameController,
              decoration: _inputDecoration('Full Name', Icons.person_outlined),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Role Selector
            DropdownButtonFormField<UserRole>(
              value: _selectedSignupRole,
              decoration: _inputDecoration('Select Role', Icons.work_outline),
              items: const [
                DropdownMenuItem(
                  value: UserRole.student,
                  child: Text('Student'),
                ),
                DropdownMenuItem(
                  value: UserRole.teacher,
                  child: Text('Teacher'),
                ),
                DropdownMenuItem(
                  value: UserRole.admin,
                  child: Text('Admin'),
                ),
              ],
              onChanged: (UserRole? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedSignupRole = newValue;
                    // Clear role-specific fields when role changes
                    _studentIdController.clear();
                    _teacherIdController.clear();
                    _adminIdController.clear();
                    _departmentController.clear();
                    _ageController.clear();
                    _gradeLevelController.clear();
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: _inputDecoration('Email', Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: _inputDecoration('Password', Icons.lock_outlined).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Confirm Password
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: _inputDecoration('Confirm Password', Icons.lock_outlined).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Role-specific fields
            ..._buildRoleSpecificFields(role),

            const SizedBox(height: 24),

            // Sign Up button
            AnimatedButton(
              text: authProvider.isLoading ? 'Creating Account...' : 'Sign Up',
              onPressed: () => _handleSignUp(authProvider),
              backgroundColor: Colors.green.shade700,
              icon: Icons.person_add,
              isLoading: authProvider.isLoading,
            ),
          ],
        ),
      ),
    ),
  );
  }

  List<Widget> _buildRoleSpecificFields(UserRole role) {
    switch (role) {
      case UserRole.student:
        return [
          TextFormField(
            controller: _ageController,
            decoration: _inputDecoration('Age', Icons.cake_outlined),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your age';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _gradeLevelController,
            decoration: _inputDecoration('Grade Level (Optional)', Icons.school_outlined),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _studentIdController,
            decoration: _inputDecoration('Student ID (Optional)', Icons.badge_outlined),
          ),
        ];
      case UserRole.teacher:
        return [
          TextFormField(
            controller: _departmentController,
            decoration: _inputDecoration('Department (Optional)', Icons.business_outlined),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _teacherIdController,
            decoration: _inputDecoration('Teacher ID (Optional)', Icons.badge_outlined),
          ),
        ];
      case UserRole.admin:
        return [
          TextFormField(
            controller: _departmentController,
            decoration: _inputDecoration('Department (Optional)', Icons.business_outlined),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _adminIdController,
            decoration: _inputDecoration('Admin ID (Optional)', Icons.admin_panel_settings_outlined),
          ),
        ];
      default:
        return [];
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.grey.shade700,
        fontSize: 15,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Icon(icon, color: Colors.grey.shade600, size: 22),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.red.shade700, width: 2),
      ),
    );
  }

  MaterialColor _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return Colors.orange;
      case UserRole.admin:
        return Colors.red;
      case UserRole.student:
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return Icons.school;
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.student:
        return Icons.person;
      default:
        return Icons.family_restroom;
    }
  }
}
