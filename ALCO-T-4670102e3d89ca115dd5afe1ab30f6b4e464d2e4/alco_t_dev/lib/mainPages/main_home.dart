import 'package:alco_t_dev/DataCollector.dart';
import 'package:alco_t_dev/GyroTask.dart';
import 'package:alco_t_dev/PatternSwipingPage.dart';
import 'package:alco_t_dev/SelectionPage.dart';
import 'package:alco_t_dev/driverCall.dart';
import 'package:alco_t_dev/driverScorePage.dart';
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
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Get.to(WidmarkPage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(255, 212, 212, 1),
                ),
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.local_drink, color: Colors.black, size: 40),
                      SizedBox(height: 10.0),
                      Text(
                        "간이 알코올 도수 계산기",
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.to(DriverCall());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(255, 212, 212, 1),
                ),
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.call, color: Colors.black, size: 40),
                      SizedBox(height: 10.0),
                      Text(
                        "대리운전 연결",
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.to(DriverScorePage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(255, 212, 212, 1),
                ),
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.add_chart, color: Colors.black, size: 40),
                      SizedBox(height: 10.0),
                      Text(
                        "내 운전 점수 확인",
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(255, 212, 212, 1),
                ),
                child: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.add_chart, color: Colors.black, size: 40),
                      SizedBox(height: 10.0),
                      Text(
                        "운전자 보험 확인",
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}