# Quick Start Guide

## 5-Minute Setup

### Step 1: Install Dependencies
```bash
cd c:\Users\Tahsan\StudioProjects\piaget
flutter pub get
```

### Step 2: Get Groq API Key
1. Go to https://console.groq.com
2. Sign up (free account)
3. Create API key
4. Copy the key

### Step 3: Configure Environment
```bash
# Edit .env file in project root
GROQ_API_KEY=paste_your_api_key_here
```

### Step 4: Run the App
```bash
flutter run
```

## App Flow

```
Start App
    ↓
Role Selection (Teacher/Parent/Student)
    ↓
Login (Enter Name)
    ↓
Dashboard (Setup Learner Profile)
    ↓
Assessment (Answer Questions)
    ↓
Results (View Report)
```

## User Journeys

### Teacher Journey
1. Select "Teacher" role
2. Enter teacher name
3. Enter learner name and age
4. Start assessment
5. View student's cognitive stage
6. Get teaching recommendations

### Parent Journey
1. Select "Parent" role
2. Enter parent name
3. Enter child's name and age
4. Start assessment
5. View child's development areas
6. Get activity suggestions

### Student Journey
1. Select "Student" role
2. Enter student name
3. Enter own age
4. Complete self-assessment
5. View personal report
6. Get learning recommendations

## Key Features

### Assessment Types
- **Yes/No Questions**: Quick cognitive checks
- **Multiple Choice**: Select from options
- **Short Answer**: Open-ended responses

### Results Include
- Overall performance score (0-100%)
- Identified cognitive stage
- Strengths identified
- Development areas
- Personalized activity suggestions

### Cognitive Stages
| Stage | Age Range | Type |
|-------|-----------|------|
| Sensorimotor | 0-2 | Learning through senses |
| Preoperational | 2-7 | Symbolic but illogical |
| Concrete Operational | 7-11 | Logical about real objects |
| Formal Operational | 11+ | Abstract & hypothetical |

## File Locations

**Configuration**:
- `.env` - API key and settings

**Main Code**:
- `lib/main.dart` - App entry point
- `lib/screens/` - UI screens
- `lib/providers/` - State management
- `lib/services/` - Business logic
- `lib/models/` - Data structures

**Documentation**:
- `SETUP_GUIDE.md` - Complete setup
- `GROQ_API_GUIDE.md` - API details
- `PRODUCTION_CHECKLIST.md` - Release checklist

## Common Issues & Solutions

### Issue: ".env not found"
**Solution**: Ensure `.env` file is in project root directory

### Issue: "GROQ_API_KEY not configured"
**Solution**: Add your API key to `.env` and restart app

### Issue: Assessment questions not showing
**Solution**: Check that age is set correctly (0-18)

### Issue: API timeout error
**Solution**: Check internet connection, verify API key

## Testing

### Test as Teacher
1. Role: Teacher
2. Name: "John Smith"
3. Learner: "Emma Jones", Age: 8
4. Complete assessment
5. View results

### Test as Parent
1. Role: Parent
2. Name: "Jane Doe"
3. Child: "Tommy", Age: 6
4. Complete assessment
5. Get activity suggestions

### Test as Student
1. Role: Student
2. Name: "Sarah"
3. Age: 10
4. Complete assessment
5. View personal report

## Performance Tips

- First assessment may take slightly longer (API setup)
- Subsequent assessments are faster
- Internet connection required for suggestions
- Works with 2G+ mobile connection

## What's Included

- ✓ Complete Flutter app source code
- ✓ State management with Provider
- ✓ Beautiful UI with gradients
- ✓ 10+ Piagetian-based questions
- ✓ Automatic scoring system
- ✓ Groq AI integration
- ✓ Responsive design
- ✓ Error handling
- ✓ Multi-role support
- ✓ Comprehensive documentation

## What You Need to Add

- ✓ Groq API key (free at https://console.groq.com)
- Optional: Backend database (Firebase, Supabase, etc.)
- Optional: Authentication system
- Optional: Analytics

## Next Steps

1. ✓ Install and run the app
2. ✓ Test with sample assessments
3. ? Add more questions to question bank
4. ? Integrate with database
5. ? Deploy to app stores

## Getting Help

- **Flutter Issues**: https://flutter.dev/docs
- **Groq API**: https://console.groq.com/docs
- **Provider Package**: https://pub.dev/packages/provider

## Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Hot Reload | r |
| Hot Restart | R |
| Quit | q |
| Show Help | h |

## Development Commands

```bash
# Run app
flutter run

# Run in debug mode
flutter run -v

# Run on specific device
flutter devices
flutter run -d <device_id>

# Build release
flutter build apk --release

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Tips for Best Results

1. **Age Accuracy**: Enter accurate learner age for better assessment
2. **Quiet Environment**: Minimize distractions during assessment
3. **Careful Reading**: Take time to read questions
4. **Honest Answers**: Provide genuine responses for accurate results
5. **Review Results**: Study recommendations and suggested activities

## Success Metrics

After successful setup:
- ✓ App loads without errors
- ✓ Role selection works
- ✓ Login completes successfully
- ✓ Assessment questions display
- ✓ Results show with score and recommendations
- ✓ Navigation between screens is smooth

## Support & Feedback

For issues or suggestions:
1. Check documentation files
2. Review error messages
3. Check Groq API status
4. Verify environment variables

---

**Happy Testing! 🎉**

Your MindTrack app is ready to assess cognitive development!
