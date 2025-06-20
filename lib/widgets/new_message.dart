import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});
  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final TextEditingController _messageController = TextEditingController();
  bool _hasEnteredMessage = false;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_checkInput);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _checkInput() {
    final isNotEmpty = _messageController.text.trim().isNotEmpty;
    if (_hasEnteredMessage != isNotEmpty) {
      setState(() {
        _hasEnteredMessage = isNotEmpty;
      });
    }
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;
    if (enteredMessage.trim().isEmpty) return;
    _messageController.clear();

    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    // Not a good solution if you want to expand it

    FirebaseFirestore.instance.collection('chats').add({
      'message_text': enteredMessage,
      'created_at': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'],
      'user_image': userData.data()!['image_url'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, bottom: 24, right: 1),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  labelText: "Message...",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(9999))),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 10, horizontal: 20), // <-- Add this
                ),
                controller: _messageController,
              ),
            ),
          ),
          IconButton(
              onPressed: _hasEnteredMessage ? _submitMessage : null,
              color: Theme.of(context).colorScheme.primary,
              icon: const Icon(
                Icons.send,
              ))
        ],
      ),
    );
  }
}
