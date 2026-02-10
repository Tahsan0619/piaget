import 'package:flutter/material.dart';
import 'package:piaget/models/assessment_model.dart';
import 'package:piaget/models/user_model.dart';
import 'package:piaget/models/cognitive_stage.dart';
import 'package:piaget/services/assessment_service.dart';
import 'package:piaget/services/supabase_service.dart';

class AssessmentProvider extends ChangeNotifier {
  AssessmentSession? _currentSession;
  LearnerProfile? _currentLearner;
  String? _realStudentId; // Actual user ID from auth
  final List<QuestionResponse> _responses = [];
  final List<CriterionEvaluation> _evaluations = [];
  AssessmentResult? _lastResult;
  bool _isLoading = false;
  String? _error;
  final _supabase = SupabaseService();

  AssessmentSession? get currentSession => _currentSession;
  LearnerProfile? get currentLearner => _currentLearner;
  List<QuestionResponse> get responses => _responses;
  List<CriterionEvaluation> get evaluations => _evaluations;
  AssessmentResult? get lastResult => _lastResult;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSessionActive => _currentSession != null && !_currentSession!.isCompleted;

  void initializeLearner(String learnerId, String name, int age, {String? className, String? realStudentId}) {
    debugPrint('\n🧑 ========== INITIALIZING LEARNER ==========');
    debugPrint('🏷️ Learner ID: $learnerId');
    debugPrint('📝 Name: $name');
    debugPrint('🎂 Age: $age years');
    debugPrint('🏫 Class: ${className ?? "None"}');
    debugPrint('🆔 Real Student ID: ${realStudentId ?? "None"}');
    
    _currentLearner = LearnerProfile(
      id: learnerId,
      name: name,
      age: age,
      className: className,
    );
    _realStudentId = realStudentId;
    debugPrint('✅ Learner profile created successfully');
    debugPrint('🧑 ========================================\n');
    notifyListeners();
  }

  Future<void> startAssessment() async {
    debugPrint('\n🚀 ========== START ASSESSMENT FLOW ==========');
    
    if (_currentLearner == null) {
      _error = 'Learner profile not initialized';
      debugPrint('❌ CRITICAL: Learner profile is NULL');
      debugPrint('🚀 ======================================\n');
      notifyListeners();
      return;
    }

    debugPrint('✅ Learner profile verified:');
    debugPrint('   - ID: ${_currentLearner!.id}');
    debugPrint('   - Name: ${_currentLearner!.name}');
    debugPrint('   - Age: ${_currentLearner!.age}');

    _isLoading = true;
    _error = null;
    debugPrint('🔄 Setting loading state to TRUE');
    notifyListeners();

    try {
      debugPrint('🎯 Calling AssessmentService.createAssessmentSession...');
      debugPrint('   - Learner ID: ${_currentLearner!.id}');
      debugPrint('   - Age: ${_currentLearner!.age}');
      
      _currentSession = await AssessmentService.createAssessmentSession(
        _currentLearner!.id,
        _currentLearner!.age,
      );
      
      debugPrint('✅ Assessment session created successfully!');
      debugPrint('   - Session ID: ${_currentSession?.id}');
      debugPrint('   - Stage Name: ${_currentSession?.stageName}');
      debugPrint('   - Questions Count: ${_currentSession?.questions.length}');

      // Save session to database if we have realStudentId
      if (_realStudentId != null && _currentSession != null) {
        debugPrint('\n💾 Saving session to database...');
        try {
          // Convert display name to database enum value
          final dbStageValue = stageDisplayNameToDatabaseValue(_currentSession!.stageName);
          debugPrint('📊 Converting stage: "${_currentSession!.stageName}" → "$dbStageValue"');
          
          await _supabase.createAssessmentSession(
            sessionId: _currentSession!.id, // Use the pre-generated ID
            studentId: _realStudentId!,
            stage: dbStageValue,
            title: 'Cognitive Assessment - ${_currentSession!.stageName}',
            description: 'Piaget-based developmental assessment',
          );
          debugPrint('✅ Session saved to database with ID: ${_currentSession!.id}');
          
          // Save questions to database
          debugPrint('💾 Saving questions to database...');
          await _supabase.addQuestionsToSession(
            _currentSession!.id,
            _currentSession!.questions,
          );
          debugPrint('✅ Questions saved to database');
        } catch (dbError) {
          debugPrint('⚠️ Warning: Could not save to database: $dbError');
          // Continue anyway - session exists in memory
        }
      }
      
      _responses.clear();
      _evaluations.clear();
      debugPrint('🧹 Cleared previous responses and evaluations');
      
      _isLoading = false;
      _error = null;
      debugPrint('✅ Assessment ready - loading state set to FALSE');
      debugPrint('🚀 ========== ASSESSMENT FLOW SUCCESS ==========\n');
    } catch (e, stackTrace) {
      _isLoading = false;
      _error = 'Failed to start assessment: $e';
      debugPrint('❌ ========== ASSESSMENT FLOW FAILED ==========');
      debugPrint('❌ Error Type: ${e.runtimeType}');
      debugPrint('❌ Error Message: $e');
      debugPrint('📚 Stack Trace:');
      debugPrint(stackTrace.toString());
      debugPrint('❌ ==========================================\n');
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

  Future<void> completeAssessment() async {
    debugPrint('\n🏁 ========== COMPLETING ASSESSMENT ==========');
    
    if (_currentSession == null || _currentLearner == null) {
      _error = 'No active assessment session';
      debugPrint('❌ Cannot complete: No active session or learner');
      debugPrint('🏁 ============================================\n');
      notifyListeners();
      return;
    }

    if (_realStudentId == null) {
      _error = 'Student ID not found';
      debugPrint('❌ Cannot save: Real student ID is null');
      debugPrint('🏁 ============================================\n');
      notifyListeners();
      return;
    }

    _currentSession!.completedAt = DateTime.now();
    final duration = _currentSession!.completedAt!
        .difference(_currentSession!.startedAt)
        .inSeconds;

    debugPrint('⏱️ Assessment Duration: $duration seconds');

    _lastResult = AssessmentService.generateAssessmentResult(
      _currentLearner!.id,
      _currentSession!,
      _responses,
      _evaluations,
    );

    debugPrint('✅ Assessment result generated in memory');
    debugPrint('📊 Stage: ${_lastResult!.identifiedStage}');
    debugPrint('📊 Score: ${_lastResult!.overallScore}');
    debugPrint('📊 Strengths: ${_lastResult!.strengths.length}');
    debugPrint('📊 Development Areas: ${_lastResult!.developmentAreas.length}');

    // Save to database
    try {
      debugPrint('\n💾 Saving assessment to database...');
      
      // Convert criteriaResults list to map for database storage
      final criteriaMap = <String, dynamic>{};
      for (var i = 0; i < _lastResult!.criteriaResults.length; i++) {
        final eval = _lastResult!.criteriaResults[i];
        criteriaMap[eval.criterionName] = {
          'status': eval.status.name,
          'score': eval.score,
          'feedback': eval.feedback,
        };
      }
      
      // Convert display name to database enum value
      final dbStageValue = stageDisplayNameToDatabaseValue(_lastResult!.identifiedStage);
      debugPrint('📊 Converting stage: "${_lastResult!.identifiedStage}" → "$dbStageValue"');
      
      await _supabase.saveCompleteAssessment(
        sessionId: _currentSession!.id,
        studentId: _realStudentId!,
        identifiedStage: dbStageValue,
        overallScore: _lastResult!.overallScore,
        strengths: _lastResult!.strengths,
        developmentAreas: _lastResult!.developmentAreas,
        suggestedActivities: _lastResult!.suggestedActivities,
        durationSeconds: duration,
        criteriaResults: criteriaMap,
      );
      debugPrint('✅ Assessment saved to database successfully!');
      debugPrint('🏁 ========== ASSESSMENT COMPLETED ==========\n');
    } catch (e, stackTrace) {
      _error = 'Failed to save assessment: $e';
      debugPrint('❌ Failed to save to database: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      debugPrint('🏁 ========== ASSESSMENT SAVE FAILED ==========\n');
    }

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
    _realStudentId = null;
    resetAssessment();
  }
}
