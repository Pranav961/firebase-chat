import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat/controller/chat_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatDetailScreen extends StatelessWidget {
  final String chatId;
  final String selectedUserId;
  final bool isGroup;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.selectedUserId,
    required this.isGroup,
  });

  @override
  Widget build(BuildContext context) {
    final ChatDetailController controller = Get.put(
      ChatDetailController(chatId: chatId, isGroup: isGroup, selectedUserId: selectedUserId),
    );

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Obx(() => Text(controller.title.value)),
        backgroundColor: Colors.blue[300],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty) {
                return const Center(
                  child: Text("No messages yet."),
                );
              }
              return ListView.builder(
                reverse: true,
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index].data();
                  final senderName = message['senderName'] ?? 'Unknown Sender';
                  final isMe = message['senderId'] == FirebaseAuth.instance.currentUser?.uid;
                  final time = controller.formatTimestamp(message['timestamp']);
                  final isReadMap = message['isRead'] as Map<String, dynamic>? ?? {};
                  bool allReadByOthers =
                      isReadMap.entries.where((entry) => entry.key != FirebaseAuth.instance.currentUser?.uid).every((entry) => entry.value == true);

                  return Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: IntrinsicWidth(
                          child: Container(
                            margin: isMe
                                ? EdgeInsets.only(top: 10, bottom: 10, right: 10, left: MediaQuery.of(context).size.width * 0.4)
                                : EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.4, left: 10, top: 10, bottom: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue[300] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  senderName,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300, color: isMe ? Colors.white : Colors.black),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  message['text'] ?? '',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 5),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        time,
                                        style: const TextStyle(
                                          fontSize: 8,
                                          color: Colors.black26,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      if (isMe)
                                        Icon(
                                          allReadByOthers ? Icons.done_all : Icons.done,
                                          size: 13,
                                          color: allReadByOthers ? Colors.blue : Colors.black26,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: controller.messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      focusedBorder:
                          OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide(color: Colors.blue)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15)), borderSide: BorderSide(color: Colors.black)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue[300]),
                  onPressed: controller.sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
