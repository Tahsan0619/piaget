import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:piaget/models/user_model.dart';
import 'package:piaget/providers/auth_provider.dart';
import 'package:piaget/providers/assessment_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:piaget/utils/responsive.dart';
import 'package:piaget/widgets/animations.dart';
import 'package:piaget/widgets/enhanced_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _classController = TextEditingController();
  int? _selectedAge;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _classController.dispose();
    super.dispose();
  }

  Future<void> _startAssessment() async {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    final role = user?.role;

    final learnerName = role == UserRole.student
        ? (user?.name ?? 'Student')
        : _nameController.text;

    if (learnerName.isEmpty || _selectedAge == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white),
              SizedBox(width: 12),
              Text('Please fill in all required fields'),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final assessmentProvider = context.read<AssessmentProvider>();
    assessmentProvider.initializeLearner(
      const Uuid().v4(),
      learnerName,
      _selectedAge!,
      className: _classController.text.isEmpty ? null : _classController.text,
    );

    await assessmentProvider.startAssessment();

    if (assessmentProvider.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(assessmentProvider.error!),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Show success message if questions were generated
    if (mounted && assessmentProvider.currentSession != null) {
      final questionCount = assessmentProvider.currentSession!.questions.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Generated $questionCount questions'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    if (mounted) {
      Navigator.of(context).pushNamed('/assessment');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    final role = user?.role;

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
          child: Column(
            children: [
              _buildAppBar(context, user, authProvider),
              Expanded(
                child: ResponsiveLayout(
                  mobile: _buildMobileLayout(context, role),
                  tablet: _buildTabletLayout(context, role),
                  desktop: _buildDesktopLayout(context, role),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, UserProfile? user, AuthProvider authProvider) {
    return FadeInAnimation(
      duration: const Duration(milliseconds: 600),
      child: Padding(
        padding: Responsive.padding(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${user?.name ?? "User"}',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 28),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.fontSize(context, 12),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
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
                        onPressed: () {
                          Navigator.pop(context);
                          authProvider.logout();
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
              child: PulseAnimation(
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
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, UserRole? role) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildQuickStats(context, role),
              const SizedBox(height: 32),
              _buildAssessmentForm(context, role),
              const SizedBox(height: 32),
              _buildHelpSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, UserRole? role) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                _buildQuickStats(context, role),
                const SizedBox(height: 40),
                _buildAssessmentForm(context, role),
                const SizedBox(height: 40),
                _buildHelpSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, UserRole? role) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            padding: const EdgeInsets.all(48.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildAssessmentForm(context, role),
                      const SizedBox(height: 40),
                      _buildHelpSection(context),
                    ],
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  flex: 1,
                  child: _buildQuickStats(context, role),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, UserRole? role) {
    return Column(
      children: [
        SlideInAnimation(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 200),
          child: InfoCard(
            icon: Icons.rocket_launch,
            title: 'Quick Start',
            description: 'Begin a new cognitive assessment',
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 16),
        SlideInAnimation(
          duration: const Duration(milliseconds: 600),
          delay: const Duration(milliseconds: 400),
          child: InfoCard(
            icon: Icons.psychology,
            title: 'Piaget Stages',
            description: 'Assess 4 cognitive development stages',
            color: Colors.purple.shade600,
          ),
        ),
        if (role != UserRole.student) ...[
          const SizedBox(height: 16),
          SlideInAnimation(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 600),
            child: InfoCard(
              icon: Icons.analytics,
              title: 'Track Progress',
              description: 'Monitor learner development over time',
              color: Colors.orange.shade600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAssessmentForm(BuildContext context, UserRole? role) {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 400),
      child: Container(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 24 : 32),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment,
                  color: Colors.blue.shade700,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  role == UserRole.student ? 'Start Assessment' : 'New Assessment',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 24),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Name field
            if (role != UserRole.student) ...[
              Text(
                'Learner Name *',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter learner name',
                  prefixIcon: const Icon(Icons.person_outline),
                  filled: true,
                  fillColor: Colors.white,
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
              const SizedBox(height: 24),
            ],

            // Age selector
            Text(
              'Age *',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(16, (index) {
                final age = index + 1; // Ages 1-16
                final isSelected = _selectedAge == age;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAge = age),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade700 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.blue.shade700.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      '$age',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.fontSize(context, 16),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Class field (optional)
            if (role != UserRole.student) ...[
              Text(
                'Class/Grade (Optional)',
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 14),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _classController,
                decoration: InputDecoration(
                  hintText: 'e.g., Grade 4, Class 5A',
                  prefixIcon: const Icon(Icons.class_outlined),
                  filled: true,
                  fillColor: Colors.white,
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
            ] else
              const SizedBox(height: 8),

            // Start button
            Consumer<AssessmentProvider>(
              builder: (context, assessmentProvider, _) {
                final isLoading = assessmentProvider.isLoading;
                return SizedBox(
                  width: double.infinity,
                  child: AnimatedButton(
                    text: isLoading ? 'Preparing questions...' : 'Start Assessment',
                    onPressed: isLoading ? null : _startAssessment,
                    backgroundColor: Colors.blue.shade700,
                    icon: isLoading ? Icons.hourglass_top : Icons.play_arrow,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade100, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purple.shade200, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, color: Colors.purple.shade700, size: 28),
                const SizedBox(width: 12),
                Text(
                  'How it works',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildHelpStep(1, 'Fill in learner details', Icons.edit),
            const SizedBox(height: 12),
            _buildHelpStep(2, 'Answer cognitive assessment questions', Icons.quiz),
            const SizedBox(height: 12),
            _buildHelpStep(3, 'Receive detailed developmental insights', Icons.insights),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpStep(int number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.purple.shade700,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            children: [
              Icon(icon, color: Colors.purple.shade600, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 14),
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
