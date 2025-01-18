import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_app/firebase_options.dart';
import 'package:to_do_list_app/routes/route.dart';
import 'package:to_do_list_app/controllers/onboarding_controller.dart';
import 'package:to_do_list_app/services/notification_service.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    print('Initializing Firebase...');
    // Inisialisasi Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');

    print('Initializing Notification Service...');
    // Inisialisasi Notification Service
    final notificationService = NotificationService();
    await notificationService.initialize();
    Get.put(notificationService, permanent: true);
    print('Notification Service initialized successfully');

    // Cek status onboarding
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool(OnboardingController.ONBOARDING_KEY) ?? false;
    
    runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding));
  } catch (e) {
    print('Error initializing app: $e');
    runApp(const MyApp(hasSeenOnboarding: false));
  }
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  
  const MyApp({
    super.key,
    required this.hasSeenOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'To Do List App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: _determineInitialRoute(),
      getPages: AppPages.pages,
    );
  }

  String _determineInitialRoute() {
    final user = FirebaseAuth.instance.currentUser;
    
    // Jika user sudah login, langsung ke todo
    if (user != null) {
      return MyRoutes.todo;
    }
    
    // Jika belum login tapi sudah pernah lihat onboarding, ke login
    if (hasSeenOnboarding) {
      return MyRoutes.login;
    }
    
    // Jika belum login dan belum pernah lihat onboarding, ke onboarding
    return MyRoutes.onboarding;
  }
}


