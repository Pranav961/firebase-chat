import 'package:firebase_chat/controller/chat_controller.dart';
import 'package:firebase_chat/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final ChatController controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LOGIN",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          children: [
            buildTextField(controller.emailController, "Email"),
            const SizedBox(height: 35),
            buildTextField(controller.passwordController, "Password"),
            const SizedBox(height: 35),
            ElevatedButton(
              onPressed: () async {
                if (controller.emailController.text.isEmpty || controller.passwordController.text.isEmpty) {
                  Get.snackbar(
                    "Error",
                    "Please fill in both fields",
                    snackPosition: SnackPosition.BOTTOM,
                    duration: Duration(seconds: 3),
                  );
                } else {
                  await controller.login(
                    context,
                    controller.emailController.text,
                    controller.passwordController.text,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.black),
              child: const Text(
                "SUBMIT",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Get.to(const SignUp());
              },
              child: const Text(
                "Don't have an account? SIGN UP",
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }

  TextField buildTextField(controller, hint) => TextField(
        controller: controller,
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
