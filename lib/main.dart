import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/home_screen.dart';
import 'package:firebase_chat/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  User? user = FirebaseAuth.instance.currentUser;

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: user == null ?  LoginScreen() :  HomeScreen(),
    ),
  );
}



