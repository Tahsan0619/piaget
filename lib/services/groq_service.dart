import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Groq API client tuned for Piaget-aligned, JSON-first responses.
class GroqService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'mixtral-8x7b-32768';

  // Lower temperature and bounded tokens for more deterministic, on-topic replies.
  static const double _defaultTemperature = 0.35;
  static const double _defaultTopP = 0.9;
  static const int _defaultMaxTokens = 900;

  late final String _apiKey;
  final http.Client _client;

  GroqService({http.Client? client}) : _client = client ?? http.Client() {
    _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('GROQ_API_KEY not found in environment variables');
    }
  }

  Future<String> generateContent(
    String prompt, {
    double temperature = _defaultTemperature,
    int maxTokens = _defaultMaxTokens,
  }) async {
    final content = await _callChat(
      messages: [
        {
          'role': 'system',
          'content': _systemGeneral,
        },
        {
          'role': 'user',
          'content': prompt,
        },
      ],
      temperature: temperature,
      maxTokens: maxTokens,
      expectJson: false,
    );
    return content;
  }

  /// Helper to request strictly JSON responses with the given prompt.
  Future<Map<String, dynamic>> generateJsonResponse(
    String prompt, {
    double temperature = _defaultTemperature,
    int maxTokens = _defaultMaxTokens,
  }) async {
    final content = await _callChat(
      messages: [
        {
          'role': 'system',
          'content': _systemGeneral,
        },
        {
          'role': 'user',
          'content': prompt,
        },
      ],
      temperature: temperature,
      maxTokens: maxTokens,
      expectJson: true,
    );

    return _safeJsonDecode(content, fallbackLabel: 'json_response');
  }

  Future<Map<String, dynamic>> generateSuggestions(
    String learnerAge,
    List<String> developmentAreas,
  ) async {
    final areasText = developmentAreas.isEmpty
        ? 'general cognitive development'
        : developmentAreas.join(', ');

    final prompt = '''
Child age: $learnerAge years.
Focus areas: $areasText.

Provide Piaget-aligned, age-appropriate learning suggestions.
Return ONLY compact JSON with this exact shape:
{
  "activities": ["activity 1", "activity 2", "activity 3"],
  "materials": ["material 1", "material 2"],
  "guidance": "1-2 sentences for adult support",
  "tips": ["tip 1", "tip 2"]
}

Rules:
- No prose outside JSON.
- Activities must be concrete, safe, and doable at home/school.
- Align with Piaget stage expectations for the given age.
- Keep language simple, specific, and actionable.
- Avoid repetition; diversify activities.
''';

    final content = await _callChat(
      messages: [
        {'role': 'system', 'content': _systemSuggestions},
        {'role': 'user', 'content': prompt},
      ],
      temperature: 0.35,
      maxTokens: 600,
      expectJson: true,
    );

    return _safeJsonDecode(content, fallbackLabel: 'suggestions');
  }

  Future<Map<String, dynamic>> evaluateResponse(
    String criterion,
    String question,
    String learnerResponse,
    String stage,
  ) async {
    final prompt = '''
Evaluate the learner response using Piaget cognitive expectations.

Criterion: $criterion
Stage: $stage
Question: $question
Learner Response: "$learnerResponse"

Return ONLY JSON with this exact shape:
{
  "status": "achieved" | "developing" | "notYetAchieved",
  "score": 0-100,
  "reasoning": "short rationale",
  "feedback": "1-2 actionable coaching tips"
}

Rules:
- No text outside JSON.
- Ground reasoning in stage expectations and observed response quality.
- Keep feedback specific and supportive.
''';

    final content = await _callChat(
      messages: [
        {'role': 'system', 'content': _systemEvaluator},
        {'role': 'user', 'content': prompt},
      ],
      temperature: 0.3,
      maxTokens: 500,
      expectJson: true,
    );

    return _safeJsonDecode(content, fallbackLabel: 'evaluation');
  }

  /// Core chat caller with optional JSON expectation for higher relevance.
  Future<String> _callChat({
    required List<Map<String, String>> messages,
    double temperature = _defaultTemperature,
    double topP = _defaultTopP,
    int maxTokens = _defaultMaxTokens,
    bool expectJson = false,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': temperature,
          'top_p': topP,
          'max_tokens': maxTokens,
          'presence_penalty': 0,
          'frequency_penalty': 0,
          if (expectJson) 'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Groq error ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content =
          data['choices']?[0]?['message']?['content']?.toString() ?? '';

      if (content.isEmpty) {
        throw Exception('Groq response was empty');
      }

      return content.trim();
    } catch (e) {
      throw Exception('Error calling Groq API: $e');
    }
  }

  Map<String, dynamic> _safeJsonDecode(String raw, {required String fallbackLabel}) {
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      // Attempt to salvage JSON if the model wrapped it in text.
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        try {
          return jsonDecode(raw.substring(start, end + 1)) as Map<String, dynamic>;
        } catch (_) {
          // fall through
        }
      }
      throw Exception('Unable to parse $fallbackLabel JSON from Groq response. Raw: $raw');
    }
  }

  static const String _systemGeneral =
      'You are a concise educational assistant. Provide grounded, specific answers. Avoid fluff.';

  static const String _systemSuggestions = '''
You are an educational psychologist and curriculum designer.
You strictly return compact JSON and nothing else.
Prioritize Piaget-aligned, age-appropriate, practical activities.
Be concise, concrete, and safe. Avoid repetition and generic advice.
''';

  static const String _systemEvaluator = '''
You are a cognitive development evaluator. Judge responses against Piaget stage expectations.
Return only JSON. Be specific, concise, and constructive.
''';
}
