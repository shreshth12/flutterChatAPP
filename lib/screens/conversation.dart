// ignore_for_file: prefer_const_constructors
import 'package:chatapp/services/database.dart';
import 'package:chatapp/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Conversation extends StatefulWidget {
  final String? chatRoomID;
  Conversation(this.chatRoomID);

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  TextEditingController messageTextEditingController =
      new TextEditingController();

  Stream? chatMessagesStream;

  Widget chatMessageList() {
    return StreamBuilder(
      stream: chatMessagesStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.size,
                itemBuilder: (context, index) {
                  return MessageTile(
                    snapshot.data.docs[index].get("message"),
                    snapshot.data.docs[index].get("sendBy") == Constants.myName,
                  );
                },
              )
            : Container();
      },
    );
  }

  sendMessage() {
    if (messageTextEditingController.text.isNotEmpty) {
      Map<String, dynamic> messageMap = {
        "message": messageTextEditingController.text,
        "sendBy": Constants.myName,
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      DatabaseMethods().addConversationMessages(widget.chatRoomID!, messageMap);
      messageTextEditingController.text = '';
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    DatabaseMethods().getConversationMessages(widget.chatRoomID!).then((value) {
      setState(() {
        chatMessagesStream = value;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat rating: '),
      ),
      backgroundColor: Colors.black,
      body: Container(
        child: Stack(
          children: [
            chatMessageList(),
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: messageTextEditingController,
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.white),
                        hintText: "Message",
                        prefixIcon: Icon(Icons.send),
                        border: InputBorder.none,
                      ),
                    )),
                    Material(
                        elevation: 5,
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(30),
                        child: MaterialButton(
                          child: Text("Send"),
                          onPressed: () {
                            sendMessage();
                          },
                        ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;

  MessageTile(this.message, this.isSendByMe);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: isSendByMe ? 0 : 24, right: isSendByMe ? 24 : 0),
      width: MediaQuery.of(context).size.width,
      alignment: isSendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: isSendByMe
                    ? [const Color(0xff007EF4), const Color(0xff2A75BC)]
                    : [
                        Color.fromARGB(255, 255, 255, 255),
                        Color.fromARGB(255, 250, 250, 250)
                      ]),
            borderRadius: isSendByMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomLeft: Radius.circular(23))
                : BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                    bottomRight: Radius.circular(23))),
        child: Text(
          message,
          style: TextStyle(color: Colors.black, fontSize: 17),
        ),
      ),
    );
  }
}
