import 'package:alco_t_dev/DataCollector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alco_t_dev/user_model.dart';

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

  var beta = 0.015;   // 시간당 분해량. 평균 0.015%. 0.008%~0.03%
  var absorptionFactor = 0.7;  // 알코올 흡수율

  var alcohol = 0.0;  // 누적 섭취량
  DateTime? lastIntake; // 마지막 섭취 시간
  var alcoholysisTime = 0.0;  // 마지막 섭취로부터 분해에 필요한 시간
  var maxBAC = 0.0; // 최대 BAC

  DrinkDataCollector _collector = DrinkDataCollector();

  void addAlcohol(double degree, double volumn){
    lastIntake = DateTime.now();
    alcohol += degree * volumn * 0.7894;
  }

  void setMaxBAC(bool isMan, double weight){
    double sexWeight = (isMan)?0.86:0.64;
    maxBAC = (absorptionFactor * alcohol) / (10 * weight * sexWeight);
  }

  double getCurrentBAC(){
    int passed = DateTime.now().difference(lastIntake!).inMinutes;
    if (passed >= 90) {
      return maxBAC - (beta * (passed/60));
    }
    return maxBAC;
  }

  void updateAlcohol(bool isMan, double weight){
    // 알코올이 추가될 때, 알코올이 부분적으로 분해됐을 경우 총 알코올량 갱신
    double sexWeight = (isMan)?0.86:0.64;
    int passed = DateTime.now().difference(lastIntake!).inMinutes;
    if (passed >= 90){
      alcohol -= beta * (passed/60) * (10 * weight * sexWeight) / absorptionFactor;
    }
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
    UserModel userModel = Provider.of<UserModel>(context);
    checkBAC();

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
                          updateAlcohol(userModel.sex!, userModel.weight!);
                          addAlcohol(deg, vol);
                          setMaxBAC(userModel.sex!, userModel.weight!);
                          setAlcoholysisTime();
                          _collector.setData(DrinkDataModel(user: userModel.user!, alcohol: alcohol));
                          _collector.saveData();
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

class DrinkDataCollector extends GetxController{

  DrinkDataModel? _data;

  void setData(DrinkDataModel dataInstance){
    _data = dataInstance;
  }

  void saveData() async {
    try{
      await FirebaseFirestore.instance.collection('drink').add(_data!.toJson());
    } catch(e){
      print(e);
    }
  }
}

class DrinkDataModel{
  User user;
  double alcohol;
  Timestamp? submitTime;

  DrinkDataModel({required this.user, required this.alcohol});

  DrinkDataModel.fromJson(Map<String, dynamic> json)
      : user = json['user'],
        alcohol = json['alcohol'],
        submitTime = json['submitTime'];

  Map<String,dynamic> toJson(){
    return {
      'user': user,
      'alcohol': alcohol,
      'submitTime': submitTime ?? FieldValue.serverTimestamp(),
    };
  }
}