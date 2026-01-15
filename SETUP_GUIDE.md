# MindTrack: Identifying Learning Stages with Piaget

A comprehensive Flutter application designed to assess the cognitive development stage of students based on Jean Piaget's theory of cognitive development.

## Features

- **Multi-Role Support**: Support for Teachers, Parents, and Students
- **Cognitive Assessment**: Interactive scenario-based questions inspired by Piaget's classic experiments
- **Stage Detection**: Automatic identification of cognitive development stages (Sensorimotor, Preoperational, Concrete Operational, Formal Operational)
- **Detailed Reports**: Comprehensive assessment results with:
  - Overall performance score
  - Identified cognitive stage
  - Strengths identification
  - Development areas
  - Personalized activity suggestions
- **AI-Powered Suggestions**: Groq API integration for intelligent feedback generation
- **Responsive UI**: Beautiful, intuitive interface with gradient backgrounds and smooth animations

## Project Structure

```
lib/
├── config/
│   ├── constants.dart         # App-wide constants
│   └── theme.dart             # Theme configuration
├── models/
│   ├── assessment_model.dart  # Assessment data models
│   ├── cognitive_stage.dart   # Cognitive stage enums and extensions
│   └── user_model.dart        # User profile models
├── providers/
│   ├── assessment_provider.dart # Assessment state management
│   └── auth_provider.dart       # Authentication state management
├── screens/
│   ├── assessment/
│   │   └── assessment_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── role_selection_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   └── results/
│       └── results_screen.dart
├── services/
│   ├── assessment_service.dart # Assessment logic and scoring
│   └── groq_service.dart       # Groq API integration
├── utils/
│   └── helpers.dart            # Utility functions
└── main.dart                   # App entry point
```

## Setup Instructions

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK (included with Flutter)
- Groq API key (get it from https://console.groq.com)

### Installation

1. **Clone or extract the project**:
   ```bash
   cd piaget
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables**:
   - Copy `.env.example` to `.env` in the project root
   - Add your Groq API key:
     ```
     GROQ_API_KEY=your_groq_api_key_here
     ```

4. **Run the application**:
   ```bash
   flutter run
   ```

### Dependencies

- **provider** (^6.0.0): State management
- **http** (^1.1.0): HTTP client for API calls
- **flutter_dotenv** (^5.1.0): Environment variable management
- **uuid** (^4.0.0): UUID generation
- **intl** (^0.19.0): Internationalization
- **url_launcher** (^6.2.0): URL launching

## User Roles

### Teacher
- Create and manage learner assessments
- View learner cognitive development stages
- Receive stage-specific teaching recommendations
- Track multiple learner progress

### Parent
- Assess their child's cognitive development
- Receive detailed developmental reports
- Get personalized activity suggestions
- Monitor learning progress

### Student
- Complete self-assessment questionnaires
- Receive immediate feedback on performance
- Get activity recommendations for development areas
- Track their own cognitive development

## Assessment Flow

1. **Role Selection**: User selects their role (Teacher, Parent, or Student)
2. **Login**: User provides their name and optional email
3. **Learner Profile Setup**: Enter learner name and age
4. **Assessment**: Interactive questions based on cognitive stage
5. **Results**: Comprehensive report with scores and recommendations

## Cognitive Stages Assessed

### Sensorimotor (0-2 years)
Learning through senses and actions. Indicators include:
- Object Permanence
- Cause-Effect Understanding
- Goal-Directed Behavior
- And more...

### Preoperational (2-7 years)
Symbolic but illogical thinking. Indicators include:
- Symbolic Thinking
- Egocentrism
- Centration
- And more...

### Concrete Operational (7-11 years)
Logical thinking about real objects. Indicators include:
- Conservation
- Reversibility
- Decentration
- And more...

### Formal Operational (11+ years)
Abstract and hypothetical thinking. Indicators include:
- Abstract Thinking
- Hypothetical Reasoning
- Metacognition
- And more...

## API Integration

### Groq API

The app uses Groq's free API for generating intelligent suggestions and evaluations:

```dart
// Example usage
final groqService = GroqService();
final suggestions = await groqService.generateSuggestions(
  learnerAge: '8',
  developmentAreas: ['Conservation', 'Reversibility'],
);
```

## Scoring System

Each response is evaluated using a rule-based scoring model:

- **Achieved (80-100)**: Expected reasoning level observed
- **Developing (50-79)**: Partial or inconsistent reasoning
- **Not Yet Achieved (0-49)**: Reasoning not aligned with stage expectation

## Assessment Output

The app generates three-layered results:

1. **Identified cognitive stage characteristics**
2. **Criteria-wise strengths and gaps**
3. **Suggested developmental activities**

## Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Architecture

- **State Management**: Provider pattern for clean state management
- **Service Layer**: Separation of business logic (AssessmentService, GroqService)
- **Model Layer**: Well-defined data models with JSON serialization
- **UI Layer**: Modular, reusable widgets and screens

## Error Handling

The app implements comprehensive error handling:
- Network error management
- Validation error messages
- Graceful fallbacks for API failures
- User-friendly error notifications

## Future Enhancements

- Teacher dashboard with learner management
- Data persistence with local database
- Export assessment reports as PDF
- Multi-language support
- Advanced analytics and progress tracking
- Parent-teacher collaboration features
- Gamification elements (badges, achievements)

## Contributing

For contributions, please follow these guidelines:
1. Create a feature branch
2. Make your changes
3. Ensure code quality
4. Submit a pull request

## License

This project is licensed under the MIT License.

## Contact

For questions and feedback, please contact the development team.

## Acknowledgments

- Jean Piaget's theory of cognitive development
- Flutter and Dart communities
- Groq API for AI capabilities
