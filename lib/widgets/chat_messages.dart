import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (ctx, chatShapshots) {
          if (chatShapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                strokeCap: StrokeCap.round,
              ),
            );
          }
          if (!chatShapshots.hasData || chatShapshots.data!.docs.isEmpty) {
            return Center(
              child: Text("No mesage found!"),
            );
          }
          if (chatShapshots.hasError) {
            return Center(
              child: Text("Something went wrong :("),
            );
          }
          final loadedMessages = chatShapshots.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 32, left: 16, right: 16),
            reverse: true,
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, index) {
              final chatMessage = loadedMessages[index].data();
              final nextChatMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;

              final currentMessageUserID = chatMessage['userId'];
              final nextMessageUserID =
                  nextChatMessage != null ? nextChatMessage['userId'] : null;

              final nextUserIsSameAsCurrent =
                  nextMessageUserID == currentMessageUserID;

              if (nextUserIsSameAsCurrent) {
                return MessageBubble.next(
                    message: chatMessage['message_text'],
                    isMe: authenticatedUser.uid == currentMessageUserID);
              } else {
                return MessageBubble.first(
                    userImage: chatMessage['user_image'],
                    username: chatMessage['username'],
                    message: chatMessage['message_text'],
                    isMe: authenticatedUser.uid == currentMessageUserID);
              }
              // return Text(loadedMessages[index].data()['message_text']);
            },
          );
        });
  }
}
