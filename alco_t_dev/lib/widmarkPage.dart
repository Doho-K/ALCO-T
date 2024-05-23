import 'package:alco_t_dev/DataCollector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WidmarkPage extends StatefulWidget{
  const WidmarkPage({Key? key}) : super(key: key);
  @override
  State<WidmarkPage> createState() => _WidmarkPageState();
}

class _WidmarkPageState extends State<WidmarkPage>{
  TextEditingController _sojuController = TextEditingController();
  TextEditingController _beerController = TextEditingController();
  final myController = Get.put(DataCollector());
  var beer = 0;
  var soju = 0;
  var total = 0.0;
  var time = 0.0;
  String _formatTime(double time) {
    int hours = time.floor(); // 시간 부분 추출
    int minutes = ((time - hours) * 60).round(); // 분 부분 추출
    if(time<0){
      return '0시간 0분';
    }
    else{
      return '$hours시간 $minutes분';
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SingleChildScrollView( // SingleChildScrollView 추가
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("얼마나 마셨나요?",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w600),),
              SizedBox(height: 20.0),
              TextField(
                onChanged: (text){
                  setState(() {
                    soju = int.parse(text);
                    total = soju * 7.125 + beer * 8;
                    time = ((total / (10*myController.userWeight.value*0.84))-0.03)/0.015;
                  });
                },
                controller: _sojuController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromRGBO(255, 212, 212, 1),
                  labelText: '소주 몇 잔 마셨나요?',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20.0),
              TextField(
                onChanged: (text){
                  setState(() {
                    beer = int.parse(text);
                    total = soju * 7.125 + beer * 8;
                    time = ((total / (10*myController.userWeight.value*0.84))-0.03)/0.015;

                  });

                },
                controller: _beerController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color.fromRGBO(255, 212, 212, 1),
                  labelText: '맥주 몇 잔 마셨나요?(225ml)',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20.0),
              Text("권장 휴식시간: ${_formatTime(time)}",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w600),),
              SizedBox(height: 20.0),
              Text("위드마크 공식으로 절대적인 기준이 아닙니다.")
            ],
          ),
        ),
      ),
    );
  }
}
