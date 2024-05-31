import 'package:alco_t_dev/DataCollector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/*
수정 예정사항
1. 유저 인풋 페이지 수정 후, 성별 정보 적용 가능하게 변경 예정(현재는 setMaxBal에 true(남자)로 넘겨주게 해놨음)
2. 음주량(alcohol) 로컬 기록 및 파이어베이스에 데이터 전송
3. 페이지 입장시 / 데이터 입력시 시간 확인해서 알코올 분해량 적용
4. 
*/

class WidmarkPage_improved extends StatefulWidget{
  const WidmarkPage_improved({Key? key}) : super(key: key);
  @override
  State<WidmarkPage_improved> createState() => _WidmarkPageState();
}

class _WidmarkPageState extends State<WidmarkPage_improved>{
  TextEditingController _drinkController = TextEditingController();
  TextEditingController _volumnController = TextEditingController();
  final myController = Get.put(DataCollector());
  var _selectedDrink = "직접 입력";
  var _selectedVolumn = "직접 입력";

  var beta = 0.015;   // 시간당 분해량
  var absorptionFactor = 0.7;  // 알코올 흡수율

  var alcohol = 0.0;  // 누적 섭취량
  DateTime? lastIntake; // 마지막 섭취 시간
  var alcoholysisTime = 0.0;  // 마지막 섭취로부터 분해에 필요한 시간
  var maxBAC = 0.0; // 최대 BAC

  void addAlcohol(double degree, double volumn){
    lastIntake = DateTime.now();
    alcohol += degree * volumn * 0.7894;
  }

  void setMaxBAC(bool isMan, double weight){
    double sexWeight = (isMan)?0.86:0.64;
    maxBAC = (absorptionFactor * alcohol) / (10 * weight * sexWeight);
  }

  double getCurrentBAC(){
    double passed = DateTime.now().difference(lastIntake!).inMinutes / 1000;
    return maxBAC - (beta * passed);
  }

  void setAlcoholysisTime(){
    alcoholysisTime = maxBAC / beta;
  }

  String getRemainedTime(){
    if(lastIntake != null){
      var passed = DateTime.now().difference(lastIntake!).inMinutes;
      var remained = (alcoholysisTime*60 - passed).floor();
      var hour = remained~/60;
      var minute = remained%60;
      return '$hour시간 $minute분';
    }
    else{
      return '0시간 0분';
    }
  }

  DateTime getEndTime(){
    if(lastIntake != null){
      var t = (alcoholysisTime*60).floor();
      var hour = t~/60;
      var minute = t%60;
      return lastIntake!.add(Duration(hours: hour, minutes: minute));
    }
    else{
      return DateTime.now();
    }
  }

  void checkBAC(){
    // 분해시간이 지났는지 체크
    if(getEndTime().difference(DateTime.now()).inMinutes <= 0){
      lastIntake = null;
      alcohol = 0;
      alcoholysisTime = 0;
      maxBAC = 0;
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
              Text('주종(도수):'),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDrink,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDrink = newValue!;
                            });
                          },
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                          items: <String>[
                            '소주(18 %)',
                            '맥주(4.5 %)',
                            '직접 입력',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  if (_selectedDrink == '직접 입력')
                    SizedBox(width: 10),
                  if (_selectedDrink == '직접 입력')
                    Expanded(
                      child: TextField(
                        controller: _drinkController,
                        decoration: InputDecoration(
                          labelText: '도수(%)',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16.0),
              Text('섭취량:'),
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedVolumn,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedVolumn = newValue!;
                            });
                          },
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                          items: <String>[
                            '소주잔 반 잔(25 ml)',
                            '소주잔 한 잔(50 ml)',
                            '소주 한 병(360 ml)',
                            '맥주잔 반 잔(110 ml)',
                            '맥주잔 한 잔(225 ml)',
                            '맥주 작은캔(350 ml)',
                            '맥주 큰 캔(500 ml)',
                            '직접 입력',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  if (_selectedVolumn == '직접 입력')
                    SizedBox(width: 10),
                  if (_selectedVolumn == '직접 입력')
                    Expanded(
                      child: TextField(
                        controller: _volumnController,
                        decoration: InputDecoration(
                          labelText: '섭취량(ml)',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // 취소 버튼 로직
                      _drinkController.clear();
                      _volumnController.clear();
                      setState(() {
                        _selectedDrink = '직접 입력';
                        _selectedVolumn = '직접 입력';
                      });
                    },
                    child: Text('취소'),
                  ),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      // 저장 버튼 로직
                      String drink, volumn;
                      RegExp regExp = RegExp(r'\((.*?)\s');
                      if(_selectedDrink == '직접 입력'){
                        drink = _drinkController.text;
                      }
                      else{
                        Match? match = regExp.firstMatch(_selectedDrink);
                        drink = match!.group(1)!;
                      }
                      if(_selectedVolumn == '직접 입력'){
                        volumn = _volumnController.text;
                      }
                      else{
                        Match? match = regExp.firstMatch(_selectedVolumn);
                        volumn = match!.group(1)!;
                      }
                      regExp = RegExp(r'^-?\d+(\.\d+)?$');
                      if(regExp.hasMatch(drink) && regExp.hasMatch(volumn)){
                        setState(() {
                          var deg = double.parse(drink) / 100;
                          var vol = double.parse(volumn);
                          addAlcohol(deg, vol);
                          setMaxBAC(true, 80);
                          setAlcoholysisTime();
                        });
                      }
                    },
                    child: Text('저장'),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Text("섭취 알코올(g): ${alcohol.toStringAsFixed(2)}",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w600),),
              SizedBox(height: 20.0),
              Text("최대 혈중 알코올 농도: ${maxBAC.toStringAsFixed(5)}",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w600),),
              SizedBox(height: 20.0),
              Text("권장 휴식시간: ${getRemainedTime()}",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w600),),
              SizedBox(height: 20.0),
              Text("분해 종료 시간 : ${DateFormat("MM/dd HH시 mm분").format(getEndTime())}",style: TextStyle(color: Colors.black,fontSize: 20,fontWeight: FontWeight.w600),),
              SizedBox(height: 20.0),
              Text("위드마크 공식으로 절대적인 기준이 아닙니다."),
            ],
          ),
        ),
      ),
    );
  }
}