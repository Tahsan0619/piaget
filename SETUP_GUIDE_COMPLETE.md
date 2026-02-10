# MindTrack: Piaget Cognitive Assessment System

A comprehensive Flutter-based mobile application for cognitive assessment using Piaget's developmental theory. Designed for students, teachers, and administrators with full Supabase backend integration.

## ✨ Features

### 🎓 Student Features
- Complete cognitive assessments tailored to age
- Track personal learning progress
- View assessment history and results
- Monitor cognitive stage development
- Interactive learning activities

### 👨‍🏫 Teacher Features  
- Create and manage student accounts
- Conduct assessments for students
- Track student progress across cognitive stages
- View detailed analytics and reports
- Manage classes and groups
- Generate personalized learning recommendations

### 👑 Admin Features
- Complete system management
- User management (Students, Teachers, Admins)
- View system-wide analytics
- Monitor all assessments
- Activate/deactivate user accounts
- Access comprehensive reports

### 🔐 Authentication & Security
- Secure email/password authentication via Supabase
- Role-based access control (RBAC)
- Row-level security (RLS) policies
- Encrypted data transmission
- Session management

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.8.1 or higher)
  - Download from: https://flutter.dev/docs/get-started/install
- **Dart SDK** (comes with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Git**
- **Supabase Account** (free tier available)
  - Sign up at: https://supabase.com

### Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Tahsan0619/piaget.git
   cd piaget
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Supabase**

   a. Create a new project on [Supabase](https://supabase.com)
   
   b. Execute the SQL schema:
      - Open your Supabase project dashboard
      - Go to SQL Editor
      - Copy the entire content from `supabase_schema.sql`
      - Execute the SQL script
   
   c. Get your Supabase credentials:
      - Project URL: Found in Settings > API
      - Anon/Public Key: Found in Settings > API

4. **Configure Environment Variables**

   Create a `.env` file in the root directory:
   ```bash
   cp .env.example .env
   ```

   Edit `.env` and add your credentials:
   ```env
   # GROQ API Configuration (for AI features)
   GROQ_API_KEY=your_groq_api_key_here

   # Supabase Configuration
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your_supabase_anon_key_here
   ```

5. **Update Package Name (Optional but Recommended)**

   If you want to change the package name from the default:
   
   Edit `android/app/build.gradle.kts`:
   ```kotlin
   applicationId = "com.yourcompany.mindtrack"
   ```

### Running the App

#### For Development (Debug Mode)

```bash
# Run on connected Android device/emulator
flutter run

# Run with hot reload enabled
flutter run --hot
```

#### For Production (Release Mode)

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Install release APK on connected device
flutter install --release
```

The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

## 📱 Supported Platforms

- ✅ **Android** (Primary Target)
  - Minimum SDK: 21 (Android 5.0)
  - Target SDK: 34 (Android 14)
  - Tested on Android 8.0 - 14

## 🗂️ Project Structure

```
piaget/
├── lib/
│   ├── config/           # App configuration & theme
│   ├── models/           # Data models
│   ├── providers/        # State management (Provider)
│   ├── screens/          # UI screens
│   │   ├── auth/         # Login, signup, role selection
│   │   ├── dashboard/    # Role-specific dashboards
│   │   ├── assessment/   # Assessment screens
│   │   └── results/      # Results and analytics
│   ├── services/         # Backend services (Supabase)
│   ├── utils/            # Utility functions
│   └── widgets/          # Reusable widgets
├── android/              # Android-specific code
├── assets/               # Images, fonts, etc.
├── supabase_schema.sql   # Database schema
└── .env.example          # Environment variables template
```

## 🔑 Default Test Accounts

After running the SQL schema, you can create test accounts through the app's signup page, or you can manually insert them.

### Creating Your First Admin Account

1. Sign up through the app with the "Admin" role
2. Use your email and a secure password
3. The account will be created automatically

### Database Access

For direct database access:
1. Go to your Supabase Dashboard
2. Navigate to Table Editor
3. You can manually create/edit users there

## 📊 Database Schema

The application uses a comprehensive PostgreSQL database schema with:

- **Users Table**: Core user information with role-based access
- **Students Table**: Extended profile for students
- **Teachers Table**: Extended profile for teachers
- **Admins Table**: Extended profile with permissions
- **Assessment Sessions**: Track assessment progress
- **Assessment Results**: Store detailed results
- **Question Responses**: Individual answers
- **Student Progress**: Aggregate progress tracking
- **Classes**: Group management
- **Notifications**: User notifications
- **Activity Logs**: Audit trail

All tables have:
- Row Level Security (RLS) enabled
- Proper indexes for performance
- Foreign key constraints
- Automatic timestamp updates

## 🔧 Configuration

### Supabase Configuration

1. **Enable Email Auth**:
   - Supabase Dashboard → Authentication → Settings
   - Enable "Email" provider
   - Configure email templates (optional)

2. **Setup RLS Policies**:
   - All policies are created by the SQL schema
   - Verify they're active in: Dashboard → Authentication → Policies

3. **API Settings**:
   - The anon key is safe to use in client applications
   - It respects all RLS policies

### App Configuration

Key settings in `lib/config/constants.dart`:
```dart
// Add any app-specific constants here
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests (requires device/emulator)
flutter drive --target=test_driver/app.dart
```

## 🐛 Troubleshooting

### Common Issues

**1. Supabase Connection Error**
```
Error: Supabase not initialized
```
**Solution**: Verify your `.env` file has correct SUPABASE_URL and SUPABASE_ANON_KEY

**2. Build Errors**
```
Error: Could not resolve all files for configuration
```
**Solution**: Run `flutter clean` then `flutter pub get`

**3. Database Errors**
```
Error: Permission denied
```
**Solution**: Check RLS policies are properly set up in Supabase

**4. Login Issues**
```
Error: Invalid email or password
```
**Solution**: 
- Verify user exists in Supabase Dashboard
- Check email is confirmed (if email verification enabled)
- Ensure user has `is_active = true`

## 📦 Dependencies

Major packages used:

- `supabase_flutter: ^2.5.0` - Backend & Authentication
- `provider: ^6.0.0` - State Management
- `flutter_dotenv: ^5.1.0` - Environment Configuration
- `shared_preferences: ^2.2.3` - Local Storage
- `intl: ^0.19.0` - Internationalization
- `http: ^1.1.0` - HTTP Client

See `pubspec.yaml` for complete list.

## 🚀 Deployment

### Google Play Store

1. **Prepare for Release**:
   ```bash
   flutter build appbundle --release
   ```

2. **Generate Signing Key**:
   ```bash
   keytool -genkey -v -keystore ~/mindtrack-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias mindtrack
   ```

3. **Configure Signing**:
   Create `android/key.properties`:
   ```properties
   storePassword=your_store_password
   keyPassword=your_key_password
   keyAlias=mindtrack
   storeFile=path/to/mindtrack-release-key.jks
   ```

4. **Update `build.gradle.kts`** to reference signing config

5. **Build and Upload** to Play Console

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Credits

- Developed by: Tahsan0619
- Based on: Piaget's Cognitive Development Theory
- Backend: Supabase
- Framework: Flutter

## 📞 Support

For support, please:
1. Check the troubleshooting section above
2. Review closed issues on GitHub
3. Open a new issue with:
   - Flutter version (`flutter --version`)
   - Error logs
   - Steps to reproduce

## 🔄 Updates

### Version 1.0.0 (Current)
- ✅ Full Supabase integration
- ✅ Student, Teacher, and Admin dashboards
- ✅ Complete authentication system
- ✅ Role-based access control
- ✅ Assessment management
- ✅ Progress tracking
- ✅ Production-ready for Android

### Roadmap
- 🔲 iOS support
- 🔲 Offline mode
- 🔲 Push notifications
- 🔲 Advanced analytics
- 🔲 Export reports (PDF)
- 🔲 Multi-language support

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

**Built with ❤️ using Flutter and Supabase**
