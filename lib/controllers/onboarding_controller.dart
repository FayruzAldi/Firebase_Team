import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Models/onboarding_model.dart';
import '../routes/route.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;
  static const String ONBOARDING_KEY = 'has_seen_onboarding';

  final List<OnboardingModel> pages = [
    OnboardingModel(
      title: 'Manage your\ntasks',
      description: 'Organize all your to-do\'s and projects. Color coordinate and prioritize your tasks',
      image: 'lib/assets/todolist.png',
    ),
    OnboardingModel(
      title: 'Get reminded\nin time',
      description: 'Get reminded when it\'s time to do your tasks and never miss a deadline again',
      image: 'lib/assets/todolist.png',
    ),
    OnboardingModel(
      title: 'Stay organized\nwith us',
      description: 'Organize your daily tasks and make your life easier with us',
      image: 'lib/assets/todolist.png',
    ),
  ];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() async {
    if (currentPage.value == pages.length - 1) {
      try {
        // Simpan status bahwa user sudah melihat onboarding
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(ONBOARDING_KEY, true);
        Get.offAllNamed(MyRoutes.login);
      } catch (e) {
        print('Error saving onboarding status: $e');
      }
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
} 