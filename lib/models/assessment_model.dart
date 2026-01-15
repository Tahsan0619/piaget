enum CriterionStatus { achieved, developing, notYetAchieved }

enum ResponseType { yesNo, multipleChoice, shortAnswer }

class Question {
  final String id;
  final String text;
  final String criterion;
  final String stage;
  final ResponseType responseType;
  final List<String>? options;
  final String? correctAnswer;
  final Map<String, dynamic>? scoringRules;

  Question({
    required this.id,
    required this.text,
    required this.criterion,
    required this.stage,
    required this.responseType,
    this.options,
    this.correctAnswer,
    this.scoringRules,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      criterion: json['criterion'] as String,
      stage: json['stage'] as String,
      responseType: ResponseType.values.byName(json['responseType'] as String),
      options: List<String>.from(json['options'] as List? ?? []),
      correctAnswer: json['correctAnswer'] as String?,
      scoringRules: json['scoringRules'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'criterion': criterion,
    'stage': stage,
    'responseType': responseType.name,
    'options': options,
    'correctAnswer': correctAnswer,
    'scoringRules': scoringRules,
  };
}

class QuestionResponse {
  final String questionId;
  final String answer;
  final int timeSpentSeconds;
  final DateTime respondedAt;

  QuestionResponse({
    required this.questionId,
    required this.answer,
    required this.timeSpentSeconds,
    required this.respondedAt,
  });

  factory QuestionResponse.fromJson(Map<String, dynamic> json) {
    return QuestionResponse(
      questionId: json['questionId'] as String,
      answer: json['answer'] as String,
      timeSpentSeconds: json['timeSpentSeconds'] as int,
      respondedAt: DateTime.parse(json['respondedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'answer': answer,
    'timeSpentSeconds': timeSpentSeconds,
    'respondedAt': respondedAt.toIso8601String(),
  };
}

class CriterionEvaluation {
  final String criterionName;
  final CriterionStatus status;
  final double score;
  final String feedback;

  CriterionEvaluation({
    required this.criterionName,
    required this.status,
    required this.score,
    required this.feedback,
  });

  factory CriterionEvaluation.fromJson(Map<String, dynamic> json) {
    return CriterionEvaluation(
      criterionName: json['criterionName'] as String,
      status: CriterionStatus.values.byName(json['status'] as String),
      score: (json['score'] as num).toDouble(),
      feedback: json['feedback'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'criterionName': criterionName,
    'status': status.name,
    'score': score,
    'feedback': feedback,
  };
}

class AssessmentResult {
  final String id;
  final String learnerId;
  final String assessmentStage;
  final List<CriterionEvaluation> criteriaResults;
  final String identifiedStage;
  final List<String> strengths;
  final List<String> developmentAreas;
  final List<String> suggestedActivities;
  final DateTime completedAt;
  final double overallScore;

  AssessmentResult({
    required this.id,
    required this.learnerId,
    required this.assessmentStage,
    required this.criteriaResults,
    required this.identifiedStage,
    required this.strengths,
    required this.developmentAreas,
    required this.suggestedActivities,
    required this.completedAt,
    required this.overallScore,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      id: json['id'] as String,
      learnerId: json['learnerId'] as String,
      assessmentStage: json['assessmentStage'] as String,
      criteriaResults: (json['criteriaResults'] as List)
          .map((e) => CriterionEvaluation.fromJson(e as Map<String, dynamic>))
          .toList(),
      identifiedStage: json['identifiedStage'] as String,
      strengths: List<String>.from(json['strengths'] as List),
      developmentAreas: List<String>.from(json['developmentAreas'] as List),
      suggestedActivities: List<String>.from(json['suggestedActivities'] as List),
      completedAt: DateTime.parse(json['completedAt'] as String),
      overallScore: (json['overallScore'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'learnerId': learnerId,
    'assessmentStage': assessmentStage,
    'criteriaResults': criteriaResults.map((e) => e.toJson()).toList(),
    'identifiedStage': identifiedStage,
    'strengths': strengths,
    'developmentAreas': developmentAreas,
    'suggestedActivities': suggestedActivities,
    'completedAt': completedAt.toIso8601String(),
    'overallScore': overallScore,
  };
}

class AssessmentSession {
  final String id;
  final String learnerId;
  final String stageName;
  final List<Question> questions;
  final List<QuestionResponse> responses;
  final DateTime startedAt;
  DateTime? completedAt;

  AssessmentSession({
    required this.id,
    required this.learnerId,
    required this.stageName,
    required this.questions,
    this.responses = const [],
    required this.startedAt,
    this.completedAt,
  });

  bool get isCompleted => completedAt != null;

  int get progress => responses.length;

  double get progressPercentage => (progress / questions.length * 100).clamp(0, 100);
}
