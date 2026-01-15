# MindTrack Configuration Notes

## Before Running - IMPORTANT

### 1. Environment Variable Setup
**File**: `.env` (in project root)

```env
GROQ_API_KEY=your_actual_groq_api_key_here
```

**How to get API key**:
1. Visit https://console.groq.com
2. Create account (free)
3. Go to "API Keys" section
4. Create new key
5. Copy and paste into `.env`

### 2. Dependencies Installation
```bash
cd c:\Users\Tahsan\StudioProjects\piaget
flutter pub get
```

This will install:
- provider (state management)
- http (API calls)
- flutter_dotenv (environment variables)
- uuid (ID generation)
- And more...

### 3. Verify Setup

**Run these commands**:
```bash
# Check Flutter version
flutter --version

# Check if device is connected
flutter devices

# Verify dependencies
flutter pub get
```

## File Locations

| File | Purpose | Location |
|------|---------|----------|
| `.env` | API Key | Project root |
| `main.dart` | App entry | `lib/main.dart` |
| `pubspec.yaml` | Dependencies | Project root |
| `QUICK_START.md` | Quick guide | Project root |

## Critical Setup Steps

### Step 1: Add API Key
```bash
# Edit .env in project root
GROQ_API_KEY=your_key_here
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Run App
```bash
flutter run
```

## Troubleshooting Before Running

### Error: "GROQ_API_KEY not found"
- Check `.env` file exists in project root
- Check file contains: `GROQ_API_KEY=your_key`
- Restart Flutter app after changes

### Error: "Command 'flutter' not found"
- Add Flutter to PATH environment variable
- Restart terminal/IDE
- Or use full path: `/path/to/flutter/bin/flutter`

### Error: "No connected devices"
- Connect physical device via USB, or
- Use Android emulator: `emulator -avd YourEmulator`
- Use iOS simulator: `open -a Simulator`

### Error: "Dependencies not found"
```bash
flutter clean
flutter pub get
flutter run
```

## App Navigation Flow

```
┌─────────────────────────────┐
│  App Start                   │
└────────────┬────────────────┘
             ↓
┌──────────────────────────────┐
│  Role Selection              │
│  (Teacher/Parent/Student)    │
└────────────┬─────────────────┘
             ↓
┌──────────────────────────────┐
│  Login (Enter Name)          │
└────────────┬─────────────────┘
             ↓
┌──────────────────────────────┐
│  Dashboard (Learner Setup)   │
│  (Name, Age, Class)          │
└────────────┬─────────────────┘
             ↓
┌──────────────────────────────┐
│  Assessment (10 Questions)   │
│  (Yes/No, MC, Short Answer)  │
└────────────┬─────────────────┘
             ↓
┌──────────────────────────────┐
│  Results (Report & Stats)    │
│  (Score, Stage, Activities)  │
└─────────────────────────────┘
```

## Key Features Overview

### Assessment Types
1. **Yes/No Questions**: Binary choice
2. **Multiple Choice**: Select from 3-4 options
3. **Short Answer**: Free text response

### Cognitive Stages
| Age | Stage | Type |
|-----|-------|------|
| 0-2 | Sensorimotor | Learning through senses |
| 2-7 | Preoperational | Symbolic but illogical |
| 7-11 | Concrete Operational | Logical about objects |
| 11+ | Formal Operational | Abstract thinking |

### Result Components
- Overall score (0-100%)
- Identified stage
- Strengths (areas of excellence)
- Development areas (improvement zones)
- Activity suggestions

## Testing the Complete Flow

### Test as Teacher
1. **Role**: Select "Teacher"
2. **Login**: Enter "Mr. Smith"
3. **Learner**: Name "Emma", Age "8"
4. **Assessment**: Answer 10 questions
5. **Results**: View cognitive stage & recommendations

### Test as Parent
1. **Role**: Select "Parent"
2. **Login**: Enter "Jane Doe"
3. **Child**: Name "Tommy", Age "6"
4. **Assessment**: Complete questionnaire
5. **Results**: Get activity suggestions

### Test as Student
1. **Role**: Select "Student"
2. **Login**: Enter your name
3. **Profile**: Enter your age
4. **Assessment**: Self-assessment
5. **Results**: Personal development report

## Performance Expectations

| Operation | Time |
|-----------|------|
| App startup | 2-3 seconds |
| Role selection | Instant |
| Login | <1 second |
| Dashboard load | <1 second |
| First question | <1 second |
| API suggestion (Groq) | 1-2 seconds |
| Results display | <1 second |
| Total assessment time | 5-10 minutes |

## Network Requirements

- **Internet**: Required for Groq API calls
- **Speed**: 2G+ sufficient
- **Connection**: WiFi or mobile data
- **API Rate Limits**: 30 calls/min (free tier)

## Device Requirements

- **RAM**: 2GB+ recommended
- **Storage**: 50MB+ free space
- **OS**: Android 21+ or iOS 12+
- **Screen**: Any size (responsive design)

## Configuration Files

### `.env` Format
```env
# Environment variables
GROQ_API_KEY=paste_your_key_here

# Keep format exactly as above
# No quotes needed
# One line only
```

### `pubspec.yaml` Updated
All dependencies are already configured:
```yaml
dependencies:
  flutter: sdk: flutter
  provider: ^6.0.0
  http: ^1.1.0
  flutter_dotenv: ^5.1.0
  uuid: ^4.0.0
  # ... more dependencies
```

## Running on Different Platforms

### Android
```bash
flutter run -d android
# or via emulator
emulator -avd YourDevice
flutter run
```

### iOS
```bash
flutter run -d ios
# or via simulator
open -a Simulator
flutter run
```

### Web (if needed)
```bash
flutter run -d chrome
# or
flutter run -d firefox
```

## Code Organization

```
lib/
├── main.dart              ← Start here
├── config/               ← App settings
├── models/               ← Data structures
├── providers/            ← State management
├── screens/              ← UI screens
├── services/             ← Business logic
├── utils/                ← Helpers
└── widgets/              ← Reusable components
```

## Common Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Run with verbose output
flutter run -v

# Hot reload (press 'r' in terminal)
# Hot restart (press 'R' in terminal)

# Build release
flutter build apk --release
flutter build ios --release

# Check devices
flutter devices

# Clean project
flutter clean
```

## Verification Checklist

- [ ] `.env` file created with API key
- [ ] `flutter pub get` completed successfully
- [ ] Connected device appears in `flutter devices`
- [ ] `flutter run` starts without errors
- [ ] App loads with role selection screen
- [ ] Can select role and login
- [ ] Assessment questions display
- [ ] Results show after completing questions
- [ ] All navigation works smoothly

## Quick Commands Reference

```bash
# One-liner setup
flutter pub get && flutter run

# Check everything
flutter doctor -v

# Run and watch for changes
flutter run --debug

# Kill running instances
flutter kill

# Start clean
flutter clean && flutter pub get && flutter run
```

## Support Quick Links

- **Flutter**: https://flutter.dev
- **Groq API**: https://console.groq.com
- **Provider**: https://pub.dev/packages/provider
- **Piaget Info**: https://www.simply.education/piaget

## Next Steps

1. ✓ Read this document
2. ✓ Add Groq API key to `.env`
3. ✓ Run `flutter pub get`
4. ✓ Run `flutter run`
5. ✓ Test the app
6. ? Add more questions
7. ? Connect to backend
8. ? Deploy to app stores

---

**Ready to run?**

```bash
# Final setup
flutter pub get

# Launch the app
flutter run
```

**Enjoy using MindTrack! 🎉**
