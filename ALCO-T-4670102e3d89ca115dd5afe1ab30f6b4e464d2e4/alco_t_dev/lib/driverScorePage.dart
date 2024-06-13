import 'package:alco_t_dev/DataCollector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverScorePage extends StatelessWidget {
  final myController = Get.put(DataCollector());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('운전 점수', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Color.fromRGBO(255, 77, 77, 1)),
      body: Center(
        child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('images/profile.png'), // 사용자 사진 경로 설정
              ),
              SizedBox(height: 16),
              Text(
                myController.userName.value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                '운전 경력: 3년 4개월',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                '차량 종류: 소나타 2020',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                '차량 번호: 1234가 5678',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                '긴급 연락처: 010-2341-2381',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 32),
              Text(
                '당신의 운전 점수',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 16),
              Text(
                '운전 점수: 120점\n안전 운전 상위 13%!\n8개월동안 총 5%의 보험료를 절약했어요!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

            ],
          )
        ),
      );

  }
}