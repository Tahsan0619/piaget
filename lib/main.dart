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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // If .env fails to load, continue anyway (API features may not work)
    debugPrint('Warning: Could not load .env file: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AssessmentProvider()),
      ],
      child: MaterialApp(
        title: 'MindTrack: Piaget Assessment',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
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
        if (!authProvider.isAuthenticated) {
          return const RoleSelectionScreen();
        }
        return const DashboardScreen();
      },
    );
  }
}
