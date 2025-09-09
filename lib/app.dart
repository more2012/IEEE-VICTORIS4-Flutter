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

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => MedicationController()),
      ],
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey, // Add this line
        debugShowCheckedModeBanner: false,
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        home: const OnBoardingScreen(),
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
