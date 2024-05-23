import 'package:alco_t_dev/DataCollector.dart';
import 'package:alco_t_dev/GyroTask.dart';
import 'package:alco_t_dev/PatternSwipingPage.dart';
import 'package:alco_t_dev/SelectionPage.dart';
import 'package:alco_t_dev/widmarkPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class main_home extends StatefulWidget {
  const main_home({Key? key}) : super(key: key);

  @override
  State<main_home> createState() => _main_homeState();
}

class _main_homeState extends State<main_home> {
  final myController = Get.put(DataCollector());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SizedBox(height: 20.0),
              ElevatedButton(onPressed: () {
                Get.to(WidmarkPage());
              },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(255, 212, 212, 1),
                  ),
                  child: Container(
                    height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.local_drink,color: Colors.black,),
                    SizedBox(width: 10.0),
                    Text("알코올 도수 계산기",style:TextStyle(color: Colors.black),)
                  ],
                ),
              )),
              SizedBox(height: 20.0),
              ElevatedButton(onPressed: () {
                Get.to(PatternSwipingPage(userID: "", sessionID: 1, inPattern: 3, randPattern: 2));
              },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(255, 212, 212, 1),
                  ),
                  child: Container(
                    height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.call,color: Colors.black,),
                    SizedBox(width: 10.0),
                    Text("대리운전//타이핑 테스크",style:TextStyle(color: Colors.black),)
                  ],
                ),
              )),
              SizedBox(height: 20.0),
              ElevatedButton(onPressed: () {
                Get.to(SelectionPage(sessionID: 1,userID: "",));
              },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(255, 212, 212, 1),
                  ),
                  child: Container(
                height: 70,

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add_chart,color: Colors.black,),
                    SizedBox(width: 10.0),
                    Text("내 운전 점수//선택 테스트",style:TextStyle(color: Colors.black),)
                  ],
                ),
              )),
              ElevatedButton(onPressed: () {
                Get.to(GyroTask());
              },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(255, 212, 212, 1),
                  ),
                  child: Container(
                    height: 70,

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.add_chart,color: Colors.black,),
                        SizedBox(width: 10.0),
                        Text("자이로 테스크",style:TextStyle(color: Colors.black),)
                      ],
                    ),
                  ))

            ],
          ),
        ),
      ),
    );
  }
}