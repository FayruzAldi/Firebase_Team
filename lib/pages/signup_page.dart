import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_list_app/widgets/mycolors.dart';
import 'package:to_do_list_app/widgets/mytextfield.dart';
import '../controllers/signup_controller.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SignupController controller = Get.find<SignupController>();

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
                const SizedBox(height: 150),
                Text(
                  'Create Your',
                  style: TextStyle(
                    fontFamily: 'WelcomeFont',
                    fontSize: 32,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'First Account',
                  style: TextStyle(
                    fontFamily: 'WelcomeFont',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 120),
                MyTextField(
                    hintText: 'Name',
                    isObsecure: false,
                    controller: controller.nameController,
                    fillColor: Colors.transparent,
                    filled: true,
                    borderColor: Colors.black,
                    focusedBorderColor: Colors.black,
                    borderRadius: 10,
                    prefixIcon: Icon(Icons.person)),
                const SizedBox(height: 20),
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
                          controller.isLoading.value ? null : controller.signup,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: mainColor1,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 6),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Sign Up',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                    )),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
