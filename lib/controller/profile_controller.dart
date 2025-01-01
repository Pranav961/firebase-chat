import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {


  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final doc = await FirebaseFirestore.instance.collection('profile').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;

      nameController.text = data['name'] ?? '';
      numberController.text = data['mobile'] ?? '';
      aboutMeController.text = data['about_me'] ?? '';
      emailController.text = data['email'] ?? '';
    }
  }

  Future<void> saveProfile() async {
    if (nameController.text.isEmpty || numberController.text.isEmpty || aboutMeController.text.isEmpty) {
      Get.snackbar(
        "Please fill all details",
        "",
        duration: Duration(seconds: 2),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('profile')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({'name': nameController.text, 'mobile': numberController.text, 'about_me': aboutMeController.text, 'email': emailController.text});

      Get.snackbar(
        "Profile saved successfully",
        "",
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint("Error: $e");
      Get.snackbar(
        "Error saving profile. Try Again!",
        "",
        duration: Duration(seconds: 2),
      );
    }
  }
}
