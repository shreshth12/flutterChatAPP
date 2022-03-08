import 'package:chatapp/screens/conversation.dart';
import 'package:chatapp/screens/search.dart';
import 'package:chatapp/screens/signIn.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/services/helper.dart';
import 'package:chatapp/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class chatRoom extends StatefulWidget {
  const chatRoom({Key? key}) : super(key: key);

  @override
  State<chatRoom> createState() => _chatRoomState();
}

class _chatRoomState extends State<chatRoom> {
  Stream? chatRoomsStream;

  Widget chatRoomList() {
    return StreamBuilder(
      stream: chatRoomsStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.size,
                itemBuilder: (context, index) {
                  return chatRoomTile(
                      snapshot.data.docs[index]
                          .get("chatroomid")
                          .toString()
                          .replaceAll("_", "")
                          .replaceAll(Constants.myName, ""),
                      snapshot.data.docs[index].get("chatroomid"));
                },
              )
            : Container();
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    getUserInfo();

    super.initState();
  }

  getUserInfo() async {
    Constants.myName = (await HelperFunctions.getUserNameSharedPreference())!;
    DatabaseMethods().getChatRooms(Constants.myName).then((value) {
      setState(() {
        chatRoomsStream = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conversations"),
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.black,
              ),
              onPressed: () => {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: const Text('Are you sure'),
                        content: const Text('you want to log out?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => {
                              HelperFunctions.saveUserLoggedInSharedPreference(
                                  false),
                              Navigator.pop(context, 'OK'),
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          signIn()))
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    )
                  }),
        ],
      ),
      body: chatRoomList(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SearchRoom()));
        },
      ),
    );
  }
}

class chatRoomTile extends StatelessWidget {
  final String userName;
  final String chatRoomID;
  chatRoomTile(this.userName, this.chatRoomID);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Conversation(chatRoomID)));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(children: [
          Container(
            height: 10,
            width: 10,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(12)),
          ),
          SizedBox(width: 8),
          Text(userName)
        ]),
      ),
    );
  }
}
