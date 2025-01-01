import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ChatDetailController extends GetxController {
  late final String chatId;
  late final String selectedUserId;
  late final bool isGroup;
  RxBool isDeleteMode = false.obs; // Tracks if delete mode is active
  RxList<String> selectedMessages = <String>[].obs; // Stores IDs of selected messages


  ChatDetailController({
    required this.chatId,
    required this.isGroup,
    required this.selectedUserId,
  });

  final TextEditingController messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  Rx<String> title = "Chat".obs;
  RxList<QueryDocumentSnapshot<Map<String, dynamic>>> messages = <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>> messageSubscription;

  @override
  void onInit() {
    super.onInit();
    fetchTitle();
    startListeningToMessages();
    readReceipts();
  }

  @override
  void onClose() {
    messageSubscription.cancel();
    super.onClose();
  }

  void startListeningToMessages() {
    messageSubscription = FirebaseFirestore.instance
        .collection(isGroup ? 'groups' : 'chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      messages.value = snapshot.docs;
      for (var doc in snapshot.docs) {
        var messageData = doc.data();
        if (messageData['isRead'][currentUser?.uid] == false) {
          markMessageAsRead(doc.id);
        }
      }
    });
  }

  void readReceipts() {
    for (var message in messages) {
      final messageData = message.data();
      final isReadMap = messageData['isRead'] as Map<String, dynamic>;

      bool allReadByOthers = true;

      for (var entry in isReadMap.entries) {
        if (entry.key != currentUser?.uid && entry.value == false) {
          allReadByOthers = false;
          break;
        }
      }

      if (allReadByOthers) {
        log("Message with ID ${message.id} has been read by all except the sender.");
      } else {
        log("Message with ID ${message.id} has not been read by all participants.");
      }
    }
  }

  void sendMessage() async {
    if (messageController.text.trim().isEmpty) return;

    final message = messageController.text.trim();
    String senderName = 'unknown';
    messageController.clear();

    try {
      final profileDoc = await FirebaseFirestore.instance.collection('profile').doc(currentUser?.uid).get();
      if (profileDoc.exists) {
        senderName = profileDoc.data()?['name'] ?? "Unknown Sender";
      }
    } catch (e) {
      debugPrint("Error fetching sender name: $e");
    }

    Map<String, bool> isRead = {};
    if (isGroup) {
      final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(chatId).get();
      if (groupDoc.exists) {
        final participants = groupDoc.data()?['participants'] ?? [];
        for (String userId in participants) {
          isRead[userId] = false;
        }
      }
    } else {
      isRead[selectedUserId] = false;
      isRead[currentUser!.uid] = false;
    }

    final messageData = {
      'senderId': currentUser?.uid,
      'senderName': senderName,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead
    };

    final chatDocRef = FirebaseFirestore.instance.collection(isGroup ? 'groups' : 'chats').doc(chatId);
    try {
      await chatDocRef.collection('messages').add(messageData);
      await chatDocRef.update({
        'lastMessage': message,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      debugPrint("Message sent and chat updated successfully.");
    } catch (e) {
      debugPrint("Failed to send message or update chat: $e");
    }
  }

  void markMessageAsRead(String messageId) async {
    final currentUserId = currentUser?.uid;

    try {
      final messageRef = FirebaseFirestore.instance.collection(isGroup ? 'groups' : 'chats').doc(chatId).collection('messages').doc(messageId);

      await messageRef.update({
        'isRead.$currentUserId': true,
      });

      debugPrint("Message marked as read for user $currentUserId");
    } catch (e) {
      debugPrint("Error marking message as read: $e");
    }
  }

  void fetchTitle() async {
    try {
      if (isGroup) {
        final groupDoc = await FirebaseFirestore.instance.collection('groups').doc(chatId).get();
        if (groupDoc.exists) {
          title.value = groupDoc.data()?['name'] ?? "Group Chat";
        } else {
          title.value = "Unknown Group";
        }
      } else {
        final userDoc = await FirebaseFirestore.instance.collection('profile').doc(selectedUserId).get();
        if (userDoc.exists) {
          title.value = userDoc.data()?['name'] ?? "User";
        } else {
          title.value = "Unknown User";
        }
      }
    } catch (e) {
      debugPrint("Error fetching title: $e");
      title.value = "Error";
    }
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "";
    final dateTime = timestamp.toDate();
    return DateFormat.jm('en_US').format(dateTime);
  }

}
