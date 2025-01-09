import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Email dan password harus diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      Get.offAllNamed('/todo'); // Redirect ke halaman todo setelah login berhasil
    } on FirebaseAuthException catch (e) {
      String message = 'Terjadi kesalahan';
      if (e.code == 'user-not-found') {
        message = 'Email tidak ditemukan';
      } else if (e.code == 'wrong-password') {
        message = 'Password salah';
      }
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan yang tidak diketahui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      
      print('Memulai proses Google Sign In...');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('User membatalkan proses login Google');
        isLoading.value = false;
        return;
      }

      print('Mendapatkan detail autentikasi...');
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('Membuat kredensial Firebase...');
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Mencoba sign in ke Firebase...');
      // Sign in to Firebase with the Google credential
      await _auth.signInWithCredential(credential);
      print('Login berhasil, mengarahkan ke halaman todo...');
      Get.offAllNamed('/todo');
    } catch (e) {
      print('Error detail pada Google Sign In: $e');
      Get.snackbar(
        'Error',
        'Gagal login dengan Google: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

