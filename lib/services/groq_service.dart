import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Groq API client tuned for Piaget-aligned, JSON-first responses.
class GroqService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  // Lower temperature and bounded tokens for more deterministic, on-topic replies.
  static const double _defaultTemperature = 0.35;
  static const double _defaultTopP = 0.9;
  static const int _defaultMaxTokens = 900;

  late final String _apiKey;
  final http.Client _client;

  GroqService({http.Client? client}) : _client = client ?? http.Client() {
    debugPrint('\n📖 ========== GROQ SERVICE INITIALIZATION ==========');
    _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    
    if (_apiKey.isEmpty) {
      debugPrint('❌ CRITICAL ERROR: GROQ_API_KEY not found in environment variables');
      debugPrint('⚠️ Please check:');
      debugPrint('   1. .env file exists in project root');
      debugPrint('   2. .env contains: GROQ_API_KEY=your_api_key_here');
      debugPrint('   3. dotenv.load() was called in main()');
      debugPrint('📖 ================================================\n');
      throw Exception('GROQ_API_KEY not found in environment variables');
    }
    
    final keyPreview = _apiKey.length > 10 
        ? '${_apiKey.substring(0, 10)}...${_apiKey.substring(_apiKey.length - 4)}'
        : '***';
    debugPrint('✅ API Key found: $keyPreview (${_apiKey.length} chars)');
    debugPrint('🌍 Base URL: $_baseUrl');
    debugPrint('🤖 Model: $_model');
    debugPrint('📖 ================================================\n');
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
    debugPrint('\n💬 ========== GROQ JSON REQUEST ==========');
    debugPrint('🌡️ Temperature: $temperature');
    debugPrint('📊 Max Tokens: $maxTokens');
    debugPrint('📝 Prompt length: ${prompt.length} chars');
    
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

    debugPrint('📋 Response content length: ${content.length} chars');
    debugPrint('📝 Parsing JSON response...');
    final result = _safeJsonDecode(content, fallbackLabel: 'json_response');
    debugPrint('✅ JSON parsed successfully');
    debugPrint('💬 ======================================\n');
    return result;
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
    debugPrint('\n🌐 ========== HTTP REQUEST TO GROQ API ==========');
    debugPrint('📍 URL: $_baseUrl');
    debugPrint('🤖 Model: $_model');
    debugPrint('🌡️ Temperature: $temperature');
    debugPrint('📊 Top P: $topP');
    debugPrint('📊 Max Tokens: $maxTokens');
    debugPrint('📑 Expect JSON: $expectJson');
    debugPrint('💬 Messages: ${messages.length}');
    
    try {
      debugPrint('\n📦 Building HTTP request...');
      final requestBody = {
        'model': _model,
        'messages': messages,
        'temperature': temperature,
        'top_p': topP,
        'max_tokens': maxTokens,
        'presence_penalty': 0,
        'frequency_penalty': 0,
        if (expectJson) 'response_format': {'type': 'json_object'},
      };
      
      debugPrint('📋 Request body size: ${jsonEncode(requestBody).length} chars');
      debugPrint('🚀 Sending HTTP POST request...');
      final requestStartTime = DateTime.now();
      
      final response = await _client.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode(requestBody),
      );
      
      final requestDuration = DateTime.now().difference(requestStartTime);
      debugPrint('⏱️ Request completed in ${requestDuration.inMilliseconds}ms');
      debugPrint('📊 HTTP Status Code: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('❌ ========== GROQ API ERROR ==========');
        debugPrint('❌ Status Code: ${response.statusCode}');
        debugPrint('❌ Response Body: ${response.body}');
        debugPrint('❌ Response Headers: ${response.headers}');
        debugPrint('❌ ===================================\n');
        throw Exception('Groq error ${response.statusCode}: ${response.body}');
      }

      debugPrint('✅ Received successful response');
      debugPrint('📋 Response body size: ${response.body.length} chars');
      
      debugPrint('\n📝 Parsing response JSON...');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('✅ Response JSON parsed successfully');
      
      final content =
          data['choices']?[0]?['message']?['content']?.toString() ?? '';

      if (content.isEmpty) {
        debugPrint('❌ Response content is EMPTY');
        debugPrint('📊 Response structure: ${data.keys.toList()}');
        debugPrint('📊 Choices: ${data['choices']}');
        throw Exception('Groq response was empty');
      }

      debugPrint('✅ Extracted content: ${content.length} chars');
      debugPrint('🌐 ============================================\n');
      return content.trim();
    } catch (e, stackTrace) {
      debugPrint('❌ ========== HTTP REQUEST FAILED ==========');
      debugPrint('❌ Error Type: ${e.runtimeType}');
      debugPrint('❌ Error: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      debugPrint('❌ ========================================\n');
      throw Exception('Error calling Groq API: $e');
    }
  }

  Map<String, dynamic> _safeJsonDecode(String raw, {required String fallbackLabel}) {
    debugPrint('\n📝 ========== JSON PARSING ==========');
    debugPrint('📊 Input length: ${raw.length} chars');
    
    try {
      final parsed = jsonDecode(raw) as Map<String, dynamic>;
      debugPrint('✅ JSON parsed successfully on first attempt');
      debugPrint('📊 Keys: ${parsed.keys.toList()}');
      debugPrint('📝 ==================================\n');
      return parsed;
    } catch (e) {
      debugPrint('⚠️ First parse attempt failed: $e');
      debugPrint('🔍 Attempting to salvage JSON...');
      
      // Attempt to salvage JSON if the model wrapped it in text.
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      debugPrint('📍 Found braces at: start=$start, end=$end');
      
      if (start != -1 && end != -1 && end > start) {
        try {
          final extracted = raw.substring(start, end + 1);
          debugPrint('🔪 Extracted substring: ${extracted.length} chars');
          final parsed = jsonDecode(extracted) as Map<String, dynamic>;
          debugPrint('✅ JSON salvaged successfully!');
          debugPrint('📊 Keys: ${parsed.keys.toList()}');
          debugPrint('📝 ==================================\n');
          return parsed;
        } catch (e2) {
          debugPrint('❌ Salvage attempt also failed: $e2');
        }
      }
      
      debugPrint('❌ ========== JSON PARSE FAILED ==========');
      debugPrint('❌ Label: $fallbackLabel');
      debugPrint('❌ Raw content preview (first 500 chars):');
      debugPrint(raw.length > 500 ? raw.substring(0, 500) : raw);
      debugPrint('❌ ======================================\n');
      throw Exception('Unable to parse $fallbackLabel JSON from Groq response. Raw: ${raw.substring(0, raw.length > 200 ? 200 : raw.length)}');
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
