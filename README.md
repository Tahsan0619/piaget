# MindTrack: Piaget Assessment System

A comprehensive Flutter-based cognitive assessment platform built on Piaget's theory of cognitive development. This system enables teachers and administrators to assess students' cognitive stages, track progress, and manage educational workflows.

## 🎯 Overview

MindTrack is a full-featured educational assessment platform that:
- Evaluates students based on Piaget's cognitive development stages
- Provides role-based access for Students, Teachers, and Administrators
- Tracks individual student progress over time
- Enables class management and student assignment
- Generates detailed PDF assessment reports with developmental recommendations
- Uses AI-powered evaluation for intelligent scoring and feedback

## ✨ Key Features

### 👨‍🎓 Student Features
- Take adaptive cognitive assessments
- View personal progress and assessment history
- Track current cognitive stage and average scores
- Age-appropriate question generation (ages 7–20)
- Real-time feedback and results
- Download/share PDF assessment reports

### 👨‍🏫 Teacher Features
- Manage assigned students
- Create and organize classes
- Browse all students with multi-select capabilities
- View detailed student progress and assessment results
- Download PDF reports for any student's assessment
- Assign students to classes
- Track class performance metrics

### 👨‍💼 Admin Features
- Complete system oversight dashboard
- User management (Students, Teachers, Admins)
- View system-wide statistics
- Toggle user active status
- Delete users
- Access all assessment data
- Monitor platform usage

---

## 🛠️ Tech Stack

### Frontend

| Technology | Purpose | Details |
|---|---|---|
| **Flutter 3.8.1+** | UI Framework | Cross-platform mobile/web/desktop framework using a single Dart codebase. Builds native Android APKs, iOS apps, and web deployments. |
| **Dart 3.8.1+** | Programming Language | Strongly-typed, null-safe language powering the entire client application. |
| **Provider 6.0** | State Management | Lightweight reactive state management using `ChangeNotifier`. Two main providers: `AuthProvider` (authentication, user sessions, dashboard stats) and `AssessmentProvider` (assessment lifecycle, question flow, results). |
| **Material Design 3** | Design System | Google's Material Design components with custom theming — gradient backgrounds, pill-style badges, card-based layouts, and responsive breakpoints. |
| **pdf / printing** | PDF Generation | Generates comprehensive A4 assessment reports client-side using the `pdf` package and shares/prints them via the `printing` package. |
| **flutter_dotenv** | Configuration | Loads environment variables (API keys, Supabase credentials) from a `.env` file at runtime. |
| **shared_preferences** | Local Storage | Persists user preferences and lightweight cached data locally on the device. |
| **image_picker** | Media Handling | Enables profile image selection from camera or gallery. |
| **intl** | Internationalization | Date/time formatting (e.g., `MMMM d, yyyy – h:mm a`) for assessment timestamps and report headers. |
| **url_launcher** | External Links | Opens external URLs from within the app. |

**Frontend Architecture:**
- **Screens**: Role-based dashboards (Student, Teacher, Admin), authentication screens (Login, Signup, Role Selection), assessment screen, and results screen.
- **Widgets**: Reusable animated components with slide/fade transitions.
- **Utils**: Responsive breakpoint utilities (`mobile`, `tablet`, `desktop`) for adaptive layouts.
- **Routing**: Named routes — `/role`, `/login`, `/dashboard`, `/assessment`, `/results`.

### Backend

| Technology | Purpose | Details |
|---|---|---|
| **Supabase** | Backend-as-a-Service | Provides the complete backend infrastructure — database, authentication, real-time subscriptions, and REST API — hosted at a managed cloud instance. |
| **PostgreSQL** | Database | Relational database powering all data storage. Accessed through Supabase's auto-generated REST API via the `supabase_flutter` client SDK. |
| **Supabase Auth** | Authentication | Email/password authentication with PKCE (Proof Key for Code Exchange) flow. Handles user signup, login, session persistence, and logout. Auto-links auth users to application roles. |
| **Row Level Security (RLS)** | Authorization | PostgreSQL RLS policies enforce data access at the database level. A `SECURITY DEFINER` function `get_user_role()` safely resolves user roles without recursion. Students see only their data; teachers see their assigned students; admins have full access. |
| **Supabase Storage** | File Storage | Cloud storage for user profile images. |
| **Database Views** | Computed Data | PostgreSQL views (`v_student_details`, `v_assessment_summary`) pre-join and aggregate data for efficient dashboard queries. |
| **Groq API** | AI Evaluation Engine | Calls the **Llama 3.3 70B Versatile** large language model via Groq's low-latency inference API. Evaluates student responses against Piagetian criteria, generates scores, identifies cognitive stages, and produces detailed developmental feedback. |
| **HTTP (REST)** | API Communication | All client-server communication happens over HTTPS — Supabase REST for CRUD operations, Groq REST API for AI inference. The `http` package handles direct API calls to Groq. |

**Database Schema:**

| Table | Purpose |
|---|---|
| `users` | Base user profiles with role (`student`, `teacher`, `admin`) |
| `students` | Extended student data — age, grade level, assigned teacher |
| `teachers` | Teacher profiles — department, subject specialization |
| `admins` | Admin profiles with permission levels |
| `assessment_sessions` | Individual assessment records with status and timing |
| `assessment_questions` | Questions presented during each session |
| `question_responses` | Student answers and AI evaluations per question |
| `assessment_results` | Final results — overall score, identified stage, strengths, recommendations |
| `student_progress` | Longitudinal progress tracking across assessments |
| `classes` | Teacher-created class groups |
| `class_members` | Student-to-class relationships |
| `notifications` | In-app notification records |
| `activity_logs` | System activity audit trail |

**Database Views:**

| View | Purpose |
|---|---|
| `v_student_details` | Joins `users` + `students` with aggregated assessment counts and average scores |
| `v_assessment_summary` | Joins sessions + results for quick assessment overview queries |

### Security

- **PKCE Authentication Flow** — Prevents authorization code interception attacks
- **Row Level Security** — Database-enforced access control per user role
- **Environment Variables** — API keys and secrets stored in `.env` (gitignored), never hardcoded
- **SHA-256 Hashing** — Available via `crypto` package for data integrity checks

---

## 📁 Project Structure

```
lib/
├── main.dart             # App entry point, route definitions, provider setup
├── config/               # App configuration constants
├── models/
│   ├── user_model.dart          # UserProfile, StudentProfile, TeacherProfile, AdminProfile, LearnerProfile
│   ├── assessment_model.dart    # Question, QuestionResponse, CriterionEvaluation, AssessmentResult, AssessmentSession
│   └── cognitive_stage.dart     # CognitiveStage enum with Piagetian stage definitions
├── providers/
│   ├── auth_provider.dart       # Authentication state, user sessions, dashboard stats
│   └── assessment_provider.dart # Assessment lifecycle, question flow, result management
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart          # Email/password login
│   │   ├── signup_screen.dart         # New user registration
│   │   └── role_selection_screen.dart # Role picker (Student, Teacher, Admin)
│   ├── dashboard/
│   │   ├── dashboard_screen.dart      # Main router — delegates to role dashboards
│   │   ├── student_dashboard.dart     # Student home — start assessment, view progress
│   │   ├── teacher_dashboard.dart     # Teacher home — students, classes, assessments, PDF reports
│   │   └── admin_dashboard.dart       # Admin home — system stats, user management
│   ├── teacher/
│   │   ├── student_browser_screen.dart # Browse/assign students with multi-select
│   │   └── classes_screen.dart         # Class management
│   └── results/
│       └── results_screen.dart        # Assessment results display with PDF download
├── services/
│   ├── supabase_service.dart    # All Supabase DB operations (singleton)
│   ├── groq_service.dart        # Groq LLM API client for AI evaluation
│   ├── assessment_service.dart  # Question bank and assessment session logic
│   └── pdf_service.dart         # PDF report generation and sharing
├── widgets/
│   └── animations.dart          # Reusable slide/fade animation widgets
└── utils/
    └── responsive.dart          # Responsive breakpoint utilities
```

## 🎓 Cognitive Stages

The system assesses students across Piaget's cognitive development stages:

1. **Concrete Operational** (7–11 years) — Logical thinking about concrete events, understanding conservation and classification
2. **Formal Operational** (11+ years) — Abstract reasoning, hypothetical thinking, systematic problem solving

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK (3.8.1 or higher)
- Supabase account
- Groq API key (for AI-powered assessments)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Tahsan0619/piaget.git
   cd piaget
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**

   Create a `.env` file in the root directory:
   ```env
   GROQ_API_KEY=your_groq_api_key
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Run the database schema**

   Execute the SQL schema in your Supabase SQL Editor (available in project documentation).

5. **Create admin account**

   In Supabase Dashboard → Authentication → Users:
   - Create user with email: `admin@gmail.com`
   - Set password: `admin000`
   - Auto-confirm the user
   - Create corresponding admin profile in the database

6. **Run the application**
   ```bash
   flutter run
   ```

## 🔐 Default Credentials

**Admin Account:**
- Email: `admin@gmail.com`
- Password: `admin000`

*Note: Change these credentials after first login for security.*

## 📝 License

This project is part of an educational initiative.

## 👥 Contact

For questions or support, please open an issue on GitHub.

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev) framework
- Powered by [Supabase](https://supabase.com) backend
- AI assessments via [Groq](https://groq.com) API (Llama 3.3 70B)
- Based on Jean Piaget's theory of cognitive development
