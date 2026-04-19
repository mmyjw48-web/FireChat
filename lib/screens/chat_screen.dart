import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_massage/screens/welcome_screen.dart';

// انتهينا عند تصميم رسائل المرسل و المستقبل و الفرق بينهم

final _firestore = FirebaseFirestore.instance;
late User singedUser;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  static const chat_screen_rout = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  String? messageText;
  final messagesController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_current_user();
  }

  void get_current_user() {
    try {
      final cur_user = _auth.currentUser;
      if (cur_user != null) {
        singedUser = cur_user;
        print(singedUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  // void messagesStream() async {
  //   await for (var snapshot in _firestore.collection('message').snapshots()) {
  //     for (var message in snapshot.docs) {
  //       print(message.data());
  //     }
  //   }
  // }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[900],
        title: Row(
          children: [
            Image.asset('images/logo.png', height: 25),
            SizedBox(width: 10),
            Text('MessageMe'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // messagesStream();
              // add here logout function
              try {
                _auth.signOut();
                Navigator.pushNamed(context, WelcomeScreen.welcom_rout);
              } catch (e) {
                print("dont sing out $e");
              }
            },
            icon: Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                reverse: true,
                children: [StreamBuilderMessages(firestore: _firestore)],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.orange, width: 2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: messagesController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        hintText: 'Write your message here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messagesController.clear();
                      _firestore.collection('message').add({
                        'text': messageText,
                        'sender': singedUser.email,
                        'time': FieldValue.serverTimestamp(),
                      });
                    },
                    child: Text(
                      'send',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StreamBuilderMessages extends StatelessWidget {
  const StreamBuilderMessages({
    super.key,
    required FirebaseFirestore firestore,
  });
  // : _firestore = firestore;

  // final FirebaseFirestore _firestore;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('message').orderBy('time').snapshots(),
      builder: (context, snapshot) {
        List<widgetMessage> widgetMessages = [];

        if (!snapshot.hasData) {
          // this will include Modal Progress
          return Center(
            child: CircularProgressIndicator(backgroundColor: Colors.blue),
          );
        }
        ;
        final messages = snapshot.data!.docs;
        for (var message in messages) {
          final messageText = message.get('text');
          final messageSender = message.get('sender');
          widgetMessage(
            messageSender,
            messageText,
            messageSender == singedUser.email,
          );
          widgetMessages.add(
            widgetMessage(
              messageSender,
              messageText,
              messageSender == singedUser.email,
            ),
          );
        }
        return Column(children: widgetMessages);
      },
    );
  }
}

class widgetMessage extends StatelessWidget {
  const widgetMessage(this.sender, this.text, this.isMe, {super.key});
  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Column(
            children: [
              Text(
                sender,
                style: TextStyle(fontSize: 10, color: Colors.black45),
              ),
              Material(
                color: isMe ? Colors.blue : Colors.yellow[900],
                borderRadius: isMe
                    ? BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      )
                    : BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 20,
                  ),
                  child: Text(
                    ' $text ',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
