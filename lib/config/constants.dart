class AppConstants {
  // API Configuration
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String groqModel = 'mixtral-8x7b-32768';
  static const int groqMaxTokens = 1024;
  static const double groqTemperature = 0.7;

  // Assessment Configuration
  static const int defaultQuestionsPerAssessment = 10;
  static const int minLearnAge = 7;
  static const int maxLearnAge = 18;

  // Piaget's Cognitive Stages Age Ranges
  static const int concreteOperationalMaxAge = 11;
  // Formal operational starts at 11+

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 4.0;
}

class ErrorMessages {
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorizedError = 'Unauthorized access.';
  static const String notFoundError = 'Resource not found.';
  static const String validationError = 'Please fill in all required fields.';
  static const String unknownError = 'An unknown error occurred. Please try again.';
}

class SuccessMessages {
  static const String assessmentStarted = 'Assessment started successfully!';
  static const String assessmentCompleted = 'Assessment completed!';
  static const String loginSuccess = 'Login successful!';
  static const String logoutSuccess = 'Logged out successfully.';
}
