import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/expert/my_expert.dart';
import 'package:project_flutter/main.dart';
import 'package:project_flutter/myPage/purchaseManagement.dart';
import 'package:provider/provider.dart';
import '../join/userModel.dart';
import 'editProfile.dart';

class MyCustomer extends StatefulWidget {
  final String userId;

  const MyCustomer({required this.userId, Key? key}) : super(key: key);

  @override
  _MyCustomerState createState() => _MyCustomerState(userId: userId);
}

class _MyCustomerState extends State<MyCustomer> {
  final String userId;
  late Map<String, dynamic> data;
  String profileImageUrl = '';

  _MyCustomerState({required this.userId});

  @override
  void initState() {
    super.initState();
    loadUserProfileImageUrl();
  }

  void loadUserProfileImageUrl() async {
    String? imageUrl = await getUserProfileImageUrl(userId);
    setState(() {
      profileImageUrl = imageUrl ?? 'assets/profile.png';
    });
  }

  Future<String?> getUserProfileImageUrl(String userId) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection("userList");
      QuerySnapshot snap = await users.where('userId', isEqualTo: userId).get();

      for (QueryDocumentSnapshot doc in snap.docs) {
        return doc['profileImageUrl'] as String?;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "마이페이지",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFFCAF58),
        elevation: 1.0,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            child: Text(
              "계정 설정",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfile(data: data),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _userInfo(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 5.0,
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text(
                    "내 프로젝트",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    child: Column(
                      children: [
                        Text("요구사항을 작성하시고, 딱 맞는 전문가와의 거래를 진행하세요"),
                        ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.white),
                            side: MaterialStateProperty.all(
                              BorderSide(
                                color: Color(0xff424242),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Text(
                            "프로젝트 의뢰하기",
                            style: TextStyle(color: Color(0xff424242)),
                          ),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 5.0,
            ),
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  leading: Icon(Icons.shopping_bag_outlined),
                  title: Text('구매관리'),
                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PurchaseManagementPage()));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.credit_card),
                  title: Text('결제/환불내역'),
                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {
                    // 두 번째 아이템이 클릭됐을 때 수행할 작업
                  },
                ),
                ListTile(
                  leading: Icon(Icons.question_mark),
                  title: Text('고객센터'),
                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {
                    // 세 번째 아이템이 클릭됐을 때 수행할 작업
                  },
                ),
                ListTile(
                  leading: Icon(Icons.star),
                  title: Text('네 번째 아이템'),
                  subtitle: Text('네 번째 아이템 설명'),
                  onTap: () {
                    // 네 번째 아이템이 클릭됐을 때 수행할 작업
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _userInfo() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("userList")
          .where("userId", isEqualTo: widget.userId)
          .limit(1)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (snap.hasData) {
          data = snap.data!.docs[0].data() as Map<String, dynamic>;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '의뢰인',
                    style: TextStyle(
                      backgroundColor: Colors.yellow,
                    ),
                  ),
                  Text(
                    data['nick'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  UserModel userModel = Provider.of<UserModel>(context, listen: false);
                  userModel.updateStatus('E');

                  CollectionReference users = FirebaseFirestore.instance.collection('userList');
                  users
                      .where('userId', isEqualTo: widget.userId)
                      .limit(1)
                      .get()
                      .then((QuerySnapshot querySnapshot) {
                    if (querySnapshot.docs.isNotEmpty) {
                      DocumentReference docRef = querySnapshot.docs.first.reference;
                      Map<String, dynamic> dataToUpdate = {
                        'status': 'E',
                      };
                      docRef.update(dataToUpdate).then((_) {
                        print("문서 업데이트 성공");
                      }).catchError((error) {
                        print("문서 업데이트 오류: $error");
                      });
                    }
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyExpert(userId: userId),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  side: MaterialStateProperty.all(
                    BorderSide(
                      color: Color(0xff424242),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Text(
                  '전문가로 전환',
                  style: TextStyle(color: Color(0xff424242)),
                ),
              ),
            ],
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
