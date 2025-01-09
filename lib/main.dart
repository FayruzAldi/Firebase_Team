import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_list_app/firebase_options.dart';
import 'package:to_do_list_app/routes/route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'To Do List App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: _initialRoute,
      getPages: AppPages.pages,
    );
  }

  String get _initialRoute {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Jika user sudah login, arahkan ke halaman todo
      return MyRoutes.todo;
    }
    // Jika user belum login, arahkan ke halaman login
    return MyRoutes.login;
  }
}


