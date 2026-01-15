import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:piaget/models/user_model.dart';
import 'package:piaget/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:piaget/utils/responsive.dart';
import 'package:piaget/widgets/animations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Hardcoded credentials
  static const String ADMIN_EMAIL = 'admin@gmail.com';
  static const String ADMIN_PASSWORD = 'admin000';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter email and password');
      return;
    }

    // Validate credentials
    if (email != ADMIN_EMAIL || password != ADMIN_PASSWORD) {
      setState(() => _errorMessage = 'Invalid email or password');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final role = authProvider.selectedRole ?? UserRole.student;

      // Extract name from email (admin from admin@gmail.com)
      final nameFromEmail = email.split('@')[0].toUpperCase();

      authProvider.login(
        const Uuid().v4(),
        nameFromEmail,
        role,
        email: email,
      );

      // Navigate to dashboard
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final role = authProvider.selectedRole ?? UserRole.student;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade700,
              Colors.purple.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: ResponsiveLayout(
            mobile: _buildMobileLayout(context, role),
            tablet: _buildTabletLayout(context, role),
            desktop: _buildDesktopLayout(context, role),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, UserRole role) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            _buildHeader(context, role),
            const SizedBox(height: 40),
            _buildLoginForm(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, UserRole role) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              _buildHeader(context, role),
              const SizedBox(height: 48),
              _buildLoginForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, UserRole role) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        padding: const EdgeInsets.all(48),
        child: Row(
          children: [
            Expanded(
              child: _buildHeader(context, role),
            ),
            const SizedBox(width: 80),
            Expanded(
              child: _buildLoginForm(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserRole role) {
    Color roleColor = Colors.purple;
    IconData roleIcon = Icons.person;
    
    switch (role) {
      case UserRole.teacher:
        roleColor = Colors.orange;
        roleIcon = Icons.school;
        break;
      case UserRole.parent:
        roleColor = Colors.green;
        roleIcon = Icons.family_restroom;
        break;
      case UserRole.student:
        roleColor = Colors.purple;
        roleIcon = Icons.person;
        break;
    }

    return FadeInAnimation(
      child: Column(
        children: [
          PulseAnimation(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                roleIcon,
                size: Responsive.isMobile(context) ? 60 : 80,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 40),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in as ${role.name.toUpperCase()}',
            style: TextStyle(
              color: Colors.white70,
              fontSize: Responsive.fontSize(context, 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 300),
      child: Container(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 24 : 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Error message
            if (_errorMessage != null)
              SlideInAnimation(
                begin: const Offset(-1, 0),
                child: Container(
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
                          _errorMessage!,
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
              ),

            // Email field
            Text(
              'Email',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Password field
            Text(
              'Password',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Login button
            AnimatedButton(
              text: _isLoading ? 'Logging in...' : 'Login',
              onPressed: _handleLogin,
              backgroundColor: Colors.blue.shade700,
              icon: Icons.login,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),

            // Demo credentials
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Demo Credentials',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                          fontSize: Responsive.fontSize(context, 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildCredentialRow('Email', ADMIN_EMAIL),
                  const SizedBox(height: 8),
                  _buildCredentialRow('Password', ADMIN_PASSWORD),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Back button
            TextButton.icon(
              onPressed: () {
                context.read<AuthProvider>().resetRole();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Role Selection'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredentialRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
