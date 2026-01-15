# MindTrack Architecture & Design

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter UI Layer                         │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐ │
│  │ Auth Screens │  │ Dashboard    │  │ Assessment       │ │
│  │ - Role Sel   │  │ - Learner    │  │ - Questions      │ │
│  │ - Login      │  │ - Profile    │  │ - Answers        │ │
│  └──────────────┘  └──────────────┘  └──────────────────┘ │
│  ┌──────────────────────────────────────────────────────┐  │
│  │         Results Screen - Reporting & Analytics      │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│               State Management Layer (Provider)             │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────────────┐  ┌─────────────────────────────┐ │
│  │  AuthProvider        │  │  AssessmentProvider         │ │
│  │  - User state        │  │  - Current session          │ │
│  │  - Role management   │  │  - Responses                │ │
│  │  - Login status      │  │  - Evaluations              │ │
│  │                      │  │  - Results                  │ │
│  └──────────────────────┘  └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                  Service Layer                              │
├─────────────────────────────────────────────────────────────┤
│  ┌────────────────────────┐  ┌──────────────────────────┐  │
│  │ AssessmentService      │  │ GroqService              │  │
│  │ - Question Bank        │  │ - API Integration        │  │
│  │ - Scoring Logic        │  │ - Response Evaluation    │  │
│  │ - Stage Mapping        │  │ - Suggestion Generation  │  │
│  │ - Result Generation    │  │ - Prompt Engineering     │  │
│  └────────────────────────┘  └──────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│                   Data Models                               │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐ ┌──────────────┐ ┌────────────────────┐ │
│  │ UserModel    │ │ CognitiveStg │ │ AssessmentModel    │ │
│  │ - UserProfile│ │ - Stages     │ │ - Question         │ │
│  │ - LearnerPrf │ │ - Indicators │ │ - Response         │ │
│  └──────────────┘ └──────────────┘ │ - Evaluation       │ │
│                                     │ - Result           │ │
│                                     │ - Session          │ │
│                                     └────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              External Services & APIs                       │
├─────────────────────────────────────────────────────────────┤
│              ┌──────────────────────────────┐               │
│              │   Groq API (mixtral-8x7b)    │               │
│              │ - Free tier: 30 calls/min    │               │
│              │ - Max: 1024 tokens/request   │               │
│              │ - Response time: 1-2 sec     │               │
│              └──────────────────────────────┘               │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow Architecture

### Assessment Data Flow
```
User Input
    ↓
LearnerProfile Created
    ↓
Age-based Stage Mapping
    ↓
Questions Loaded (Stage-specific)
    ↓
Question Displayed
    ↓
User Answer
    ↓
Response Recorded (Time, Answer)
    ↓
Criterion Evaluation
    ↓
Score Calculated
    ↓
Status Determined (Achieved/Developing/Not Yet)
    ↓
Loop (Next Question)
    ↓
Assessment Complete
    ↓
Result Aggregation
    ↓
API: Generate Suggestions
    ↓
Report Displayed
```

## Screen Navigation Flow

```
                          ┌─────────────────────────┐
                          │   App Initialization    │
                          └────────────┬────────────┘
                                       ↓
                    ┌──────────────────────────────────┐
                    │    Is User Authenticated?        │
                    └────────────┬─────────────────────┘
                          YES ↙           ↘ NO
                             ↓             ↓
                    ┌─────────────────┐  ┌──────────────────────┐
                    │   Dashboard     │  │  Role Selection      │
                    │   Screen        │  │  Screen              │
                    └────────┬────────┘  └──────────┬───────────┘
                             ↓                      ↓
                ┌────────────────────────┐  ┌──────────────────┐
                │ Start Assessment       │  │   Login Screen   │
                │ (Setup Learner)        │  │   (Enter Name)   │
                └────────────┬───────────┘  └────────┬─────────┘
                             ↓                       ↓
                ┌────────────────────────────────────┘
                ↓
        ┌──────────────────────┐
        │ Assessment Screen    │
        │ (Answer Questions)   │
        └────────────┬─────────┘
                     ↓
        ┌──────────────────────┐
        │  Is Assessment Done? │
        └───┬──────────────┬───┘
            │ NO           │ YES
            ↓              ↓
        ┌─────────┐   ┌──────────────┐
        │Next Qst │   │Results Screen│
        └─────────┘   │(Report)      │
                      └────────┬─────┘
                               ↓
                      ┌────────────────────┐
                      │ New Assessment or  │
                      │ Back to Dashboard  │
                      └────────────────────┘
```

## Component Hierarchy

```
MyApp
├── MultiProvider
│   ├── AuthProvider
│   └── AssessmentProvider
│
└── MaterialApp
    ├── Theme Configuration
    │
    ├── Home: _AppNavigator
    │   └── Conditional Navigation
    │       ├── If NOT authenticated
    │       │   └── RoleSelectionScreen
    │       │
    │       └── If authenticated
    │           └── DashboardScreen
    │
    ├── Routes:
    │   ├── /role → RoleSelectionScreen
    │   ├── /login → LoginScreen
    │   ├── /dashboard → DashboardScreen
    │   ├── /assessment → AssessmentScreen
    │   └── /results → ResultsScreen
    │
    ├── RoleSelectionScreen
    │   ├── _RoleCard (Teacher)
    │   ├── _RoleCard (Parent)
    │   └── _RoleCard (Student)
    │
    ├── AssessmentScreen
    │   ├── AppBar with Progress
    │   ├── LinearProgressIndicator
    │   │
    │   └── PageView
    │       └── _QuestionWidget
    │           ├── _YesNoResponse
    │           ├── _MultipleChoiceResponse
    │           ├── _ShortAnswerResponse
    │           └── _AnswerButton
    │
    └── ResultsScreen
        ├── GradientCard (Score)
        ├── Container (Stage)
        ├── Container (Strengths)
        ├── Container (Development Areas)
        ├── Container (Activities)
        └── Buttons (Actions)
```

## State Management Pattern

```
┌──────────────────────────────────────────────────────┐
│           Widget Layer                               │
│  (Screens & Widgets)                                │
└────────────────┬─────────────────────────────────────┘
                 │ Listen
                 ↓
┌──────────────────────────────────────────────────────┐
│           Provider Layer                             │
│  ┌────────────────────┐  ┌─────────────────────────┐│
│  │ AuthProvider       │  │ AssessmentProvider      ││
│  │ - currentUser      │  │ - currentSession        ││
│  │ - isAuthenticated  │  │ - currentLearner        ││
│  │ - selectedRole     │  │ - responses             ││
│  └────────────────────┘  │ - evaluations           ││
│                          │ - lastResult            ││
│                          └─────────────────────────┘│
└────────────────┬────────────────────────────────────┘
                 │ Notify
                 ↓
┌──────────────────────────────────────────────────────┐
│           Service Layer                              │
│  (Business Logic & API)                             │
└────────────────┬────────────────────────────────────┘
                 │ Execute
                 ↓
┌──────────────────────────────────────────────────────┐
│           Data Models                                │
│  (UserModel, AssessmentModel, CognitiveStage)       │
└──────────────────────────────────────────────────────┘
```

## Cognitive Assessment Algorithm

```
1. INPUT: Learner Age
        ↓
2. MAP: Age → Cognitive Stage
        ↓
3. LOAD: Stage-specific questions
        ↓
4. LOOP: For each question
    ├─ Display question
    ├─ Record response
    ├─ Time response
    ├─ Apply scoring rules
    ├─ Calculate score
    └─ Determine status
        ↓
5. AGGREGATE: All criterion scores
        ↓
6. DETERMINE: Overall stage match
        ↓
7. CLASSIFY: 
    ├─ Strengths (Achieved)
    ├─ Developing (Developing)
    └─ Areas to improve (Not Yet)
        ↓
8. GENERATE: Suggestions via API
        ↓
9. OUTPUT: Assessment Result
```

## Scoring System

```
Raw Response
        ↓
Apply Scoring Rules
        ↓
Calculate Score (0-100)
        ↓
Determine Status:
    ├─ 80-100: Achieved ✓
    ├─ 50-79:  Developing ~
    └─ 0-49:   Not Yet ✗
        ↓
Generate Feedback
        ↓
Add to Evaluations List
```

## Dependencies & Libraries

```
Flutter Application
├── State Management
│   └── provider: ^6.0.0
├── Networking
│   └── http: ^1.1.0
├── Environment
│   └── flutter_dotenv: ^5.1.0
├── Utilities
│   ├── uuid: ^4.0.0
│   └── intl: ^0.19.0
├── UI Extras
│   └── url_launcher: ^6.2.0
└── System
    └── cupertino_icons: ^1.0.8
```

## File Organization

```
lib/
├── Entry Point
│   └── main.dart ← Start here
│
├── Configuration
│   ├── config/constants.dart
│   └── config/theme.dart
│
├── Data Layer
│   ├── models/user_model.dart
│   ├── models/assessment_model.dart
│   └── models/cognitive_stage.dart
│
├── Business Logic
│   ├── services/assessment_service.dart
│   └── services/groq_service.dart
│
├── State Management
│   ├── providers/auth_provider.dart
│   └── providers/assessment_provider.dart
│
├── Presentation
│   ├── screens/auth/
│   ├── screens/dashboard/
│   ├── screens/assessment/
│   ├── screens/results/
│   ├── widgets/custom_widgets.dart
│   └── utils/helpers.dart
```

## API Integration Pattern

```
Widget → Provider → Service → API
                ↓
         Groq API Call
                ↓
         JSON Response
                ↓
    Parse & Create Models
                ↓
        Update Provider State
                ↓
      Notify Listeners (Widgets)
                ↓
      UI Updates with New Data
```

## Error Handling Flow

```
Operation Attempted
        ↓
Try Block
    ├─ Execute operation
    ├─ Check response
    └─ Parse data
        ↓
Catch Block
    ├─ Identify error type
    ├─ Log error
    └─ Get error message
        ↓
Show User Error
    ├─ Toast/Snackbar
    ├─ Dialog
    └─ Error screen
        ↓
Allow Retry or Go Back
```

## User Authentication Flow

```
Start App
    ↓
Check isAuthenticated
    ├─ TRUE  → Show Dashboard
    └─ FALSE → Show Role Selection
            ↓
    Select Role (setUserRole)
            ↓
    Navigate to Login
            ↓
    Enter Name & Email
            ↓
    Login (authProvider.login)
            ↓
    Set isAuthenticated = TRUE
            ↓
    Navigate to Dashboard
            ↓
    User is logged in ✓
```

## Assessment Complete Flow

```
Last Question Answered
            ↓
recordResponse() called
            ↓
completeAssessment() triggered
            ↓
Generate AssessmentResult:
    ├─ Aggregate scores
    ├─ Determine stage
    ├─ Identify strengths
    ├─ Identify dev areas
    └─ Generate suggestions
            ↓
Navigate to Results Screen
            ↓
Display comprehensive report
            ↓
Offer options:
    ├─ New Assessment
    └─ Back to Dashboard
```

---

**Architecture follows SOLID principles and clean code practices for maintainability and scalability.**
