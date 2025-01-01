import 'package:firebase_chat/controller/chat_controller.dart';
import 'package:firebase_chat/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'all_users.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final List screens = [
     AllUsersScreen(),
     ChatScreen(),
     ProfileScreen(),
  ];

  final ChatController controller = Get.put(ChatController());

  void initState() {
    controller.fetchUsers();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Obx(() {
          switch (controller.currentIndex.value) {
            case 0:
              return const Text(
                "HOME",
                style: TextStyle(color: Colors.white, fontSize: 26),
              );
            case 1:
              return const Text(
                "CHATS",
                style: TextStyle(color: Colors.white, fontSize: 26),
              );
            case 2:
              return const Text(
                "PROFILE",
                style: TextStyle(color: Colors.white, fontSize: 26),
              );
            default:
              return const SizedBox();
          }
        }),
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.currentIndex.value == 1) {
              return IconButton(
                onPressed: () {
                  controller.createGroup(context);
                },
                icon: const Icon(
                  Icons.group_add,
                  color: Colors.white,
                  size: 26,
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
          Obx(() {
            if (controller.currentIndex.value == 2) {
              return PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
                onSelected: (value) async {
                  if (value == "logout") {
                    controller.logout(context);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: "logout",
                      child: Text("Logout"),
                    ),
                  ];
                },
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
      body: Obx(() {
        return screens[controller.currentIndex.value];
      }),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(backgroundColor: Colors.black87,
          selectedItemColor: Colors.blue[300],
          unselectedItemColor: Colors.white,
          selectedLabelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          currentIndex: controller.currentIndex.value,
          onTap: (index) {
            controller.setCurrentIndex(index);
            if(index == 1){
              controller.fetchChatAndGroups();
            }

          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: "Chats"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        );
      }),
    );
  }
}
