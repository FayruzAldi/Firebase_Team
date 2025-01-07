import 'package:get/get.dart';
import '../bindings/login_binding.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../pages/todo_page.dart';
import '../pages/edit_page.dart';

class MyRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String todo = '/todo';
  static const String edit = '/edit';
}

class AppPages {
  static final List<GetPage> pages = [
    GetPage(name: MyRoutes.login, page: () => const LoginPage(), binding: LoginBinding()),
    GetPage(name: MyRoutes.signup, page: () => const SignupPage(), binding: LoginBinding()),
    GetPage(name: MyRoutes.todo, page: () => const TodoPage()),
    GetPage(name: MyRoutes.edit, page: () => const EditPage()),
  ];
}
