import 'package:awan/features/onboarding/controllers/onboarding_controller.dart';
import 'package:awan/features/auth/controllers/auth_controller.dart';
import 'package:awan/core/routes/app_routes.dart';
import 'features/screens/on_boarding_screen.dart';
import 'package:awan/core/theme/app_theme.dart';
import 'package:awan/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingController()),
        ChangeNotifierProvider(create: (_) => AuthController()),
      ],
      child: MaterialApp(
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
