import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:project_flutter/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  late String userAId;
  late String userBId;
  late String chatRoomId;

  @override
  void initState() {
    super.initState();
    final Uuid uuid = Uuid();
    userAId = uuid.v4();
    userBId = uuid.v4();
    chatRoomId = 'chat_room_${userAId}_${userBId}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '상대방 아이디',
          style: TextStyle(color: Colors.black), // 텍스트 색상을 흰색으로 설정
        ),
        centerTitle: true, // 제목을 중앙 정렬
        backgroundColor: Colors.white, // AppBar의 배경색을 투명색으로 설정
      ),

      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text("상대방이 계좌이체 등 직접 결제를 요구하면 거절하시고 \n 즉시 고객센터로 알려주세요", style: TextStyle(fontSize: 12,), textAlign: TextAlign.center,),
          ),
          Expanded(
            child: ChatMessages(chatRoomId: chatRoomId, userAId: userAId),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: '메시지 입력'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _handleOnSubmit();
                  },
                ),
              ],
            ),
          ),
          if (_isLoading)
            CircularProgressIndicator(),
        ],
      ),
    );
  }

  void _handleOnSubmit() {
    final String text = _messageController.text;
    if (text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      _firestore.collection('chat_rooms/$chatRoomId/messages').add({
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'user': userAId,
      }).then((_) {
        _messageController.clear();
      }).catchError((error) {
        print('Error: $error');
      }).whenComplete(() {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }
}

class ChatMessages extends StatelessWidget {
  final String chatRoomId;
  final String userAId;

  ChatMessages({
    required this.chatRoomId,
    required this.userAId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms/$chatRoomId/messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),

      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final messages = snapshot.data?.docs;

        if (messages != null && messages.isNotEmpty) {
          List<Widget> messageWidgets = [];
          for (var message in messages) {
            final messageText = message['text'];
            final messageTimestamp = message['timestamp'];
            final user = message['user'];

            final isCurrentUser = user == userAId;

            final messageWidget = ChatMessage(
              text: messageText,
              sendTime: messageTimestamp != null
                  ? DateFormat('a h:mm').format(messageTimestamp.toDate())
                  : DateFormat('a h:mm').format(DateTime.now()),
              isCurrentUser: isCurrentUser,
            );


            messageWidgets.add(messageWidget);
          }

          return ListView(
            reverse: true,
            children: messageWidgets,
          );
        } else {
          return Center(
            child: Text('No messages available.'),
          );
        }
      },
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final String sendTime;
  final bool isCurrentUser;

  ChatMessage({
    required this.text,
    required this.sendTime,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final currentDateTime = DateTime.now();
    final messageDateTime = DateFormat('yy.MM.dd hh:mm').parse(sendTime, true);

    // 날짜를 비교하여 '다음 날' 여부를 확인
    final isNextDay = currentDateTime.day < messageDateTime.day;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.orange : Colors.grey,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  text,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Text(
                isNextDay ? '---------${DateFormat('yyyy.MM.dd').format(messageDateTime)}--------' : sendTime,
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}