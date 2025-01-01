import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UsersController extends GetxController {
  var users = <Map<String, dynamic>>[].obs;
  String? currentUserId;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final querySnapshot = await FirebaseFirestore.instance.collection('profile').get();

      users.value = querySnapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) => {
                'uid': doc.id,
                ...doc.data(),
              })
          .toList();
      if (users.isEmpty) {
        Center(
          child: Text("No users found"),
        );
      }
    } catch (e) {
      debugPrint("Error fetching users: $e");
    }
  }

  Future<String> openChat(String selectedUserId) async {
    String? chatId;

    try {
      QuerySnapshot chatQuery = await FirebaseFirestore.instance.collection('chats').where('participants', arrayContains: currentUser?.uid).get();

      for (var doc in chatQuery.docs) {
        List participants = doc['participants'];
        if (participants.contains(selectedUserId)) {
          chatId = doc.id;
          break;
        }
      }

      if (chatId == null) {
        DocumentReference newChat = await FirebaseFirestore.instance.collection('chats').add({
          'createdBy': currentUser?.uid,
          'participants': [currentUser?.uid, selectedUserId],
          'lastMessage': '',
          'lastUpdated': DateTime.now(),
        });
        chatId = newChat.id;
      }

      return chatId;
    } catch (e) {
      print("Error opening chat: $e");
      rethrow;
    }
  }
}
