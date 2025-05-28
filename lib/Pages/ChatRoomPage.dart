import 'dart:developer';
import 'dart:io';
import 'package:chat_app/main.dart';
import 'package:chat_app/Models/ChatRoomModel.dart';
import 'package:chat_app/Models/MessageModel.dart';
import 'package:chat_app/Models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage({Key? key, required this.targetUser, required this.chatroom, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {

  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      // Send Message
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: DateTime.now(),
        text: msg,
        seen: false,
        mediaUrl: null,
        mediaType: null,
      );

      FirebaseFirestore.instance.collection("chatrooms").doc(
          widget.chatroom.chatroomid)
          .collection("messages").doc(newMessage.messageid).set(
          newMessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance.collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      log("Message Sent!");
    }
  }

  Future<void> pickImage_Send() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      UploadTask uploadTask = FirebaseStorage.instance
          .ref("chatimages/$fileName.jpg")
          .putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      MessageModel imageMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        text: null,
        seen: false,
        createdon: DateTime.now(),
        mediaUrl: downloadUrl,
        mediaType: "image",
      );
      FirebaseFirestore.instance.collection("chatrooms").doc(
          widget.chatroom.chatroomid)
          .collection("messages").doc(imageMessage.messageid)
          .set(imageMessage.toMap());
      widget.chatroom.lastMessage = "📷 Photo";
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: NetworkImage(widget.targetUser.profilepic ?? ''),
            ),
            const SizedBox(width: 10),
            Text(widget.targetUser.fullname ?? ''),
          ],
        ),
      ),
      body: Column(
        children: [
// Message list
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid)
                  .collection("messages").orderBy("createdon", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot data = snapshot.data as QuerySnapshot;
                    return ListView.builder(
                      reverse: true,
                      itemCount: data.docs.length,
                      itemBuilder: (context, index) {
                        MessageModel currentMessage = MessageModel.fromMap(
                            data.docs[index].data() as Map<String, dynamic>);

                        bool isMe = currentMessage.sender == widget.userModel.uid;

                        return Align(
                          alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Colors.grey[400]
                                  : Theme
                                  .of(context)
                                  .colorScheme
                                  .secondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: currentMessage.mediaUrl != null
                                ? Image.network(currentMessage.mediaUrl!,
                                height: 200, fit: BoxFit.cover)
                                : Text(
                              currentMessage.text ?? "",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text("No messages yet"));
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          // Input area
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: pickImage_Send,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Expanded(
                  child: TextField(
                    controller: messageController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      hintText: "Enter message",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                  color: Theme
                      .of(context)
                      .colorScheme
                      .secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}