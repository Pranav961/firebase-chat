import 'package:firebase_chat/controller/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final ChatController controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Obx(() {
        if (controller.chatUsers.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }
        return ListView.builder(
          itemCount: controller.chatUsers.length,
          itemBuilder: (context, index) {
            final item = controller.chatUsers[index];
            final isGroup = item['type'] == 'group';

            final name = item['name'];
            final avatarLetter = name != null && name.isNotEmpty ? name[0].toUpperCase() : '?';
            if (avatarLetter == null) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            }

            return InkWell(
              onTap: () async {
                String chatId = item['id'];
                String selectedUserId = isGroup ? '' : item['uid'];
                Get.to(
                  () => ChatDetailScreen(
                    chatId: chatId,
                    selectedUserId: selectedUserId,
                    isGroup: isGroup,
                  ),
                );
              },
              child: Card(
                color: Colors.blue[300],
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey[200],
                        child: name == null
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : Text(
                                avatarLetter,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.black87),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isGroup ? item['name'] ?? "" : item['name'] ?? "",
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.4,
                              child: Text(
                                item['lastMessage'] ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
