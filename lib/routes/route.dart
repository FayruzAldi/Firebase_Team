import 'package:get/get.dart';
import 'package:to_do_list_app/bindings/Todo_binding.dart';
import '../bindings/login_binding.dart';
import '../bindings/signup_binding.dart';
import '../bindings/onboarding_binding.dart';
import '../middleware/auth_middleware.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../pages/todo_page.dart';
import '../pages/edit_page.dart';
import '../pages/onboarding_page.dart';

class MyRoutes {
  static const String onboarding = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String todo = '/todo';
  static const String edit = '/edit';
}

class AppPages {
  static final authMiddleware = AuthMiddleware();
  
  static final List<GetPage> pages = [
    GetPage(
      name: MyRoutes.onboarding,
      page: () => OnboardingPage(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: MyRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
      middlewares: [authMiddleware],
    ),
    GetPage(
      name: MyRoutes.signup,
      page: () => const SignupPage(),
      binding: SignupBinding(),
      middlewares: [authMiddleware],
    ),
    GetPage(
      name: MyRoutes.todo,
      page: () => TodoPage(),
      binding: TodoBinding(),
      middlewares: [authMiddleware],
    ),
    GetPage(
      name: MyRoutes.edit,
      page: () => const EditPage(),
      middlewares: [authMiddleware],
    ),
  ];
}
