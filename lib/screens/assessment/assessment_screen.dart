import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:piaget/providers/assessment_provider.dart';
import 'package:piaget/models/assessment_model.dart';
import 'package:piaget/utils/responsive.dart';
import 'package:piaget/widgets/animations.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  final Map<String, TextEditingController> _shortAnswerControllers = {};
  String? _selectedAnswer;
  late AnimationController _progressController;
  int _score = 0;
  // Matching question state
  final Map<String, Map<String, String?>> _matchingSelections = {}; // questionId -> {leftItem: selectedRight}
  String? _dragSource;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    for (var controller in _shortAnswerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submitAnswer(String answer, int timeSpent) async {
    final assessmentProvider = context.read<AssessmentProvider>();
    final session = assessmentProvider.currentSession;

    if (session != null && _currentIndex < session.questions.length) {
      final question = session.questions[_currentIndex];
      assessmentProvider.recordResponse(question.id, answer, timeSpent);

      // Increment score for gamification
      setState(() => _score++);

      if (_currentIndex < session.questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _progressController.forward(from: 0);
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      } else {
        // Last question answered - save to database
        debugPrint('📝 Last question answered, completing assessment...');
        await assessmentProvider.completeAssessment();
        debugPrint('✅ Assessment completion process finished');
        
        // Check if widget is still mounted before showing dialog
        if (mounted) {
          _showCompletionDialog();
        }
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.orange.shade700, size: 28),
            const SizedBox(width: 12),
            const Text('Great Job!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 80),
            const SizedBox(height: 16),
            const Text(
              'You completed the assessment!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Let\'s see your results',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacementNamed('/results');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('View Results', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AssessmentProvider>(
      builder: (context, assessmentProvider, _) {
        final session = assessmentProvider.currentSession;

        if (session == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  const Text(
                    'Loading assessment...',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
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
          backgroundColor: Colors.grey.shade50,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(session),
                Expanded(
                  child: ResponsiveLayout(
                    mobile: _buildQuestionView(session),
                    tablet: _buildQuestionView(session, isTablet: true),
                    desktop: _buildDesktopView(session),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AssessmentSession session) {
    final progress = (_currentIndex + 1) / session.questions.length;

    return FadeInAnimation(
      child: Container(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 16 : 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.purple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Exit Assessment?'),
                        content: const Text('Your progress will be lost. Are you sure?'),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Exit'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      'Question ${_currentIndex + 1}/${session.questions.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Responsive.fontSize(context, 18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber.shade300, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Score: $_score',
                          style: TextStyle(
                            color: Colors.amber.shade100,
                            fontSize: Responsive.fontSize(context, 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Responsive.fontSize(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                tween: Tween(begin: 0.0, end: progress),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation(Colors.green.shade400),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionView(AssessmentSession session, {bool isTablet = false}) {
    return PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: session.questions.length,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      itemBuilder: (context, index) {
        final question = session.questions[index];
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 32 : 20),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: isTablet ? 600 : double.infinity),
                child: _buildQuestionCard(question, session),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopView(AssessmentSession session) {
    final question = session.questions[_currentIndex];
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progress Overview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ...List.generate(session.questions.length, (index) {
                  final isDone = index < _currentIndex;
                  final isCurrent = index == _currentIndex;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isDone
                                ? Colors.green.shade400
                                : isCurrent
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade300,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: isCurrent ? Colors.white : Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Question ${index + 1}',
                            style: TextStyle(
                              color: isCurrent ? Colors.blue.shade700 : Colors.grey.shade600,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: _buildQuestionCard(question, session),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Question question, AssessmentSession session) {
    return SlideInAnimation(
      key: ValueKey(_currentIndex),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Text(
                question.stage,
                style: TextStyle(
                  color: Colors.purple.shade700,
                  fontSize: Responsive.fontSize(context, 12),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              question.text,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 20),
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: Colors.grey.shade800,
              ),
            ),
            // Optionally show criterion as helper text to give context.
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question.criterion,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(context, 14),
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildAnswerInput(question),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerInput(Question question) {
    switch (question.responseType) {
      case ResponseType.yesNo:
        return _buildYesNoButtons(question);
      case ResponseType.multipleChoice:
        return _buildMultipleChoice(question);
      case ResponseType.shortAnswer:
        return _buildShortAnswer(question);
      case ResponseType.matching:
        return _buildMatchingQuestion(question);
    }
  }

  Widget _buildYesNoButtons(Question question) {
    return Column(
      children: [
        _buildOptionButton(
          'Yes',
          Icons.check_circle,
          Colors.green,
          () {
            setState(() => _selectedAnswer = 'yes');
            Future.delayed(const Duration(milliseconds: 300), () {
              _submitAnswer('yes', 0);
            });
          },
          _selectedAnswer == 'yes',
        ),
        const SizedBox(height: 16),
        _buildOptionButton(
          'No',
          Icons.cancel,
          Colors.red,
          () {
            setState(() => _selectedAnswer = 'no');
            Future.delayed(const Duration(milliseconds: 300), () {
              _submitAnswer('no', 0);
            });
          },
          _selectedAnswer == 'no',
        ),
      ],
    );
  }

  Widget _buildMultipleChoice(Question question) {
    return Column(
      children: question.options!.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final colors = [
          Colors.blue,
          Colors.purple,
          Colors.orange,
          Colors.green,
        ];
        final color = colors[index % colors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOptionButton(
            option,
            Icons.check_circle_outline,
            color,
            () {
              setState(() => _selectedAnswer = option);
              Future.delayed(const Duration(milliseconds: 300), () {
                _submitAnswer(option, 0);
              });
            },
            _selectedAnswer == option,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOptionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 20 : 24),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: Responsive.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: Colors.white,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortAnswer(Question question) {
    final controller = _shortAnswerControllers.putIfAbsent(
      question.id,
      () => TextEditingController(),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.edit_note, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Type your detailed answer below',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 14),
                    color: Colors.amber.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: controller,
          maxLines: 5,
          minLines: 4,
          decoration: InputDecoration(
            hintText: 'Enter your thoughtful answer here...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2.5),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 16),
            height: 1.5,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _submitAnswer(controller.text.trim(), 0);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.white),
                        const SizedBox(width: 12),
                        const Text('Please provide an answer before continuing'),
                      ],
                    ),
                    backgroundColor: Colors.orange.shade700,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Submit Answer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchingQuestion(Question question) {
    final pairs = question.matchingPairs ?? {};
    if (pairs.isEmpty) return const Text('No matching pairs available.');

    // Initialize selections if not present
    if (!_matchingSelections.containsKey(question.id)) {
      _matchingSelections[question.id] = {};
    }
    final selections = _matchingSelections[question.id]!;

    final leftItems = pairs.keys.toList();
    final rightItems = pairs.values.toList()..shuffle();

    // Calculate which right items are still available
    final usedRightItems = selections.values.where((v) => v != null).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.indigo.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.drag_indicator, color: Colors.indigo.shade700, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Drag items from the right to match with items on the left, or tap to select',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 13),
                    color: Colors.indigo.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Available items to drag
        Text(
          'Available answers:',
          style: TextStyle(
            fontSize: Responsive.fontSize(context, 14),
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: rightItems.where((r) => !usedRightItems.contains(r)).map((rightItem) {
            return Draggable<String>(
              data: rightItem,
              feedback: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rightItem,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.indigo.shade200),
                  ),
                  child: Text(
                    rightItem,
                    style: TextStyle(
                      fontSize: Responsive.fontSize(context, 13),
                      color: Colors.indigo.shade300,
                    ),
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.indigo.shade300),
                ),
                child: Text(
                  rightItem,
                  style: TextStyle(
                    fontSize: Responsive.fontSize(context, 13),
                    color: Colors.indigo.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        // Matching area
        ...leftItems.asMap().entries.map((entry) {
          final leftItem = entry.value;
          final matched = selections[leftItem];
          final colors = [Colors.blue, Colors.purple, Colors.teal, Colors.orange, Colors.pink];
          final color = colors[entry.key % colors.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 500;
                if (isMobile) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLeftMatchItem(leftItem, color),
                      const SizedBox(height: 8),
                      Center(
                        child: Icon(Icons.arrow_downward, color: Colors.grey.shade400, size: 20),
                      ),
                      const SizedBox(height: 8),
                      _buildRightMatchTarget(question.id, leftItem, matched, rightItems, usedRightItems, color),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: _buildLeftMatchItem(leftItem, color)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.arrow_forward, color: Colors.grey.shade400, size: 24),
                    ),
                    Expanded(child: _buildRightMatchTarget(question.id, leftItem, matched, rightItems, usedRightItems, color)),
                  ],
                );
              },
            ),
          );
        }),
        const SizedBox(height: 24),
        // Submit matching button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: selections.length == leftItems.length && selections.values.every((v) => v != null)
                ? () {
                    // Score based on correct matches
                    int correct = 0;
                    for (final left in leftItems) {
                      if (selections[left] == pairs[left]) {
                        correct++;
                      }
                    }
                    final scorePercent = (correct / leftItems.length * 100).round();
                    final answer = 'Matched $correct/${leftItems.length} correctly';
                    _submitAnswer(answer, 0);
                  }
                : null,
            icon: const Icon(Icons.check_circle),
            label: Text(
              selections.length == leftItems.length && selections.values.every((v) => v != null)
                  ? 'Submit Matches'
                  : 'Match all items to continue (${selections.values.where((v) => v != null).length}/${leftItems.length})',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeftMatchItem(String text, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.label, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: Responsive.fontSize(context, 14),
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightMatchTarget(
    String questionId,
    String leftItem,
    String? matched,
    List<String> rightItems,
    Set<String?> usedRightItems,
    Color color,
  ) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        setState(() {
          // Remove previous assignment of this right item
          _matchingSelections[questionId]?.removeWhere((k, v) => v == details.data);
          _matchingSelections[questionId]?[leftItem] = details.data;
        });
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        if (matched != null) {
          return Draggable<String>(
            data: matched,
            feedback: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  matched,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
            childWhenDragging: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid),
              ),
              child: const Center(child: Text('...')),
            ),
            onDragCompleted: () {
              // If dragged somewhere else, it's handled by the target
            },
            child: GestureDetector(
              onTap: () {
                // Unassign on tap
                setState(() {
                  _matchingSelections[questionId]?[leftItem] = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        matched,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.fontSize(context, 13),
                        ),
                      ),
                    ),
                    const Icon(Icons.close, color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () => _showMatchingPicker(questionId, leftItem, rightItems, usedRightItems),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isHovering ? color.withOpacity(0.15) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isHovering ? color : Colors.grey.shade300,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isHovering ? Icons.add_circle : Icons.touch_app,
                  color: isHovering ? color : Colors.grey.shade400,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isHovering ? 'Drop here' : 'Tap to match',
                  style: TextStyle(
                    color: isHovering ? color : Colors.grey.shade500,
                    fontSize: Responsive.fontSize(context, 13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMatchingPicker(
    String questionId,
    String leftItem,
    List<String> allRightItems,
    Set<String?> usedRightItems,
  ) {
    final available = allRightItems.where((r) => !usedRightItems.contains(r) || _matchingSelections[questionId]?[leftItem] == r).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select match for:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  leftItem,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...available.map((rightItem) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      tileColor: Colors.grey.shade50,
                      leading: const Icon(Icons.circle_outlined),
                      title: Text(rightItem),
                      onTap: () {
                        setState(() {
                          _matchingSelections[questionId]?.removeWhere((k, v) => v == rightItem);
                          _matchingSelections[questionId]?[leftItem] = rightItem;
                        });
                        Navigator.pop(ctx);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
