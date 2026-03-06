import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:piaget/providers/auth_provider.dart';
import 'package:piaget/providers/assessment_provider.dart';
import 'package:piaget/screens/auth/role_selection_screen.dart';
import 'package:piaget/screens/auth/login_screen.dart';
import 'package:piaget/screens/dashboard/dashboard_screen.dart';
import 'package:piaget/screens/assessment/assessment_screen.dart';
import 'package:piaget/screens/results/results_screen.dart';
import 'package:piaget/services/supabase_service.dart';
import 'package:piaget/config/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables
    await dotenv.load(fileName: '.env');
    
    // Initialize Supabase
    await SupabaseService().initialize();
  } catch (e) {
    // If .env fails to load or Supabase fails to initialize, log and continue
    // The app will work in offline mode or show appropriate errors
    debugPrint('Warning: Initialization error: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initializeAuth()),
        ChangeNotifierProvider(create: (_) => AssessmentProvider()),
      ],
      child: MaterialApp(
        title: 'MindTrack: Piaget Assessment',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const _AppNavigator(),
        routes: {
          '/role': (_) => const RoleSelectionScreen(),
          '/login': (_) => const LoginScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/assessment': (_) => const AssessmentScreen(),
          '/results': (_) => const ResultsScreen(),
        },
      ),
    );
  }
}

class _AppNavigator extends StatelessWidget {
  const _AppNavigator();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading indicator while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If not authenticated, show role selection screen
        if (!authProvider.isAuthenticated) {
          return const RoleSelectionScreen();
        }

        // If authenticated, show dashboard
        return const DashboardScreen();
      },
    );
  }
}
