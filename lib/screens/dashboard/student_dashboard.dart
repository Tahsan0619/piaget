import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:piaget/providers/auth_provider.dart';
import 'package:piaget/providers/assessment_provider.dart';
import 'package:piaget/services/supabase_service.dart';
import 'package:piaget/widgets/animations.dart';
import 'package:uuid/uuid.dart';
import 'package:piaget/utils/responsive.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final _supabase = SupabaseService();
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _recentAssessments = [];
  Map<String, dynamic>? _progress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.id;

      if (userId != null) {
        final stats = await _supabase.getStudentDashboardStats(userId);
        final assessments = await _supabase.getStudentAssessments(userId, limit: 5);
        final progress = await _supabase.getStudentProgress(userId);

        setState(() {
          _stats = stats;
          _recentAssessments = assessments;
          _progress = progress;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startNewAssessment() async {
    debugPrint('\n🎯 ========== START NEW ASSESSMENT ==========');
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;
    debugPrint('📝 User ID: $userId');
    debugPrint('📝 User Name: ${authProvider.currentUser?.name}');

    if (userId == null) {
      debugPrint('❌ Cannot start assessment: userId is null');
      return;
    }

    // Show age selection dialog
    debugPrint('🎂 Showing age selection dialog...');
    final age = await showDialog<int>(
      context: context,
      builder: (context) => _buildAgeSelectionDialog(),
    );

    if (age == null) {
      debugPrint('⚠️ Age selection cancelled by user');
      return;
    }
    debugPrint('✅ Age selected: $age years');

    try {
      debugPrint('🔧 Initializing assessment provider...');
      final assessmentProvider = context.read<AssessmentProvider>();
      final learnerId = const Uuid().v4();
      debugPrint('👤 Generated Learner ID: $learnerId');
      
      assessmentProvider.initializeLearner(
        learnerId,
        authProvider.currentUser?.name ?? 'Student',
        age,
        realStudentId: userId, // Pass the real user ID for database saves
      );
      debugPrint('✅ Learner initialized successfully');

      debugPrint('🚀 Calling startAssessment()...');
      await assessmentProvider.startAssessment();
      debugPrint('✅ startAssessment() completed');

      if (assessmentProvider.error != null && mounted) {
        debugPrint('❌ Assessment provider returned error: ${assessmentProvider.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(assessmentProvider.error!),
            backgroundColor: Colors.red.shade700,
          ),
        );
        debugPrint('🎯 ========== ASSESSMENT FAILED ==========\n');
        return;
      }

      if (mounted) {
        debugPrint('🎯 Navigating to assessment screen...');
        await Navigator.of(context).pushNamed('/assessment');
        // Reload dashboard data after returning from assessment
        debugPrint('🔄 Reloading dashboard after assessment...');
        await _loadDashboardData();
        debugPrint('🎯 ========== ASSESSMENT STARTED SUCCESSFULLY ==========\n');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ CRITICAL ERROR in _startNewAssessment: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start assessment: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      debugPrint('🎯 ========== ASSESSMENT FAILED ==========\n');
    }
  }

  Widget _buildAgeSelectionDialog() {
    int selectedAge = 10;
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Select Your Age'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please confirm your age to get appropriate assessment:'),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: selectedAge,
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: List.generate(18, (index) => index + 3)
                    .map((age) => DropdownMenuItem(
                          value: age,
                          child: Text('$age years old'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedAge = value);
                  }
                },
              ),
            ],
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, selectedAge),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Message
            FadeInAnimation(
              child: Text(
                'My Learning Journey',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 20),

            // Stats Cards
            _buildStatsCards(),
            const SizedBox(height: 24),

            // Progress Card
            if (_progress != null) _buildProgressCard(),
            const SizedBox(height: 24),

            // Start New Assessment Button
            _buildStartAssessmentButton(),
            const SizedBox(height: 24),

            // Recent Assessments
            _buildRecentAssessments(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 44) / 2; // 2 cards with padding
    
    return Row(
      children: [
        SizedBox(
          width: cardWidth,
          child: _buildStatCard(
            'Total',
            '${_stats?['total_assessments'] ?? 0}',
            Icons.assignment,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: cardWidth,
          child: _buildStatCard(
            'Completed',
            '${_stats?['completed_assessments'] ?? 0}',
            Icons.check_circle,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return FadeInAnimation(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                height: 1.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final currentStage = _progress?['current_stage'] ?? 'Not assessed';
    final averageScore = _progress?['average_score']?.toDouble() ?? 0.0;

    return FadeInAnimation(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.purple.shade600],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Icon(Icons.trending_up, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'My Progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Current Stage',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentStage.toString().replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Average Score',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${averageScore.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartAssessmentButton() {
    return FadeInAnimation(
      delay: const Duration(milliseconds: 300),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: _startNewAssessment,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
          ),
          icon: const Icon(Icons.add_circle_outline, size: 24),
          label: const Text(
            'Start New Assessment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAssessments() {
    if (_recentAssessments.isEmpty) {
      return FadeInAnimation(
        delay: const Duration(milliseconds: 400),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.assignment_outlined, size: 56, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'No assessments yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Start your first assessment to track your progress!',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FadeInAnimation(
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Recent Assessments',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          ...List.generate(
            _recentAssessments.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildAssessmentCard(_recentAssessments[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(Map<String, dynamic> assessment) {
    final status = assessment['status'] ?? 'unknown';
    final stage = assessment['stage'] ?? 'N/A';
    final score = assessment['overall_score']?.toDouble();
    final startedAt = assessment['started_at'] != null
        ? DateTime.parse(assessment['started_at'] as String)
        : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: status == 'completed' ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              status == 'completed' ? Icons.check_circle : Icons.hourglass_empty,
              color: status == 'completed' ? Colors.green.shade700 : Colors.orange.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  stage.toString().replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  startedAt != null
                      ? '${startedAt.day}/${startedAt.month}/${startedAt.year}'
                      : 'Date N/A',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (score != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${score.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
