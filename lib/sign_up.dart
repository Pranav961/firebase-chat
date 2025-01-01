import 'package:firebase_chat/controller/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final ChatController controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SIGN UP",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          children: [
            buildTextField(nameController, "Name"),
            const SizedBox(height: 25),
            buildTextField(emailController, "Email"),
            const SizedBox(height: 25),
            buildTextField(numberController, "Mobile Number"),
            const SizedBox(height: 25),
            buildTextField(passwordController, "Password"),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                await controller.signUp(context, nameController.text, emailController.text, numberController.text, passwordController.text);
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
