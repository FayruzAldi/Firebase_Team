import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/route.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Cek apakah user sudah login
    final user = FirebaseAuth.instance.currentUser;
    
    // Jika mencoba mengakses halaman todo tanpa login
    if (route == MyRoutes.todo && user == null) {
      return const RouteSettings(name: MyRoutes.login);
    }
    
    // Jika sudah login dan mencoba mengakses halaman login/signup/onboarding
    if ((route == MyRoutes.login || route == MyRoutes.signup || route == MyRoutes.onboarding) && user != null) {
      return const RouteSettings(name: MyRoutes.todo);
    }
    
    return null;
  }
} 