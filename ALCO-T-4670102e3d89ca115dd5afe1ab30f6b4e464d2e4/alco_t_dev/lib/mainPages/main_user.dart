import 'package:alco_t_dev/DataCollector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class main_user extends StatefulWidget {
  const main_user({Key? key}) : super(key: key);

  @override
  State<main_user> createState() => _main_userState();
}

class _main_userState extends State<main_user> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  final myController = Get.put(DataCollector());
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("사용자 정보 입력",style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.w600),),
              ],
            )),
            SizedBox(height: 20.0),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(255, 212, 212, 1),
                labelText: '이름',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(255, 212, 212, 1),
                labelText: '몸무게(kg)',
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromRGBO(255, 212, 212, 1),
                labelText: '키(cm)',
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              height: 30,
              child: ElevatedButton(
                onPressed: () {
                  myController.userName.value = _nameController.text;
                  myController.userWeight.value = int.parse(_weightController.text);
                  myController.userHeight.value = int.parse(_heightController.text);
                },
                child: Text("저장하기",style: TextStyle(color: Colors.black),),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              height: 1,
              color: Colors.black,
            ),
            SizedBox(height: 20.0),
            Container(
              child: Text("개인정보 처리 방침"),
            ),
            SizedBox(height: 20.0),
            Container(
              child: Text("주의 사항"),
            ),
            SizedBox(height: 20.0),
            Container(
              child: Text("저작권 정보"),
            ),


          ],
        ),
      ),
    );
  }

}