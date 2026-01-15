import 'package:flutter/foundation.dart';
import 'package:piaget/models/assessment_model.dart';
import 'package:piaget/models/cognitive_stage.dart';
import 'package:piaget/services/groq_service.dart';
import 'package:uuid/uuid.dart';

class AssessmentService {
  static const uuid = Uuid();

  // Question bank organized by stage and criterion
  static final Map<String, List<Question>> questionBank = {
    'preoperational': [
      Question(
        id: uuid.v4(),
        text: 'If I pour water from a tall glass into a short, wide glass, does the amount of water change?',
        criterion: 'Conservation',
        stage: 'preoperational',
        responseType: ResponseType.yesNo,
        scoringRules: {
          'yes': {'reasoning': 'perceptual', 'score': 20},
          'no': {'reasoning': 'logical', 'score': 80},
        },
      ),
      Question(
        id: uuid.v4(),
        text: 'Imagine a tree feels sad when its leaves fall. Is this true?',
        criterion: 'Animistic Thinking',
        stage: 'preoperational',
        responseType: ResponseType.multipleChoice,
        options: ['Yes, trees have feelings', 'Maybe sometimes', 'No, trees don\'t have feelings'],
        scoringRules: {
          'Yes, trees have feelings': {'reasoning': 'animistic', 'score': 20},
          'Maybe sometimes': {'reasoning': 'developing', 'score': 50},
          'No, trees don\'t have feelings': {'reasoning': 'logical', 'score': 90},
        },
      ),
      Question(
        id: uuid.v4(),
        text: 'Does your friend see the same thing you see when looking at a picture?',
        criterion: 'Egocentrism',
        stage: 'preoperational',
        responseType: ResponseType.yesNo,
        scoringRules: {
          'yes': {'reasoning': 'egocentric', 'score': 30},
          'no': {'reasoning': 'decentered', 'score': 85},
        },
      ),
      Question(
        id: uuid.v4(),
        text: 'When you pretend to be a doctor, what are you doing?',
        criterion: 'Symbolic Thinking',
        stage: 'preoperational',
        responseType: ResponseType.multipleChoice,
        options: [
          'Really becoming a doctor',
          'Using imagination to represent something',
          'Playing with real medical tools'
        ],
        scoringRules: {
          'Really becoming a doctor': {'reasoning': 'literal', 'score': 40},
          'Using imagination to represent something': {'reasoning': 'symbolic', 'score': 90},
          'Playing with real medical tools': {'reasoning': 'concrete', 'score': 55},
        },
      ),
    ],
    'concreteOperational': [
      Question(
        id: uuid.v4(),
        text: 'If you have 5 apples and your friend has 3, who has more?',
        criterion: 'Conservation',
        stage: 'concreteOperational',
        responseType: ResponseType.multipleChoice,
        options: ['You have more', 'Your friend has more', 'Same amount'],
        scoringRules: {
          'You have more': {'reasoning': 'correct_logical', 'score': 95},
          'Your friend has more': {'reasoning': 'incorrect', 'score': 20},
          'Same amount': {'reasoning': 'incorrect', 'score': 20},
        },
      ),
      Question(
        id: uuid.v4(),
        text: 'If Tom is taller than Sara, and Sara is taller than Mike, who is the tallest?',
        criterion: 'Transitive Inference',
        stage: 'concreteOperational',
        responseType: ResponseType.multipleChoice,
        options: ['Tom', 'Sara', 'Mike'],
        scoringRules: {
          'Tom': {'reasoning': 'correct_inference', 'score': 95},
          'Sara': {'reasoning': 'incorrect', 'score': 20},
          'Mike': {'reasoning': 'incorrect', 'score': 20},
        },
      ),
      Question(
        id: uuid.v4(),
        text: 'Can you group these items: Apple, Banana, Chair, Table. How would you organize them?',
        criterion: 'Classification',
        stage: 'concreteOperational',
        responseType: ResponseType.shortAnswer,
      ),
      Question(
        id: uuid.v4(),
        text: 'If I mix red and blue paint, what color do I get?',
        criterion: 'Cause-and-Effect Reasoning',
        stage: 'concreteOperational',
        responseType: ResponseType.multipleChoice,
        options: ['Red', 'Blue', 'Purple'],
        scoringRules: {
          'Red': {'reasoning': 'incorrect', 'score': 20},
          'Blue': {'reasoning': 'incorrect', 'score': 20},
          'Purple': {'reasoning': 'correct_cause_effect', 'score': 95},
        },
      ),
    ],
    'formalOperational': [
      Question(
        id: uuid.v4(),
        text: 'What would happen if there were no rules in society?',
        criterion: 'Hypothetical Reasoning',
        stage: 'formalOperational',
        responseType: ResponseType.shortAnswer,
      ),
      Question(
        id: uuid.v4(),
        text: 'Can you think of multiple solutions to reduce plastic pollution?',
        criterion: 'Systematic Problem Solving',
        stage: 'formalOperational',
        responseType: ResponseType.shortAnswer,
      ),
      Question(
        id: uuid.v4(),
        text: 'How do your beliefs about fairness compare with those of your friends?',
        criterion: 'Relativistic Thinking',
        stage: 'formalOperational',
        responseType: ResponseType.shortAnswer,
      ),
      Question(
        id: uuid.v4(),
        text: 'If all students study hard, do they all get good grades? Why or why not?',
        criterion: 'Abstract Thinking',
        stage: 'formalOperational',
        responseType: ResponseType.shortAnswer,
      ),
    ],
  };

  static Future<AssessmentSession> createAssessmentSession(
    String learnerId,
    int learnerAge,
  ) async {
    final stage = getStageBageFromAge(learnerAge);
    final List<Question> questions = [];

    debugPrint('🤖 Starting AI question generation for stage: ${stage.displayName}');

    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        final batch = await _generateAiQuestions(stage, attempt: attempt);
        _mergeUniqueQuestions(questions, batch, limit: 10);
        debugPrint('✅ Attempt $attempt produced ${batch.length} items; unique so far: ${questions.length}');
        if (questions.length >= 10) break;
      } catch (e, stackTrace) {
        debugPrint('❌ Attempt $attempt failed: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }

    if (questions.length < 10) {
      throw Exception('AI generation produced ${questions.length} unique questions after 3 attempts; need 10. Check internet and GROQ_API_KEY.');
    }

    return AssessmentSession(
      id: uuid.v4(),
      learnerId: learnerId,
      stageName: stage.displayName,
      questions: questions.take(10).toList(),
      startedAt: DateTime.now(),
    );
  }

  static List<Question> _getDefaultQuestions(CognitiveStage stage) {
    switch (stage) {
      case CognitiveStage.sensorimotor:
        return [
          Question(
            id: uuid.v4(),
            text: 'When an object is hidden, does it still exist?',
            criterion: 'Object Permanence',
            stage: 'sensorimotor',
            responseType: ResponseType.yesNo,
          ),
        ];
      case CognitiveStage.preoperational:
        return questionBank['preoperational'] ?? [];
      case CognitiveStage.concreteOperational:
        return questionBank['concreteOperational'] ?? [];
      case CognitiveStage.formalOperational:
        return questionBank['formalOperational'] ?? [];
    }
  }

  /// Generate up to 10 Piaget-aligned questions for the learner's cognitive stage using the AI backend.
  static Future<List<Question>> _generateAiQuestions(CognitiveStage stage, {int attempt = 1}) async {
    debugPrint('🔧 Initializing Groq service (attempt $attempt)...');
    final criteriaList = stage.indicators.join(', ');
    final stageLabel = stage.displayName;

    late GroqService groqService;
    try {
      groqService = GroqService();
      debugPrint('✅ Groq service initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize Groq service: $e');
      throw Exception('Groq client not configured: $e');
    }

    final prompt = '''
You are generating Piaget-aligned assessment questions.

Stage: $stageLabel
Allowed criteria (cover each at most once, diversify across the list): $criteriaList

Output STRICTLY this JSON (no prose):
{
  "questions": [
    {
      "text": "concise, age-appropriate question",
      "criterion": "one of the allowed criteria",
      "stage": "$stageLabel",
      "responseType": "yesNo" | "multipleChoice",
      "options": ["option 1", "option 2", "option 3"],
      "scoringRules": {
        "option": {"reasoning": "brief rationale", "score": 0-100}
      }
    }
  ]
}

Hard requirements:
- Exactly 10 questions.
- Each (criterion, text) must be unique.
- Do NOT repeat wording; vary verbs/nouns.
- For yesNo, include scoringRules for "yes" AND "no".
- For multipleChoice, include 3-4 options and scoringRules for EVERY option.
- Keep language stage-appropriate (simpler for younger learners).
''';

    debugPrint('📤 Sending request to Groq API (attempt $attempt)...');
    final response = await groqService.generateJsonResponse(
      prompt,
      temperature: attempt == 1 ? 0.45 : attempt == 2 ? 0.6 : 0.7,
      maxTokens: 2000,
    );
    debugPrint('📥 Received response from Groq API (attempt $attempt)');

    final rawList = response['questions'] as List<dynamic>? ?? [];
    if (rawList.isEmpty) {
      debugPrint('⚠️ API returned no questions on attempt $attempt. Raw keys: ${response.keys.toList()}');
      throw Exception('AI returned 0 questions on attempt $attempt');
    }
    debugPrint('📋 Parsing ${rawList.length} questions from API response...');

    final parsed = rawList.map((item) {
      final map = item as Map<String, dynamic>? ?? {};
      final text = (map['text'] ?? '').toString().trim();
      final criterion = (map['criterion'] ?? '').toString().trim();
      final responseTypeRaw = (map['responseType'] ?? '').toString();
      ResponseType responseType;
      switch (responseTypeRaw) {
        case 'multipleChoice':
          responseType = ResponseType.multipleChoice;
          break;
        default:
          responseType = ResponseType.yesNo;
      }

      final options = map['options'];
      List<String>? optionList;
      if (options is List) {
        optionList = options.map((o) => o.toString()).where((o) => o.isNotEmpty).toList();
      }

      final scoringRules = map['scoringRules'] as Map<String, dynamic>?;

      if (text.isEmpty || criterion.isEmpty) return null;

      return Question(
        id: uuid.v4(),
        text: text,
        criterion: criterion,
        stage: stage.name,
        responseType: responseType,
        options: optionList,
        scoringRules: scoringRules,
      );
    }).whereType<Question>().toList();

    debugPrint('✅ Parsed ${parsed.length} valid questions');

    // Deduplicate by (criterion, text)
    final seen = <String>{};
    final unique = <Question>[];
    for (final q in parsed) {
      final key = '${q.criterion.toLowerCase()}::${q.text.toLowerCase()}';
      if (!seen.contains(key)) {
        seen.add(key);
        unique.add(q);
      }
      if (unique.length >= 10) break;
    }

    debugPrint('🎯 Returning ${unique.length} unique questions');
    return unique;
  }

  static void _mergeUniqueQuestions(List<Question> target, List<Question> incoming, {required int limit}) {
    final seen = <String>{
      for (final q in target) '${q.criterion.toLowerCase()}::${q.text.toLowerCase()}'
    };

    for (final q in incoming) {
      final key = '${q.criterion.toLowerCase()}::${q.text.toLowerCase()}';
      if (!seen.contains(key)) {
        target.add(q);
        seen.add(key);
      }
      if (target.length >= limit) break;
    }
  }

  static CriterionEvaluation evaluateCriterion(
    String criterion,
    String answer,
    Map<String, dynamic>? scoringRules,
  ) {
    if (scoringRules == null) {
      return CriterionEvaluation(
        criterionName: criterion,
        status: CriterionStatus.developing,
        score: 50,
        feedback: 'Response recorded for manual evaluation.',
      );
    }

    final ruleEntry = scoringRules[answer];
    if (ruleEntry != null) {
      final score = (ruleEntry['score'] as int?) ?? 50;
      final reasoning = ruleEntry['reasoning'] ?? 'unknown';

      CriterionStatus status;
      if (score >= 80) {
        status = CriterionStatus.achieved;
      } else if (score >= 50) {
        status = CriterionStatus.developing;
      } else {
        status = CriterionStatus.notYetAchieved;
      }

      return CriterionEvaluation(
        criterionName: criterion,
        status: status,
        score: score.toDouble(),
        feedback: _generateFeedback(criterion, status, reasoning),
      );
    }

    return CriterionEvaluation(
      criterionName: criterion,
      status: CriterionStatus.developing,
      score: 50,
      feedback: 'Response needs further evaluation.',
    );
  }

  static String _generateFeedback(
    String criterion,
    CriterionStatus status,
    String reasoning,
  ) {
    switch (status) {
      case CriterionStatus.achieved:
        return 'Great! Your response shows strong understanding of $criterion. Keep practicing!';
      case CriterionStatus.developing:
        return 'You\'re developing $criterion. With more practice, you\'ll master this skill.';
      case CriterionStatus.notYetAchieved:
        return 'It\'s okay! $criterion is still developing. Let\'s work on it together through activities.';
    }
  }

  static AssessmentResult generateAssessmentResult(
    String learnerId,
    AssessmentSession session,
    List<QuestionResponse> responses,
    List<CriterionEvaluation> evaluations,
  ) {
    final strengths = evaluations
        .where((e) => e.status == CriterionStatus.achieved)
        .map((e) => e.criterionName)
        .toList();

    final developmentAreas = evaluations
        .where((e) => e.status == CriterionStatus.notYetAchieved)
        .map((e) => e.criterionName)
        .toList();

    final suggestedActivities = _generateSuggestedActivities(developmentAreas);
    
    final overallScore = evaluations.isEmpty
        ? 0
        : evaluations.map((e) => e.score).reduce((a, b) => a + b) / evaluations.length;

    return AssessmentResult(
      id: uuid.v4(),
      learnerId: learnerId,
      assessmentStage: session.stageName,
      criteriaResults: evaluations,
      identifiedStage: session.stageName,
      strengths: strengths,
      developmentAreas: developmentAreas,
      suggestedActivities: suggestedActivities,
      completedAt: DateTime.now(),
      overallScore: (overallScore * 100).round() / 100,
    );
  }

  static List<String> _generateSuggestedActivities(List<String> developmentAreas) {
    final activityMap = {
      'Conservation': 'Practice with liquids and solids - observe changes in appearance vs quantity',
      'Reversibility': 'Play with building blocks and reversing sequences',
      'Egocentrism': 'Role-playing games to understand different perspectives',
      'Symbolic Thinking': 'Creative play with props and storytelling',
      'Classification': 'Sorting activities with different categories',
      'Transitive Inference': 'Logic puzzles and comparison games',
      'Hypothetical Reasoning': 'Discussion of "what if" scenarios',
      'Abstract Thinking': 'Discussions about concepts and ideas',
      'Systematic Problem Solving': 'Project-based learning with planning steps',
      'Metacognition': 'Reflection exercises and journaling',
    };

    return developmentAreas
        .map((area) => activityMap[area] ?? 'Practice activities for $area development')
        .toList();
  }
}
