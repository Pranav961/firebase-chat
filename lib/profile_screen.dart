import 'package:firebase_chat/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());

  void initState() {
    controller.loadProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(35),
          child: Column(
            spacing: 35,
            children: [
              profileField(controller.nameController, "Name"),
              profileField(controller.numberController, "Mobile Number"),
              profileField(controller.emailController, "Email"),
              profileField(controller.aboutMeController, "About Me"),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: controller.saveProfile,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: const Text(
                      "SAVE",
                      style: TextStyle(color: Colors.black87, fontSize: 18),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  TextField profileField(controller, hint) => TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: Colors.black),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(width: 1, color: Colors.black),
          ),
        ),
      );
}
