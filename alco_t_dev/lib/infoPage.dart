import 'package:alco_t_dev/DataCollector.dart';
import 'package:alco_t_dev/GyroTask.dart';
import 'package:alco_t_dev/PatternSwipingPage.dart';
import 'package:alco_t_dev/landingPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:alco_t_dev/MapSearchPage.dart';
import 'package:alco_t_dev/SelectionPage.dart';

class infoPage extends StatefulWidget{
  const infoPage({Key? key}) : super(key: key);
  @override
  State<infoPage> createState() => _infoPageState();
}

class _infoPageState extends State<infoPage>{
  TextEditingController _nameController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  TextEditingController _drinkController = TextEditingController();
  final myController = Get.put(DataCollector());

  @override
  Widget build(BuildContext context){
    return Container(
      child: Padding(padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '이름',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: '몸무게 (kg)',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(
                labelText: '키 (cm)',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _drinkController,
              decoration: InputDecoration(
                labelText: '마신 주량 (ml)',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                // 사용자 정보를 저장할 Map 생성
                dataModel user = dataModel(
                  name: _nameController.text,
                  weight: double.parse(_weightController.text),
                  height: double.parse(_heightController.text),
                  drink: double.parse(_drinkController.text),
                );

                myController.data = user;
                myController.saveData();
                // 사용자 정보 입력 후 화면 초기화
                _nameController.clear();
                _weightController.clear();
                _heightController.clear();
                _drinkController.clear();
              },
              child: Text('저장'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(onPressed: (){
              Get.to(PatternSwipingPage(userID: "", sessionID: 1, inPattern: 3, randPattern: 2));//이 안에 이동할 페이지 클래스를 넣어주면 됨
            }, child: Text('스와이핑 테스크 페이지로 이동')),
            SizedBox(height: 20.0),
            ElevatedButton(onPressed: (){
              Get.to(MapSearchPage());//이 안에 이동할 페이지 클래스를 넣어주면 됨
            }, child: Text('타이핑 테스크 페이지로 이동')),
            SizedBox(height: 20.0),
            ElevatedButton(onPressed: (){
              Get.to(GyroTask());//이 안에 이동할 페이지 클래스를 넣어주면 됨
            }, child: Text('자이로 테스크 페이지로 이동')),
            SizedBox(height: 20.0),
            ElevatedButton(onPressed: (){
              Get.to(SelectionPage(userID: "", sessionID: 1));//이 안에 이동할 페이지 클래스를 넣어주면 됨
            }, child: Text('선택 테스크 페이지로 이동')),
          ],
        ),
      ),
    );
  }
}