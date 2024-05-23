import 'package:alco_t_dev/infoPage.dart';
import 'package:alco_t_dev/landingPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(infoPage());
      },
      child: GetMaterialApp(
        initialRoute: '/', // 초기 경로 설정
        getPages: [
          GetPage(name: '/', page: () => landingPage()),
          GetPage(name: '/info', page: () => infoPage(), transition: Transition.zoom),
        ],
        home: landingPage(),//InputScreen(),
      ),
    );
  }
}

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  // 변수들을 저장할 TextEditingController 생성
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('사용자 정보 입력'),
      ),
      body:infoPage(),
    );
  }
}