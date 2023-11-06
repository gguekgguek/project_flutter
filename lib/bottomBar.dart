import 'dart:math';
import 'package:flutter/material.dart';
import 'package:project_flutter/chat/chatList.dart';
import 'package:project_flutter/customer/userCustomer.dart';
import 'package:project_flutter/join/login_email.dart';
import 'package:project_flutter/myPage/customerLike.dart';
import 'package:project_flutter/product/product.dart';
import 'package:project_flutter/test.dart';
import 'package:project_flutter/tutorial.dart';
import 'package:provider/provider.dart';

import 'expert/my_expert.dart';
import 'join/userModel.dart';
import 'main.dart';
import 'myPage/myCustomer.dart';

class CircularDialog extends StatefulWidget {
  @override
  State<CircularDialog> createState() => _CircularDialogState();
}

class _CircularDialogState extends State<CircularDialog> {
  double rotation = 0.0;
  Offset initialPosition = Offset(0, 0);
  Offset currentPosition = Offset(0, 0);
  double dialogScale = 0.0; // 다이얼로그 크기의 초기 값
  double _dialogHeight = 0.0;

  List<Offset> calculateIconOffsets() {
    final double centerX = 300 / 2; // 컨테이너 가로 길이의 절반
    final double centerY = 300 / 2; // 컨테이너 세로 길이의 절반
    final double radius = 100.0; // 반지름

    final List<Offset> iconOffsets = [];

    for (int i = 0; i < 8; i++) {
      final double angle = i * (pi / 4); // 45도 간격으로 아이콘 배치
      final double x = centerX + radius * cos(angle) - 25; // 20은 아이콘의 크기 반값
      final double y = centerY + radius * sin(angle) - 30;
      iconOffsets.add(Offset(x, y));
    }

    return iconOffsets;
  }

  List<Offset> iconOffsets = [];
  List<String> addButtonTexts = ["expert", "chat", "고객센터", "테스트", "5", "6", "상품", "튜토리얼"];
  List<IconData> iconData = [Icons.star, Icons.message, Icons.people, Icons.chat, Icons.access_alarms_rounded, Icons.back_hand, Icons.add_circle_outline, Icons.telegram_sharp];
  List<Widget> pageChange = [Test(),ChatList(),UserCustomer(),Test(),HomePage(),HomePage(),Product(),Tutorial()];
  List<double> iconRotations = [pi / 2, 135 * (pi / 180), pi, 225 * (pi / 180), 270 * (pi / 180), 315 * (pi / 180), 360 * (pi / 180), 45 * (pi / 180)]; // 각 아이콘의 회전 각도

  @override
  void initState() {
    super.initState();
    iconOffsets = calculateIconOffsets();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      alignment: Alignment.bottomCenter, // 중앙 정렬
      child: TweenAnimationBuilder<double>(
        duration: Duration(milliseconds: 500),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (BuildContext context, double value, Widget? child) {
          dialogScale = value; // 크기 업데이트
          _dialogHeight = 200.0; // 원하는 높이로 설정

          return GestureDetector(
            onPanStart: (details) {
              setState(() {
                initialPosition = details.localPosition;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                // Calculate the rotation angle based on the drag direction
                double angle = (details.localPosition - initialPosition).direction;
                rotation = angle;
                currentPosition = details.localPosition;
              });
            },
            onPanEnd: (details) {
              setState(() {
              });
            },
            child: Transform.translate(
              offset: Offset(0, _dialogHeight * (1 - value)), // 아래에서 위로 슬라이딩
              child: Transform.scale(
                scale: dialogScale,
                child: Transform.rotate(
                  angle: -360 * (pi / 180) + (360 * (pi / 180) * value),
                  child: Transform.rotate(
                    angle: rotation,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          InkWell(
                            onTap: () {

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => HomePage()),
                              );
                            },
                            child: Image.asset(
                              'assets/logo.png',
                              width: 70,
                              height: 70,
                            ),
                          ),
                          for (int i = 0; i < iconOffsets.length; i++)
                            buildAddButton(
                              iconOffsets[i],
                              iconData[i],
                              iconRotations[i],
                              addButtonTexts[i],
                              i,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildAddButton(Offset offset, IconData icon, double rotationAngle, String text, int pageIndex) {
    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: Transform.rotate(
        angle: rotationAngle,
        child: Column(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => pageChange[pageIndex]),
                );
              },
              icon: Icon(
                icon,
              ),
            ),
            InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => pageChange[pageIndex]),
                );
              },
              child: Text(text)
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BottomBar(),
    // ... (앱 설정 및 라우팅 설정 등)
  ));
}

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  void _showCircularDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CircularDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _leftButton(),
          InkWell(
              onTap: (){
                _showCircularDialog(context);
              },
              child: Image.asset(
                'assets/logo.png',
                width: 70,
                height: 70,
                fit: BoxFit.contain,
              )
          ),
          _rightButton()
        ],
      ),
    );
  }
  Widget _leftButton(){
    return Expanded(
      child: IconButton(
        onPressed: () async {
          final userModel = Provider.of<UserModel>(context, listen: false);
          if (!userModel.isLogin) {
            // 사용자가 로그인하지 않은 경우에만 LoginPage로 이동
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
          } else {
            // 사용자가 로그인한 경우에만 MyPage로 이동
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => CustomerLikeList()));
          }
        },
        icon: Icon(Icons.favorite),
      ),
    );
  }
  Widget _rightButton(){
    return Expanded(
      child: IconButton(
          onPressed: () async {
            final userModel = Provider.of<UserModel>(context, listen: false);
            if (!userModel.isLogin) {
              // 사용자가 로그인하지 않은 경우에만 LoginPage로 이동
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
            } else {
              // 사용자가 로그인한 경우, userModel의 status 값에 따라 MyCustomer 또는 MyExpert로 이동
              final status = userModel.status;
              final userId = userModel.userId;
              if (status == 'C') {
                print("의뢰인");
                // 'C'인 경우 MyCustomer로 이동
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyCustomer(userId: userId!)));
              } else if (status == 'E') {
                print("전문가");
                // 'E'인 경우 MyExpert로 이동
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyExpert(userId: userId!)));
              } else {
                print("예외");
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>MyExpert(userId: userId!)));
              }
            }
          },
          icon: Icon(Icons.person)
      ),
    );
  }
}
