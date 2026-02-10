# MindTrack: Piaget Assessment System

A comprehensive Flutter-based cognitive assessment platform built on Piaget's theory of cognitive development. This system enables teachers and administrators to assess students' cognitive stages, track progress, and manage educational workflows.

## 🎯 Overview

MindTrack is a full-featured educational assessment platform that:
- Evaluates students based on Piaget's cognitive development stages
- Provides role-based access for Students, Teachers, and Administrators
- Tracks individual student progress over time
- Enables class management and student assignment
- Generates detailed assessment reports with developmental recommendations

## ✨ Key Features

### 👨‍🎓 Student Features
- Take adaptive cognitive assessments
- View personal progress and assessment history
- Track current cognitive stage and average scores
- Age-appropriate question generation
- Real-time feedback and results

### 👨‍🏫 Teacher Features
- Manage assigned students
- Create and organize classes
- Browse all students with multi-select capabilities
- View detailed student progress and assessment results
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

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.8.1+
- **Backend**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth with PKCE flow
- **State Management**: Provider
- **AI Integration**: Groq API (Llama models)
- **Database**: PostgreSQL with Row Level Security (RLS)
- **Storage**: Supabase Storage (for profile images)

## 📁 Project Structure

```
lib/
├── models/              # Data models (User, Assessment, Question)
├── providers/           # State management (Auth, Assessment)
├── screens/            
│   ├── auth/           # Login, Signup screens
│   ├── dashboard/      # Role-based dashboards (Admin, Teacher, Student)
│   └── teacher/        # Teacher-specific screens (Classes, Student Browser)
├── services/           # Supabase service, API integrations
├── widgets/            # Reusable UI components
└── utils/              # Helper functions, constants
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK (3.0.0 or higher)
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
   
   Create `.env` file in the root directory:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GROQ_API_KEY=your_groq_api_key
   ```

4. **Run the database schema**
   
   Execute the SQL schema in your Supabase SQL Editor (available in project documentation)

5. **Create admin account**
   
   In Supabase Dashboard → Authentication → Users:
   - Create user with email: `admin@gmail.com`
   - Set password: `admin000`
   - Auto-confirm the user
   - Create corresponding admin profile in database (see setup documentation)

6. **Run the application**
   ```bash
   flutter run
   ```

## 🔐 Default Credentials

**Admin Account:**
- Email: `admin@gmail.com`
- Password: `admin000`

*Note: Change these credentials after first login for security.*

## 🎓 Cognitive Stages

The system assesses students across Piaget's four cognitive development stages:

1. **Sensorimotor** (0-2 years)
2. **Preoperational** (2-7 years)
3. **Concrete Operational** (7-11 years)
4. **Formal Operational** (11+ years)

## 🔧 Recent Fixes & Enhancements

### Database & Security
- ✅ Fixed Row Level Security (RLS) policies using SECURITY DEFINER functions
- ✅ Resolved infinite recursion issue in admin authentication
- ✅ Implemented comprehensive RLS policies for all 7 database tables
- ✅ Added `get_user_role()` function to safely bypass RLS for role checks

### UI/UX Improvements
- ✅ Updated admin dashboard tab bar with modern pill-style indicator
- ✅ Grey container background with shadow effects matching login page
- ✅ Responsive card layouts with proper overflow handling
- ✅ Enhanced stat cards with emoji indicators

### Features
- ✅ Admin can view real-time statistics (students, teachers, assessments)
- ✅ Teacher can assign students and create classes
- ✅ Student browser with multi-select for bulk class creation
- ✅ Comprehensive progress tracking with stage identification
- ✅ Debug logging for better error tracking

## 📊 Database Schema

The platform uses PostgreSQL with the following main tables:

- `users` - Base user information with role-based access
- `students` - Extended student profiles with teacher assignments
- `teachers` - Teacher profiles with department info
- `admins` - Admin profiles with permission levels
- `assessment_sessions` - Individual assessment records
- `assessment_results` - Detailed results and analysis
- `student_progress` - Longitudinal progress tracking
- `classes` - Class/group management
- `class_members` - Student-class relationships

## 🤝 Contributing

This is an educational project. For major changes, please open an issue first to discuss proposed changes.

## 📝 License

This project is part of an educational initiative.

## 👥 Contact

For questions or support, please open an issue on GitHub.

## 🙏 Acknowledgments

- Built on Flutter framework
- Powered by Supabase backend
- AI assessments via Groq API
- Based on Jean Piaget's cognitive development theory
