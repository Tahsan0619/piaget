import 'package:flutter/material.dart';
import 'package:piaget/models/assessment_model.dart';
import 'package:piaget/models/user_model.dart';
import 'package:piaget/services/assessment_service.dart';

class AssessmentProvider extends ChangeNotifier {
  AssessmentSession? _currentSession;
  LearnerProfile? _currentLearner;
  final List<QuestionResponse> _responses = [];
  final List<CriterionEvaluation> _evaluations = [];
  AssessmentResult? _lastResult;
  bool _isLoading = false;
  String? _error;

  AssessmentSession? get currentSession => _currentSession;
  LearnerProfile? get currentLearner => _currentLearner;
  List<QuestionResponse> get responses => _responses;
  List<CriterionEvaluation> get evaluations => _evaluations;
  AssessmentResult? get lastResult => _lastResult;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSessionActive => _currentSession != null && !_currentSession!.isCompleted;

  void initializeLearner(String learnerId, String name, int age, {String? className}) {
    _currentLearner = LearnerProfile(
      id: learnerId,
      name: name,
      age: age,
      className: className,
    );
    notifyListeners();
  }

  Future<void> startAssessment() async {
    if (_currentLearner == null) {
      _error = 'Learner profile not initialized';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentSession = await AssessmentService.createAssessmentSession(
        _currentLearner!.id,
        _currentLearner!.age,
      );
      _responses.clear();
      _evaluations.clear();
      _isLoading = false;
      _error = null;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to start assessment: $e';
      notifyListeners();
    }
    notifyListeners();
  }

  void recordResponse(
    String questionId,
    String answer,
    int timeSpentSeconds,
  ) {
    final response = QuestionResponse(
      questionId: questionId,
      answer: answer,
      timeSpentSeconds: timeSpentSeconds,
      respondedAt: DateTime.now(),
    );

    _responses.add(response);

    // Find the question and evaluate
    if (_currentSession != null) {
      final question = _currentSession!.questions.firstWhere(
        (q) => q.id == questionId,
        orElse: () => Question(
          id: '',
          text: '',
          criterion: '',
          stage: '',
          responseType: ResponseType.yesNo,
        ),
      );

      if (question.id.isNotEmpty) {
        final evaluation = AssessmentService.evaluateCriterion(
          question.criterion,
          answer,
          question.scoringRules,
        );
        _evaluations.add(evaluation);
      }
    }

    notifyListeners();
  }

  void completeAssessment() {
    if (_currentSession == null || _currentLearner == null) {
      _error = 'No active assessment session';
      notifyListeners();
      return;
    }

    _currentSession!.completedAt = DateTime.now();

    _lastResult = AssessmentService.generateAssessmentResult(
      _currentLearner!.id,
      _currentSession!,
      _responses,
      _evaluations,
    );

    notifyListeners();
  }

  void resetAssessment() {
    _currentSession = null;
    _responses.clear();
    _evaluations.clear();
    _error = null;
    notifyListeners();
  }

  void resetLearner() {
    _currentLearner = null;
    resetAssessment();
  }
}
