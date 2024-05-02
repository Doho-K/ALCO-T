import 'package:flutter/material.dart';

class landingPage extends StatefulWidget {
  const landingPage({ Key? key }) : super(key: key);
  @override
  State<landingPage> createState() => _landingPageState();
}

class _landingPageState extends State<landingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('테스트 랜딩 페이지'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '테스트 랜딩 페이지',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      )
    );
  }
}