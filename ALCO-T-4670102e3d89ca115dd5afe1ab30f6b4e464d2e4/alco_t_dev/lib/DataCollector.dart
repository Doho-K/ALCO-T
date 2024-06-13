import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'dart:math';
class DataCollector extends GetxController{

  dataModel? data;
  RxDouble gyroX = 0.0.obs;
  RxDouble gyroY = 0.0.obs;
  RxBool taskStart = false.obs;
  RxDouble initY = 0.0.obs;
  RxDouble gyroTime = 0.0.obs;
  RxString userName = '김푸앙'.obs;
  RxInt userWeight = 60.obs;
  RxInt userHeight = 170.obs;
  RxBool userSex = true.obs;
  RxDouble userDrink = 0.0.obs;
  RxInt drunkStat = 0.obs;

  RxBool typeTaskStart = false.obs;
  RxDouble typeTaskTime = 0.0.obs;
  RxInt typeTaskIndex = 0.obs;
  RxInt delCount = 0.obs;
  RxList<double> keystrokeTime = <double>[].obs;
  RxDouble maxTime = 0.0.obs;
  RxDouble minTime = 0.0.obs;

  void saveData() async {
    try{
      await FirebaseFirestore.instance.collection('user').add(data!.toJson());
    }
    catch(e){
      print(e);
    }
  }

  void saveGyroTask(double gyroX,double gyroY, double maxX, double maxY, double time) async{
    try{
      await FirebaseFirestore.instance.collection('gyroTask').add({
        'initGyroX': gyroX,
        'initGyroY': gyroY,
        'maxGyroX': maxX,
        'maxGyroY': maxY,
        'gyroTime': time,
        'userName': userName.value,
        'userDrink': userDrink.value,
      });
    }
    catch(e){
      print(e);

    }
  }

  void saveTypeTask() async{
    try{
      maxTime.value = keystrokeTime.reduce(max);
      minTime.value = keystrokeTime.reduce(min);
      print('len: ${typeTaskIndex.value}');
      print('maxTime: ${maxTime.value}');
      print('minTime: ${minTime.value}');
      print('avgTime: ${typeTaskTime/typeTaskIndex.value}');
      print('typoCount: ${delCount.value}');
      print('time: ${typeTaskTime}');
      print('userName: ${userName.value}');
      print('userDrink: ${userDrink.value}');

      await FirebaseFirestore.instance.collection('typeTask').add({
        'len': typeTaskIndex.value,
        'maxTime': maxTime.value,
        'minTime': minTime.value,
        'avgTime': typeTaskTime.value/typeTaskIndex.value,
        'typoCount': delCount.value,
        'time': typeTaskTime.value,
        'userName': userName.value,
        'userDrink': userDrink.value,
      });
      typeTaskIndex.value = 0;
      delCount.value = 0;
      maxTime.value = 0;
      minTime.value = 0;
      typeTaskTime.value = 0;
      keystrokeTime.clear();
    }
    catch(e){
      print('len: ${typeTaskIndex.value}');
      print('maxTime: ${maxTime.value}');
      print('minTime: ${minTime.value}');
      print('avgTime: ${typeTaskTime/typeTaskIndex.value}');
      print('typoCount: ${delCount.value}');
      print('time: ${typeTaskTime}');
      print('userName: ${userName.value}');
      print('userDrink: ${userDrink.value}');
      print('TypeTask Error');
      print(e);
    }
  }

}

class dataModel{
  String name;
  double weight;
  double height;
  double drink;

  dataModel({required this.name, required this.weight, required this.height, required this.drink});

  dataModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        weight = json['weight'],
        height = json['height'],
        drink = json['drink'];

  Map<String,dynamic> toJson(){
    return {
      'name': name,
      'weight': weight,
      'height': height,
      'drink': drink,
    };
  }
}