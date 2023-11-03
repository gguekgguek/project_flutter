import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/myPage/editProfile.dart';
import 'package:project_flutter/myPage/purchaseManagement.dart';
import 'package:provider/provider.dart';
import '../chat/chatList.dart';
import '../expert/adManagement.dart';
import '../expert/adRequest.dart';
import '../expert/messageResponse.dart';
import '../expert/myPortfolio.dart';
import '../expert/ratings.dart';
import '../expert/revenue.dart';
import '../expert/vacation.dart';
import '../firebase_options.dart';
import '../join/userModel.dart';
import '../product/product.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late Map<String, dynamic> data;
  late bool isExpert;

  Color appBarColor = Color(0xFF4E598C);

  @override
  void initState() {
    super.initState();
    isExpert = false;
  }

  Widget _userInfo() {
    UserModel userModel = Provider.of<UserModel>(context);

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("userList")
          .where("userId", isEqualTo: userModel.userId)
          .limit(1)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (snap.hasData) {
          data = snap.data!.docs[0].data() as Map<String, dynamic>;
          isExpert = data['status'] == 'E';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isExpert ? '전문가' : '의뢰인',
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
                  _toggleExpertStatus();
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
                  data['status'] == 'C' ? '전문가로 전환' : '의뢰인으로 전환',
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

  void _toggleExpertStatus() {
    String newStatus = isExpert ? 'C' : 'E';

    FirebaseFirestore.instance
        .collection("userList")
        .where('userId', isEqualTo: data['userId'])
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({'status': newStatus}).then((_) {
          setState(() {
            isExpert = !isExpert;
            appBarColor = isExpert ? Color(0xFFFCAF58) : Color(0xFF4E598C);

          });
        }).catchError((error) {
          print('Firestore 업데이트 실패: $error');
        });
      });
    }).catchError((error) {
      print('Firestore 쿼리 실패: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Pretendard',
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "마이페이지",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: appBarColor, // 배경색 변경
          elevation: 1.0,
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              child: Text(
                "계정 설정",
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
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
                      radius: 50,
                      backgroundImage: AssetImage('assets/profile.png'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
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
              if(!isExpert)  // 클라이언트의 경우 컨텐츠 표시
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '보낸 제안',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      // 작업 가능한 프로젝트 목록
                      // 프로젝트 보러가기 버튼
                    ],
                  ),
                ),




              Divider(
                color: Colors.grey,
                thickness: 5.0,
              ),

              if(isExpert)
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  ListTile(
                    leading: Icon(Icons.shopping_bag_outlined),
                    title: Text('구매관리'),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                     Navigator.push(context, MaterialPageRoute(
                         builder: (context) => PurchaseManagementPage()));
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

              if(!isExpert)
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '판매 정보',
                        // style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '3개월 이내 판매중인 건수:',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        '50',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue, // 파란색 텍스트
                        ),
                      ),
                    ],
                  ),
                ),

              // 나의 서비스 섹션
              if(!isExpert)
              Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '나의 서비스',
                      // style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      leading: Icon(Icons.monetization_on), // 아이콘 추가
                      title: Text(
                        '수익 관리',
                        // style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      onTap:(){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => Revenue()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.ad_units), // 아이콘 추가
                      title: Text(
                        '광고 관리',
                        // style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      onTap:(){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AdManagement()));
                      },
                    ),

                    ListTile(
                      leading: Icon(Icons.add), // 아이콘 추가
                      title: Text(
                        '광고 신청',
                        // style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      onTap:(){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AdRequest()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.beach_access), // 아이콘 추가
                      title: Text(
                        '휴가 설정',
                        // style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      onTap:(){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => Vacation()));
                      },
                    ),
                    ListTile(
                        leading: Icon(Icons.star), // 아이콘 추가
                        title: Text(
                          '나의 전문가 등급',
                          // style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        onTap:() {
                          Navigator.of(context).push(MaterialPageRoute(builder: (
                              context) => ExpertRating()));
                        }
                    ),
                    ListTile(
                      leading: Icon(Icons.portrait), // 아이콘 추가
                      title: Text(
                        '나의 포트폴리오',
                        // style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      onTap:(){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => Portfolio()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.message), // 아이콘 추가
                      title: Text(
                        '메시지 응답 관리',
                        // style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      onTap:(){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => MessageResponse()));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          elevation: 5.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Product()),
                  );
                },
                icon: Icon(Icons.shopping_bag_outlined),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatList()),
                  );
                },
                icon: Icon(Icons.chat_outlined),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.person_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
