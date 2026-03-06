import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:piaget/providers/assessment_provider.dart';
import 'package:piaget/models/assessment_model.dart';
import 'package:piaget/models/user_model.dart';
import 'package:piaget/utils/responsive.dart';
import 'package:piaget/widgets/animations.dart';
import 'package:piaget/widgets/enhanced_widgets.dart';
import 'package:piaget/services/pdf_service.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, assessmentProvider, _) {
        final AssessmentResult? result = assessmentProvider.lastResult;
        final LearnerProfile? learner = assessmentProvider.currentLearner;

        if (result == null || learner == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 24),
                  const Text(
                    'No assessment results found',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/dashboard'),
                    icon: const Icon(Icons.dashboard),
                    label: const Text('Go to Dashboard'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

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
                mobile: _buildMobileLayout(context, result, learner),
                tablet: _buildTabletLayout(context, result, learner),
                desktop: _buildDesktopLayout(context, result, learner),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context, AssessmentResult result, LearnerProfile learner) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(context, learner),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildScoreCard(context, result),
                const SizedBox(height: 24),
                _buildCognitiveStageCard(context, result),
                const SizedBox(height: 24),
                _buildAchievements(context, result),
                const SizedBox(height: 24),
                _buildCriteriaResults(context, result),
                const SizedBox(height: 24),
                _buildRecommendations(context, result),
                const SizedBox(height: 24),
                _buildActionButtons(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context, AssessmentResult result, LearnerProfile learner) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              _buildHeader(context, learner),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildScoreCard(context, result)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildCognitiveStageCard(context, result)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildAchievements(context, result),
                    const SizedBox(height: 32),
                    _buildCriteriaResults(context, result),
                    const SizedBox(height: 32),
                    _buildRecommendations(context, result),
                    const SizedBox(height: 32),
                    _buildActionButtons(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, AssessmentResult result, LearnerProfile learner) {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              _buildHeader(context, learner),
              const SizedBox(height: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildScoreCard(context, result)),
                            const SizedBox(width: 24),
                            Expanded(child: _buildCognitiveStageCard(context, result)),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildCriteriaResults(context, result),
                        const SizedBox(height: 32),
                        _buildRecommendations(context, result),
                        const SizedBox(height: 32),
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 1,
                    child: _buildAchievements(context, result),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LearnerProfile learner) {
    return FadeInAnimation(
      child: Padding(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 24 : 32),
        child: Column(
          children: [
            PulseAnimation(
              child: Icon(
                Icons.celebration,
                size: Responsive.isMobile(context) ? 80 : 100,
                color: Colors.amber.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Assessment Complete!',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 32),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Great work, ${learner.name}!',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 18),
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, AssessmentResult result) {
    final scoreColor = result.overallScore >= 80
        ? Colors.green
        : result.overallScore >= 60
            ? Colors.orange
            : Colors.red;

    return SlideInAnimation(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 28 : 36),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scoreColor.shade400, scoreColor.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: scoreColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'Overall Score',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 16),
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${result.overallScore.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 52),
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getScoreLabel(result.overallScore),
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getScoreLabel(double score) {
    if (score >= 90) return 'Excellent! 🌟';
    if (score >= 80) return 'Very Good! 👏';
    if (score >= 70) return 'Good! 👍';
    if (score >= 60) return 'Fair 📈';
    return 'Keep Learning! 💪';
  }

  Widget _buildCognitiveStageCard(BuildContext context, AssessmentResult result) {
    final stageColors = {
      'Concrete Operational (7-11 years)': Colors.orange,
      'Formal Operational (11+ years)': Colors.green,
    };

    final stageColor = stageColors[result.assessmentStage] ?? Colors.blue;

    return SlideInAnimation(
      delay: const Duration(milliseconds: 400),
      child: Container(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 28 : 36),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [stageColor.shade400, stageColor.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: stageColor.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.psychology,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'Cognitive Stage',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 16),
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              result.assessmentStage,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaResults(BuildContext context, AssessmentResult result) {
    final criteria = result.criteriaResults;

    return SlideInAnimation(
      delay: const Duration(milliseconds: 600),
      child: Container(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 24 : 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist, color: Colors.blue.shade700, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Criteria Results',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 22),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...criteria.map((c) {
              Color badgeColor;
              IconData badgeIcon;
              switch (c.status) {
                case CriterionStatus.achieved:
                  badgeColor = Colors.green;
                  badgeIcon = Icons.check_circle;
                  break;
                case CriterionStatus.developing:
                  badgeColor = Colors.orange;
                  badgeIcon = Icons.insights;
                  break;
                case CriterionStatus.notYetAchieved:
                  badgeColor = Colors.red;
                  badgeIcon = Icons.hourglass_bottom;
                  break;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(badgeIcon, color: badgeColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.criterionName,
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c.feedback,
                            style: TextStyle(
                              fontSize: Responsive.fontSize(context, 13),
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${c.score.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                        fontSize: Responsive.fontSize(context, 14),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements(BuildContext context, AssessmentResult result) {
    final achievements = [
      {
        'title': 'Completed',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'unlocked': true,
      },
      {
        'title': 'Fast Learner',
        'icon': Icons.flash_on,
        'color': Colors.amber,
        'unlocked': result.overallScore >= 70,
      },
      {
        'title': 'Top Performer',
        'icon': Icons.star,
        'color': Colors.purple,
        'unlocked': result.overallScore >= 85,
      },
      {
        'title': 'Perfect Score',
        'icon': Icons.emoji_events,
        'color': Colors.orange,
        'unlocked': result.overallScore >= 95,
      },
    ];

    return SlideInAnimation(
      delay: const Duration(milliseconds: 800),
      child: Container(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 24 : 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.military_tech, color: Colors.amber.shade700, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 22),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Responsive.isMobile(context)
                ? Column(
                    children: achievements
                        .map((achievement) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AchievementBadge(
                                title: achievement['title'] as String,
                                icon: achievement['icon'] as IconData,
                                color: achievement['color'] as Color,
                                isUnlocked: achievement['unlocked'] as bool,
                              ),
                            ))
                        .toList(),
                  )
                : Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: achievements
                        .map((achievement) => SizedBox(
                              width: (Responsive.width(context) - 200) / 4,
                              child: AchievementBadge(
                                title: achievement['title'] as String,
                                icon: achievement['icon'] as IconData,
                                color: achievement['color'] as Color,
                                isUnlocked: achievement['unlocked'] as bool,
                              ),
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context, AssessmentResult result) {
    return SlideInAnimation(
      delay: const Duration(milliseconds: 1000),
      child: Container(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 24 : 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Personalized Development Plan',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 22),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Research-based activities tailored to ${result.assessmentStage} stage',
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ...result.suggestedActivities.asMap().entries.map((entry) {
              final index = entry.key;
              final activity = entry.value;
              
              // Parse activity type from emoji
              Color activityColor = Colors.blue;
              IconData activityIcon = Icons.school;
              String activityType = 'Activity';
              
              if (activity.startsWith('🎯')) {
                activityColor = Colors.red;
                activityIcon = Icons.priority_high;
                activityType = 'Priority Focus';
              } else if (activity.startsWith('📈')) {
                activityColor = Colors.orange;
                activityIcon = Icons.trending_up;
                activityType = 'Reinforce';
              } else if (activity.startsWith('💡')) {
                activityColor = Colors.purple;
                activityIcon = Icons.auto_awesome;
                activityType = 'Enrichment';
              } else if (activity.startsWith('🌟')) {
                activityColor = Colors.green;
                activityIcon = Icons.celebration;
                activityType = 'Continue';
              }
              
              // Remove emoji from text
              final cleanText = activity.replaceFirst(RegExp(r'^[🎯📈💡🌟]\s*'), '');
              
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: activityColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: activityColor.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: activityColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(activityIcon, color: activityColor, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                activityType,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: activityColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      cleanText,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 15),
                        color: Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These activities are based on Piaget\'s research and are designed to support cognitive development at the ${result.assessmentStage} stage.',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 13),
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, assessmentProvider, _) {
        final result = assessmentProvider.lastResult;
        final learner = assessmentProvider.currentLearner;

        return FadeInAnimation(
          delay: const Duration(milliseconds: 1200),
          child: Column(
            children: [
              // PDF Buttons Row
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: result != null && learner != null
                          ? () async {
                              try {
                                await PdfService.generateAndShareReport(result, learner);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to generate PDF: $e'),
                                      backgroundColor: Colors.red.shade700,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                }
                              }
                            }
                          : null,
                      icon: const Icon(Icons.picture_as_pdf, size: 22),
                      label: const Text('Download PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: result != null && learner != null
                          ? () async {
                              try {
                                await PdfService.printReport(result, learner);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to print: $e'),
                                      backgroundColor: Colors.red.shade700,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                }
                              }
                            }
                          : null,
                      icon: const Icon(Icons.print, size: 22),
                      label: const Text('Print Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/dashboard');
                  },
                  icon: const Icon(Icons.home, size: 24),
                  label: const Text('Back to Dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Results shared successfully!'),
                        backgroundColor: Colors.green.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.share, size: 24),
                  label: const Text('Share Results'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue.shade700,
                    side: BorderSide(color: Colors.blue.shade700, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
