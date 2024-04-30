import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
    return MaterialApp(
      home: InputScreen(),
    );
  }
}

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  // 변수들을 저장할 TextEditingController 생성
  TextEditingController _nameController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  TextEditingController _drinkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('사용자 정보 입력'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
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
                var data = {
                  'name': _nameController.text,
                  'weight': int.parse(_weightController.text),
                  'height': int.parse(_heightController.text),
                  'drink': int.parse(_drinkController.text),
                };

                // 사용자 정보 입력 후 화면 초기화
                _nameController.clear();
                _weightController.clear();
                _heightController.clear();
                _drinkController.clear();
              },
              child: Text('저장 후 테스트로'),

            ),
          ],
        ),
      ),
    );
  }
}