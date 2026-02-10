import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:piaget/models/user_model.dart';
import 'package:piaget/providers/auth_provider.dart';
import 'package:piaget/utils/responsive.dart';
import 'package:piaget/widgets/animations.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            mobile: _buildMobileLayout(context),
            tablet: _buildTabletLayout(context),
            desktop: _buildDesktopLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            _buildHeader(context),
            const SizedBox(height: 60),
            _buildRoleCards(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildHeader(context),
              const SizedBox(height: 60),
              _buildRoleCards(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.all(32),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: _buildHeader(context),
            ),
            const SizedBox(width: 60),
            Expanded(
              flex: 1,
              child: _buildRoleCards(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return FadeInAnimation(
      duration: const Duration(milliseconds: 800),
      child: Column(
        children: [
          PulseAnimation(
            child: Icon(
              Icons.psychology,
              size: Responsive.isDesktop(context) ? 120 : 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'MindTrack',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 48),
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Identifying Learning Stages with Piaget',
            style: TextStyle(
              fontSize: Responsive.fontSize(context, 16),
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCards(BuildContext context) {
    return Padding(
      padding: Responsive.padding(context),
      child: Column(
        children: [
          Text(
            'Select Your Role',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontSize: Responsive.fontSize(context, 24),
                ),
          ),
          const SizedBox(height: 32),
          SlideInAnimation(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: _RoleCard(
              icon: Icons.admin_panel_settings,
              title: 'Admin',
              description: 'Manage system and users',
              color: Colors.red,
              onTap: () {
                final authProvider = context.read<AuthProvider>();
                authProvider.setUserRole(UserRole.admin);
                Navigator.of(context).pushNamed('/login');
              },
            ),
          ),
          const SizedBox(height: 16),
          SlideInAnimation(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 300),
            child: _RoleCard(
              icon: Icons.school,
              title: 'Teacher',
              description: 'Assess students and track progress',
              color: Colors.orange,
              onTap: () {
                final authProvider = context.read<AuthProvider>();
                authProvider.setUserRole(UserRole.teacher);
                Navigator.of(context).pushNamed('/login');
              },
            ),
          ),
          const SizedBox(height: 16),
          SlideInAnimation(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 400),
            child: _RoleCard(
              icon: Icons.person,
              title: 'Student',
              description: 'Complete learning assessments',
              color: Colors.blue,
              onTap: () {
                final authProvider = context.read<AuthProvider>();
                authProvider.setUserRole(UserRole.student);
                Navigator.of(context).pushNamed('/login');
              },
            ),
          ),
          const SizedBox(height: 16),
          SlideInAnimation(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 500),
            child: _RoleCard(
              icon: Icons.family_restroom,
              title: 'Parent',
              description: 'Monitor your child\'s development',
              color: Colors.green,
              onTap: () {
                final authProvider = context.read<AuthProvider>();
                authProvider.setUserRole(UserRole.parent);
                Navigator.of(context).pushNamed('/login');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Responsive.cardWidth(context),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 20 : 28),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: Responsive.isMobile(context) ? 48 : 56,
                color: color,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 22),
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 14),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
