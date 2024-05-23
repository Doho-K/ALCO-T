import 'package:alco_t_dev/infoPage.dart';
import 'package:alco_t_dev/main.dart';
import 'package:alco_t_dev/mainPages/mainPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class landingPage extends StatefulWidget {
  const landingPage({ Key? key }) : super(key: key);
  @override
  State<landingPage> createState() => _landingPageState();
}

class _landingPageState extends State<landingPage> {
  @override
  void initState() {
    super.initState();
    //GetPage(name: '/info', page: () => infoPage(), transition: Transition.zoom);
    // 2초 후에 HomePage로 이동
    Future.delayed(Duration(seconds: 2), () {
      Get.to(mainPage());
      //Get.toNamed('/info');
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("당신의 안전운전을 위해서", style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600)),
            Text(
              'ALCO-T',
              style: TextStyle(fontSize: 64, color: Color.fromRGBO(255, 77, 77, 1), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      )
    );
  }
}