# Quick Fix: Groq API Not Working

## The Problem
Your app shows static predefined questions instead of generating dynamic questions using Groq AI.

## The Root Cause
The Groq API is either:
1. ❌ Not configured (missing/invalid API key in `.env`)
2. ❌ Not reachable (network/firewall issue)
3. ❌ Rate limited (too many requests)
4. ❌ Having temporary issues

## Quick 5-Minute Fix

### 1️⃣ Check Your API Key (30 seconds)
Open `.env` in the project root:
```
GROQ_API_KEY=gsk_YOUR_ACTUAL_API_KEY_HERE
```

✅ **Should have:** `gsk_` prefix and long alphanumeric string
❌ **Should NOT have:** `your_groq_api_key_here` or empty value

If empty or wrong, get a new key:
- Go to https://console.groq.com
- Create/copy your API key
- Paste it in `.env`

### 2️⃣ Verify Network Connection (1 minute)
Run this in terminal to test if Groq API is reachable:
```bash
curl https://api.groq.com/openai/v1/chat/completions
```
Should get a response (even if it's an auth error) - means the API is reachable.

### 3️⃣ Clean & Rebuild (2 minutes)
```bash
flutter clean
flutter pub get
flutter run
```

### 4️⃣ Test by Starting Assessment
1. Open app
2. Go to Dashboard
3. Enter learner name and age
4. Click "Start Assessment"
5. **Watch the debug console** (bottom of VS Code / Android Studio)

## What To Look For in Debug Logs

### ✅ Success:
```
🤖 Starting AI question generation for stage: Preoperational
✅ Groq service initialized successfully
📤 Sending request to Groq API (attempt 1)...
📥 Received response from Groq API (attempt 1)
✅ Parsed 10 valid questions
✨ Successfully generated 10 unique questions!
```
→ **You're done! Questions should now be dynamic**

### ❌ Failure:
```
❌ Failed to initialize Groq service: GROQ_API_KEY not found
```
→ **Fix:** Check `.env` file exists and has valid key

```
❌ Groq error 401: Invalid authentication credentials
```
→ **Fix:** Your API key is wrong. Get a new one from Groq console

```
❌ Groq error 429: Rate limit exceeded
```
→ **Fix:** Wait 5 minutes or upgrade Groq account

```
❌ Groq API request timed out
```
→ **Fix:** Check internet connection or Groq API status

## Advanced: Run Diagnostic Test

If above doesn't work, run:
```bash
dart run test/groq_diagnostic.dart
```

This will test:
- ✅ .env loading
- ✅ API key presence
- ✅ Network connectivity
- ✅ Groq API response

## Still Not Working?

Check:
1. **Internet connection** - Can you browse websites?
2. **Firewall** - Does your network allow HTTPS to api.groq.com?
3. **API Key validity** - Test it here: https://console.groq.com/playground
4. **Rate limits** - Check if you hit limits: https://console.groq.com/usage

## Expected Behavior After Fix

- ✅ First time assessment takes **5-10 seconds** to generate questions
- ✅ Questions are **different each time**
- ✅ Questions match **Piaget stages** for the learner's age
- ✅ Questions cover different cognitive criteria (conservation, animism, etc.)
- ✅ No more static/predefined questions

## Questions Still Static?

1. Make sure you **restarted the app** after changing `.env`
2. Check debug logs for errors (scroll to top of console)
3. If no errors appear, the issue is likely rate limiting - wait and try again

---

**Need help?** Check `GROQ_DEBUG_GUIDE.md` for detailed troubleshooting.
