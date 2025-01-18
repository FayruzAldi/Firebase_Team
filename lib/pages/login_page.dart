import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/routes/route.dart';
import 'package:to_do_list_app/widgets/mybutton.dart';
import 'package:to_do_list_app/widgets/mycolors.dart';
import 'package:to_do_list_app/widgets/mytextfield.dart';
import '../controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: colorBack,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(),
                Text(
                  'Welcome To',
                  style: TextStyle(
                    fontFamily: 'WelcomeFont',
                    fontSize: 32,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'To Do List App',
                  style: TextStyle(
                    fontFamily: 'WelcomeFont',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Spacer(),
                MyTextField(
                    hintText: 'Email',
                    isObsecure: false,
                    controller: controller.emailController,
                    fillColor: Colors.transparent,
                    filled: true,
                    borderColor: Colors.black,
                    focusedBorderColor: Colors.black,
                    borderRadius: 10,
                    prefixIcon: Icon(Icons.email)),
                const SizedBox(height: 20),
                Obx(
                  () => MyTextField(
                    hintText: 'Password',
                    isObsecure: controller.isPasswordHidden.value,
                    controller: controller.passwordController,
                    fillColor: Colors.transparent,
                    filled: true,
                    borderColor: Colors.black,
                    focusedBorderColor: Colors.black,
                    borderRadius: 10,
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordHidden.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: controller.togglePasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Obx(() => ElevatedButton(
                      onPressed:
                          controller.isLoading.value ? null : controller.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor1,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 6
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Login',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                    )),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Divider(color: Colors.black)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 20),
                MyButton(
                  text: 'Signin With Google',
                  imageAsset: 'lib/assets/google_logo.png',
                  backgroundColor: colorBack,
                  textColor: Colors.black.withOpacity(0.63),
                  fontSize: 16,
                  borderRadius: 10,
                  sideColor: Colors.black,
                  elevation: 2,
                  onPressed: controller.signInWithGoogle,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                    ),
                    TextButton(
                      onPressed: () {Get.toNamed(MyRoutes.signup);},
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                Spacer()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
