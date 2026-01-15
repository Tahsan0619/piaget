# Groq API Integration Guide

## Overview

MindTrack uses the **Groq API** (free tier) to generate intelligent suggestions and evaluate responses based on Piaget's cognitive development theory.

## Getting Your Groq API Key

1. Visit https://console.groq.com
2. Sign up for a free account
3. Navigate to "API Keys" section
4. Create a new API key
5. Copy and paste it into your `.env` file

## Configuration

### Environment Setup

```bash
# In .env file
GROQ_API_KEY=your_api_key_here
```

The app automatically loads this during startup using `flutter_dotenv`.

## API Capabilities Used

### 1. Response Evaluation
Evaluates learner responses against cognitive criteria:

```dart
Future<Map<String, dynamic>> evaluateResponse(
  String criterion,
  String question,
  String learnerResponse,
  String stage,
) async
```

Example:
```
Criterion: Conservation
Stage: Preoperational
Question: "If I pour water from a tall glass into a short, wide glass, does the amount of water change?"
Response: "The short glass has less water because it's wider"
```

### 2. Suggestion Generation
Creates personalized learning activities:

```dart
Future<Map<String, dynamic>> generateSuggestions(
  String learnerAge,
  List<String> developmentAreas,
) async
```

Example Output:
```json
{
  "activities": [
    "Pour water between different shaped containers",
    "Play with clay and reshaping activities"
  ],
  "materials": [
    "Glass containers of various sizes",
    "Water or sand",
    "Measuring cups"
  ],
  "guidance": "Focus on concrete, hands-on experiments...",
  "tips": [
    "Use real objects, not pictures",
    "Let the child experiment freely"
  ]
}
```

## API Usage Limits

**Free Tier**:
- 30 API calls per minute
- 100 API calls per day
- Max 1024 tokens per request
- Response models: mixtral-8x7b-32768

The app is optimized to work within these limits.

## Implementation Examples

### Example 1: Evaluating a Response

```dart
final groqService = GroqService();

final evaluation = await groqService.evaluateResponse(
  criterion: 'Conservation',
  question: 'Does the water amount change?',
  learnerResponse: 'Yes, because the glass is wider',
  stage: 'Preoperational',
);

// Output:
// {
//   "status": "notYetAchieved",
//   "score": 30,
//   "reasoning": "Learner shows perceptual thinking...",
//   "feedback": "It's great that you're thinking about..."
// }
```

### Example 2: Generating Suggestions

```dart
final suggestions = await groqService.generateSuggestions(
  learnerAge: '8',
  developmentAreas: ['Conservation', 'Reversibility'],
);

// Output:
// {
//   "activities": [
//     "Reversibility game: Show a sequence of steps, then ask child to reverse them",
//     "Conservation experiments with different materials"
//   ],
//   "materials": ["Blocks", "Water", "Sand"],
//   "guidance": "Focus on concrete operations...",
//   "tips": ["Use real objects", "Provide feedback"]
// }
```

## Error Handling

The app gracefully handles API errors:

```dart
try {
  final response = await groqService.generateContent(prompt);
} catch (e) {
  // Fallback to predefined suggestions
  print('API Error: $e');
  // Show user-friendly error message
}
```

## Best Practices

### 1. Prompt Engineering
Prompts are carefully crafted to:
- Include context about Piaget's theory
- Specify output format (JSON)
- Provide clear evaluation criteria
- Request age-appropriate language

### 2. Rate Limiting
The app implements:
- Request caching where applicable
- Batch processing when possible
- Timeout handling (30 seconds default)

### 3. Fallbacks
If API is unavailable:
- Uses predefined response templates
- Shows generic suggestions
- Maintains app functionality

## Testing the Integration

### Test Setup

1. Add a test Groq API key to `.env`
2. Run the app
3. Complete an assessment
4. Check if suggestions are generated

### Debugging

Enable debug logging:

```dart
// In groq_service.dart, add print statements
print('Sending prompt to Groq...');
print('Response: $response');
```

## Monitoring Usage

Monitor your API usage at: https://console.groq.com/usage

## Advanced Features (Optional)

### Custom Evaluation Logic
You can extend the service with custom logic:

```dart
// In assessment_service.dart
// Combine Groq API with local scoring rules
final aiEvaluation = await groqService.evaluateResponse(...);
final localScore = calculateLocalScore(...);
final finalScore = (aiEvaluation['score'] + localScore) / 2;
```

### Caching Responses
Implement caching to reduce API calls:

```dart
class CachedGroqService {
  final Map<String, dynamic> _cache = {};
  
  Future<Map<String, dynamic>> generateSuggestions(...) async {
    final cacheKey = '$learnerAge-$developmentAreas';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }
    // Fetch from API and cache
  }
}
```

## Troubleshooting

### "GROQ_API_KEY not found"
- Check `.env` file exists in project root
- Verify file name and location
- Restart Flutter app after changes

### API calls timing out
- Check internet connection
- Verify API key is valid
- Check Groq API status at https://status.groq.com

### Rate limit exceeded
- Wait a few minutes before retrying
- Upgrade Groq plan for higher limits
- Implement caching to reduce calls

## API Documentation

For more information about Groq API:
- https://console.groq.com/docs
- https://groq.com/api-documentation

## Future Enhancements

1. **Streaming Responses**: Use streaming for faster feedback
2. **Custom Models**: Leverage Groq's fine-tuning capabilities
3. **Batch Processing**: Process multiple assessments in batches
4. **Analytics**: Track API usage patterns and costs

## Cost Estimation

**Free Tier**: No charge
- Perfect for development and testing
- Sufficient for most educational use cases

**Paid Tiers**: Available for higher volume
- Check Groq pricing at https://groq.com/pricing

## Support

For API issues:
- Visit https://console.groq.com/support
- Check status page: https://status.groq.com
- Review documentation: https://console.groq.com/docs
