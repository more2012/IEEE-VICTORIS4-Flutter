import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Added for Firebase init
import 'package:flutter_native_splash/flutter_native_splash.dart'; // Assuming this is needed from your version
import 'app.dart'; // Assuming this holds your main App widget
import 'services/notification_service.dart'; // Where we move notification init logic
import 'services/storage_service.dart'; // Assuming this service exists

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding); // From your version
  await Firebase.initializeApp();
  await StorageService.init();
  await NotificationService.initialize();

  runApp(const App());
}
