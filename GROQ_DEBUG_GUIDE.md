# Groq API Integration Debug Guide

## Issue: App shows static questions instead of Groq-generated questions

If your Piaget assessment app is displaying static predefined questions instead of dynamically generating them using the Groq API, follow these steps to diagnose and fix the problem.

---

## Step 1: Verify .env Configuration

### Check if .env file exists
```bash
# In the project root, verify .env file exists
ls -la .env
```

### Verify GROQ_API_KEY is set
```bash
# View the .env file content (with key hidden)
cat .env | grep GROQ_API_KEY
# Output should show: GROQ_API_KEY=gsk_...
```

### Get a valid Groq API Key
1. Go to [https://console.groq.com](https://console.groq.com)
2. Sign up or login
3. Navigate to API Keys section
4. Create a new API key
5. Copy the key
6. Update your `.env` file:
   ```
   GROQ_API_KEY=your_new_key_here
   ```

---

## Step 2: Run Diagnostic Test

### Option A: Run diagnostic in Dart
```bash
dart run test/groq_diagnostic.dart
```

This will test:
- ✅ .env file loading
- ✅ API key presence
- ✅ Network connectivity to Groq API
- ✅ JSON response generation

### Option B: Manual API Test (cURL)
```bash
# Replace YOUR_API_KEY with your actual Groq API key
curl -X POST https://api.groq.com/openai/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "model": "mixtral-8x7b-32768",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 10
  }'
```

Expected response should have status 200 with model output.

---

## Step 3: Clean & Rebuild the App

```bash
# Clean Flutter build
flutter clean

# Remove build artifacts
rm -rf build/
rm -rf .dart_tool/

# Get fresh dependencies
flutter pub get

# Run the app
flutter run
```

---

## Step 4: Check Debug Logs

While the app is running and attempting to generate questions, watch the console output for these debug messages:

### Success indicators:
```
🤖 Starting AI question generation for stage: Preoperational
🔧 Initializing Groq service (attempt 1)...
✅ Groq service initialized successfully
📤 Sending request to Groq API (attempt 1)...
📥 Received response from Groq API (attempt 1)
✅ Parsed 10 valid questions
✨ Successfully generated 10 unique questions!
```

### Error indicators to look for:
```
❌ Failed to initialize Groq service: GROQ_API_KEY not found
❌ Failed to initialize Groq service: GROQ_API_KEY is empty
❌ Groq error 401: Invalid authentication credentials
❌ Groq error 429: Rate limit exceeded
❌ Groq API request timed out
```

---

## Step 5: Common Issues & Solutions

### Issue 1: GROQ_API_KEY not found
**Symptoms:** Debug message shows "GROQ_API_KEY not found in environment variables"

**Solution:**
1. Verify `.env` file exists in project root (not in lib/)
2. Verify file format: `GROQ_API_KEY=gsk_...` (no spaces around `=`)
3. Make sure `pubspec.yaml` includes `.env` in assets:
   ```yaml
   flutter:
     uses-material-design: true
     assets:
       - .env
   ```
4. Restart the app: `flutter clean && flutter run`

### Issue 2: API Key Invalid (401 error)
**Symptoms:** Debug shows "Groq error 401: Invalid authentication credentials"

**Solution:**
1. Get a new API key from [https://console.groq.com](https://console.groq.com)
2. Check for hidden spaces or line breaks in `.env`
3. Make sure key starts with `gsk_`
4. Update `.env` and restart app

### Issue 3: Rate Limit (429 error)
**Symptoms:** Debug shows "Groq error 429: Rate limit exceeded"

**Solution:**
- The Groq free tier has usage limits
- Wait a few minutes before retrying
- Consider upgrading your Groq account for higher limits

### Issue 4: Timeout (>30 seconds with no response)
**Symptoms:** App hangs or debug shows "request timed out"

**Solution:**
1. Check your internet connection
2. Verify you can reach `https://api.groq.com`
3. Check if Groq API is up: [https://status.groq.com](https://status.groq.com)
4. Try the diagnostic test

### Issue 5: Invalid JSON response
**Symptoms:** Debug shows "Unable to parse...JSON from Groq response"

**Solution:**
- This is usually temporary
- The app will retry up to 3 times with adjusted temperature settings
- If it persists, contact Groq support

---

## Step 6: Force Debug Output

To ensure you see all debug messages, add this to your `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable verbose logging
  debugPrintBeginLine = true;
  debugPrintEndLine = true;
  
  // ... rest of main()
}
```

---

## Step 7: Verify Questions are Dynamic

To confirm questions are being generated dynamically:

1. Start the assessment 2-3 times
2. You should see **different questions** each time
3. Check debug logs for "Generating X questions"
4. Each question should have different text but aligned to Piaget stages

### Expected question characteristics:
- **Preoperational (3-7 years):** Questions about conservation, animistic thinking, egocentrism
- **Concrete Operational (7-11 years):** Questions about logic, classification, transitive inference
- **Formal Operational (11+ years):** Questions about abstract reasoning and hypothetical thinking

---

## Still Having Issues?

### Collect diagnostic information:
1. Run `flutter doctor` and share output
2. Share relevant debug log messages
3. Verify your Groq API key works with the diagnostic test
4. Check your network allows outbound HTTPS to `api.groq.com`

### Contact Groq Support
If API issues persist, contact: [https://support.groq.com](https://support.groq.com)

---

## Files Modified
The following files were enhanced with better error logging:
- `lib/services/groq_service.dart` - Added detailed API call logging
- `lib/services/assessment_service.dart` - Added question generation diagnostics
- `test/groq_diagnostic.dart` - New diagnostic tool (run with `dart run test/groq_diagnostic.dart`)

