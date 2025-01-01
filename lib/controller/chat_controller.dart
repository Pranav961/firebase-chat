import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/home_screen.dart';
import 'package:firebase_chat/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  var chats = <Map<String, dynamic>>[].obs;
  var groups = <Map<String, dynamic>>[].obs;
  var chatUsers = <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> users = [];
  RxList<Map<String, dynamic>> selectedMembers = <Map<String, dynamic>>[].obs;
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Rx<int> currentIndex = 0.obs;

  void setCurrentIndex(int index) {
    currentIndex.value = index;
  }

  Future<void> fetchChatAndGroups() async {
    try {
      debugPrint("Fetching chats and groups...");
      FirebaseFirestore.instance.collection('chats').orderBy('lastUpdated', descending: true).snapshots().listen((querySnapshot) {
        chatUsers.value = querySnapshot.docs.map((doc) => doc.data()).toList();
      });

      final chatQuery = await FirebaseFirestore.instance.collection('chats').where('participants', arrayContains: currentUserId).get();

      debugPrint("Chats fetched: ${chatQuery.docs.length}");

      final fetchedChats = await Future.wait(chatQuery.docs.map((doc) async {
        final chatData = doc.data();
        final participants = chatData['participants'] as List<dynamic>;
        final otherUserId = participants.firstWhere((id) => id != currentUserId, orElse: () => null);
        if (otherUserId == null) return null;

        final userDoc = await FirebaseFirestore.instance.collection('profile').doc(otherUserId).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          return {
            'id': doc.id,
            'type': 'chat',
            'uid': otherUserId,
            'name': userData?['name'] ?? 'Unknown User',
            'lastMessage': chatData['lastMessage'] ?? 'No messages yet',
            'lastUpdated': chatData['lastUpdated']?.toDate(),
          };
        }
        return null;
      }).toList());

      debugPrint("Fetched chats: ${fetchedChats.length}");

      final validChats = fetchedChats.where((chat) => chat != null).cast<Map<String, dynamic>>().toList();

      final groupQuery = await FirebaseFirestore.instance.collection('groups').where('participants', arrayContains: currentUserId).get();
      debugPrint("Groups fetched: ${groupQuery.docs.length}");

      final fetchedGroups = await Future.wait(groupQuery.docs.map((doc) async {
        final groupData = doc.data();
        final groupName = groupData['name'] ?? 'Unnamed Group';

        return {
          'id': doc.id,
          'type': 'group',
          'name': groupName,
          'lastMessage': groupData['lastMessage'] ?? 'No messages yet',
          'lastUpdated': groupData['createdAt']?.toDate(),
        };
      }).toList());

      debugPrint("Fetched groups: ${fetchedGroups.length}");

      final combinedList = [...validChats, ...fetchedGroups];

      chatUsers.value = combinedList;

      chatUsers.sort((a, b) {
        final dateA = a['lastUpdated'] ?? DateTime(0);
        final dateB = b['lastUpdated'] ?? DateTime(0);
        return dateB.compareTo(dateA);
      });

      debugPrint("Total chatUsers: ${chatUsers.length}");
    } catch (e) {
      debugPrint("Error fetching chats and groups: $e");
    }
  }

  Future<void> fetchUsers() async {
    String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    try {
      final currentUserDoc = await FirebaseFirestore.instance.collection('profile').doc(currentUserId).get();

      final querySnapshot = await FirebaseFirestore.instance.collection('profile').get();

      users = querySnapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) => {
                'uid': doc.id,
                ...doc.data(),
              })
          .toList();

      final currentUserData = {
        'uid': currentUserId,
        ...currentUserDoc.data()!,
      };

      users.insert(0, currentUserData);
    } catch (e) {
      debugPrint("Error fetching users: $e");
    }

    update();
  }

  Future<void> createGroup(BuildContext context) async {
    String groupName = '';

    if (users.isEmpty) {
      await fetchUsers();
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text(
          "Create Group",
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => groupName = value,
                style: TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Group Name",
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 10),
              Obx(() {
                return Column(
                  children: users.map((user) {
                    final isSelected = selectedMembers.contains(user);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Text(
                          user['name'][0].toUpperCase(),
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      title: Text(
                        user['name'],
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        user['email'],
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.circle_outlined),
                      onTap: () {
                        if (isSelected) {
                          selectedMembers.remove(user);
                        } else {
                          selectedMembers.add(user);
                        }
                      },
                    );
                  }).toList(),
                );
              })
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              selectedMembers.clear();
              Get.back();
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (groupName.isNotEmpty && selectedMembers.isNotEmpty) {
                try {
                  final groupMembers = selectedMembers.map((e) => e['uid']).toList();
                  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                  if (!groupMembers.contains(currentUserId)) {
                    groupMembers.add(currentUserId);
                  }

                  final groupId = FirebaseFirestore.instance.collection('groups').doc().id;
                  await FirebaseFirestore.instance.collection('groups').doc(groupId).set({
                    'name': groupName,
                    'participants': groupMembers,
                    'createdAt': DateTime.now(),
                  });

                  debugPrint("Group created successfully: $groupName");
                } catch (e) {
                  debugPrint("Error creating group: $e");
                }
                Get.back();
              } else {
                debugPrint("Group name or members cannot be empty.");
              }
            },
            child: Text(
              "Create",
              style: TextStyle(color: Colors.blue[300]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Logout?"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text(
                "No",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Get.offAll(() => LoginScreen());
              },
              child: const Text(
                "Yes",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> login(BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      log("---------- $userCredential");

      Get.offAll(() => HomeScreen());

      Get.snackbar("Login Successful", "", duration: const Duration(seconds: 2));
    } catch (e) {
      Get.snackbar("Error", "", duration: const Duration(seconds: 2));
    }
  }

  Future<void> signUp(BuildContext context, String name, String email, String number, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? uid = userCredential.user?.uid;

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        'name': name,
        'email': email,
        'mobile': number,
      });

      Get.offAll(() => LoginScreen());

      Get.snackbar("Sign Up Successful", "You have successfully registered.", duration: const Duration(seconds: 2));
    } catch (e) {
      debugPrint("$e");

      Get.snackbar("Error", "Something went wrong: $e", duration: const Duration(seconds: 2));
    }
  }
}
