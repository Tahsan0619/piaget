import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Simple diagnostic tool to test Groq API connectivity and configuration
Future<void> main() async {
  print('🔍 Groq API Connection Diagnostic Tool');
  print('=' * 60);

  // Load environment
  print('\n📁 Loading .env file...');
  try {
    await dotenv.load(fileName: '.env');
    print('✅ .env file loaded successfully');
  } catch (e) {
    print('❌ Failed to load .env file: $e');
    return;
  }

  // Check API key
  print('\n🔑 Checking GROQ_API_KEY...');
  final apiKey = dotenv.env['GROQ_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('❌ GROQ_API_KEY is not set in .env file');
    return;
  }
  print('✅ GROQ_API_KEY found');
  print('   Key preview: ${apiKey.substring(0, 10)}...${apiKey.substring(apiKey.length - 4)}');

  // Test basic API connectivity
  print('\n🌐 Testing Groq API connectivity...');
  final testResponse = await _testApiConnection(apiKey);
  if (!testResponse) {
    print('❌ Cannot connect to Groq API');
    return;
  }

  // Test JSON generation
  print('\n📝 Testing JSON question generation...');
  final generationSuccess = await _testJsonGeneration(apiKey);
  if (!generationSuccess) {
    print('❌ Failed to generate JSON response from API');
    return;
  }

  print('\n' + '=' * 60);
  print('✅ All diagnostics passed! Groq API is configured correctly.');
  print('If questions still appear static in the app:');
  print('   1. Clear app cache: flutter clean');
  print('   2. Rebuild the app: flutter run');
  print('   3. Check logs for any errors during question generation');
}

Future<bool> _testApiConnection(String apiKey) async {
  try {
    const baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
    const model = 'llama-3.3-70b-versatile';

    final request = {
      'model': model,
      'messages': [
        {'role': 'user', 'content': 'Say hello in one word'}
      ],
      'max_tokens': 10,
      'temperature': 0.3,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(request),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Request timed out'),
    );

    print('   Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('✅ Successfully connected to Groq API');
      return true;
    } else if (response.statusCode == 401) {
      print('❌ API key authentication failed');
      print('   Response: ${response.body}');
      return false;
    } else if (response.statusCode == 429) {
      print('❌ API rate limit exceeded');
      print('   Response: ${response.body}');
      return false;
    } else {
      print('❌ Unexpected error from API');
      print('   Status: ${response.statusCode}');
      print('   Response: ${response.body.substring(0, 200)}');
      return false;
    }
  } catch (e) {
    print('❌ Connection error: $e');
    return false;
  }
}

Future<bool> _testJsonGeneration(String apiKey) async {
  try {
    const baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
    const model = 'llama-3.3-70b-versatile';

    final prompt = '''
Generate a simple JSON response with this exact structure:
{
  "test": "value",
  "status": "success"
}

Return ONLY the JSON, no other text.
''';

    final request = {
      'model': model,
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'max_tokens': 100,
      'temperature': 0.3,
      'response_format': {'type': 'json_object'},
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(request),
    ).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Request timed out'),
    );

    if (response.statusCode != 200) {
      print('❌ API returned error: ${response.statusCode}');
      print('   Response: ${response.body}');
      return false;
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final content = data['choices']?[0]?['message']?['content']?.toString() ?? '';

    if (content.isEmpty) {
      print('❌ API returned empty content');
      return false;
    }

    print('✅ Successfully received JSON response from API');
    print('   Content: $content');

    // Verify it's valid JSON
    try {
      jsonDecode(content);
      print('✅ Response is valid JSON');
      return true;
    } catch (e) {
      print('⚠️ Response is not valid JSON: $e');
      print('   Content: $content');
      return false;
    }
  } catch (e) {
    print('❌ Error testing JSON generation: $e');
    return false;
  }
}
