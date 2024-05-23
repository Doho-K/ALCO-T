import 'package:alco_t_dev/DataCollector.dart';
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
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            SizedBox(height: 20.0),
            ElevatedButton(onPressed: () {

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
                  Text("대리운전",style:TextStyle(color: Colors.black),)
                ],
              ),
            )),
            SizedBox(height: 20.0),
            ElevatedButton(onPressed: () {

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
                  Text("내 운전 점수",style:TextStyle(color: Colors.black),)
                ],
              ),
            ))

          ],
        ),
      ),
    );
  }
}