import 'dart:developer';
import 'package:firebase_chat/chat_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/user_controller.dart';

class AllUsersScreen extends StatelessWidget {
  const AllUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UsersController controller = Get.put(UsersController());
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Obx(() {
        if (controller.users.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }
        return ListView.builder(
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            final user = controller.users[index];
            if (user.isEmpty) {
              Center(
                child: Text("No users found"),
              );
            }
            log("******* $user");
            return InkWell(
              onTap: () async {
                String chatId = await controller.openChat(user['uid']);
                Get.to(
                  () => ChatDetailScreen(
                    chatId: chatId,
                    selectedUserId: user['uid'],
                    isGroup: false,
                  ),
                );
              },
              child: Card(
                color: Colors.blue[300],
                margin: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[200],
                        child: Text(
                          user['name']![0].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'] ?? 'Unknown Name',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              user['email'] ?? 'Unknown Email',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      )
                    ],
                  ),
                ),
              ),
              onLongPress: () {
                final selectedUser = user;
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      contentPadding: const EdgeInsets.all(30),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Name: ${selectedUser['name']}", style: const TextStyle(fontSize: 18)),
                          Text("Mobile: ${selectedUser['mobile']}", style: const TextStyle(fontSize: 16)),
                          Text("Email: ${selectedUser['email']}", style: const TextStyle(fontSize: 16)),
                          Text("About Me: ${selectedUser['about_me']}", style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      }),
    );
  }
}
