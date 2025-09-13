import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'features/onboarding/controllers/onboarding_controller.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/medication/controllers/medication_controller.dart';
import 'core/routes/app_routes.dart';
import 'features/onboarding/screens/on_boarding_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'services/notification_service.dart';
import 'screens/homepage.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => MedicationController()),
      ],
      child: const AppView(),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('🚀 Initializing app...');
      final authController = context.read<AuthController>();
      await authController.initializeAuth();
      await NotificationService.initialize();
      print('✅ App initialization complete');
      FlutterNativeSplash.remove();

    } catch (e) {
      print('⚠️ App initialization error: $e');
      FlutterNativeSplash.remove();
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      // Show loading screen while initializing
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(AppConstants.primaryColorValue),
                    ),
                    strokeWidth: 4,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return MaterialApp(
          title: 'Awan',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: authController.isLoggedIn
              ? const Homepage()
              : const OnBoardingScreen(),

          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
