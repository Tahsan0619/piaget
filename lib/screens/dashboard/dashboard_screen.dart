import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:piaget/models/user_model.dart';
import 'package:piaget/providers/auth_provider.dart';
import 'package:piaget/screens/dashboard/student_dashboard.dart';
import 'package:piaget/screens/dashboard/teacher_dashboard.dart';
import 'package:piaget/screens/dashboard/admin_dashboard.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final role = user?.role;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getGradientColors(role),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, user, authProvider),
              Expanded(
                child: _buildRoleBasedDashboard(role),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, UserProfile? user, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${user?.name ?? "User"}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user?.role?.name.toUpperCase() ?? 'USER',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await authProvider.logout();
                        
                        // Navigate to login screen and clear navigation stack
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login',
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.logout,
                color: _getPrimaryColor(user?.role),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBasedDashboard(UserRole? role) {
    switch (role) {
      case UserRole.student:
        return const StudentDashboard();
      case UserRole.teacher:
        return const TeacherDashboard();
      case UserRole.admin:
        return const AdminDashboard();
      default:
        return _buildDefaultDashboard();
    }
  }

  Widget _buildDefaultDashboard() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.dashboard, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            const Text(
              'Welcome to MindTrack',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please log in to access your dashboard',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors(UserRole? role) {
    switch (role) {
      case UserRole.student:
        return [Colors.blue.shade700, Colors.blue.shade900];
      case UserRole.teacher:
        return [Colors.orange.shade700, Colors.orange.shade900];
      case UserRole.admin:
        return [Colors.red.shade700, Colors.red.shade900];
      default:
        return [Colors.blue.shade700, Colors.purple.shade600];
    }
  }

  Color _getPrimaryColor(UserRole? role) {
    switch (role) {
      case UserRole.student:
        return Colors.blue.shade700;
      case UserRole.teacher:
        return Colors.orange.shade700;
      case UserRole.admin:
        return Colors.red.shade700;
      default:
        return Colors.blue.shade700;
    }
  }
}
