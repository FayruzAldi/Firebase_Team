import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/login_model.dart';
import '../Models/user_model.dart';

class LoginController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    signInOption: SignInOption.standard,
  );
  
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
      
      // Membuat model login
      final loginData = LoginModel(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Login ke Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: loginData.email,
        password: loginData.password,
      );

      // Mengambil data user dari Firestore
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      if (userDoc.exists) {
        final userData = UserModel.fromJson({
          'uid': userCredential.user!.uid,
          ...userDoc.data()!
        });
        print('Login berhasil untuk user: ${userData.name}');
      }

      Get.offAllNamed('/todo');
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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('User membatalkan proses login Google');
        isLoading.value = false;
        return;
      }

      print('Mendapatkan detail autentikasi...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('Membuat kredensial Firebase...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Mencoba sign in ke Firebase...');
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Menyimpan atau mengupdate data user di Firestore
      final userData = UserModel(
        uid: userCredential.user!.uid,
        name: googleUser.displayName ?? '',
        email: googleUser.email,
        createdAt: DateTime.now(),
        photoUrl: googleUser.photoUrl,
      );

      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData.toJson(), SetOptions(merge: true));

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

