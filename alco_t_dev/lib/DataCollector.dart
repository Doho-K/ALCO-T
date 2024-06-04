import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DataCollector extends GetxController{

  dataModel? data;
  RxDouble gyroX = 0.0.obs;
  RxDouble gyroY = 0.0.obs;
  RxBool taskStart = false.obs;
  RxDouble initY = 0.0.obs;
  RxDouble gyroTime = 0.0.obs;
  RxString userName = 'user'.obs;
  RxInt userWeight = 60.obs;
  RxInt userHeight = 170.obs;
  RxBool userSex = true.obs;
  RxDouble userDrink = 0.0.obs;

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
      for(int i = 0; i<keystrokeTime.length; i++){
        if(keystrokeTime[i]>maxTime.value){
          maxTime.value = keystrokeTime[i];
        }
        if(keystrokeTime[i]<minTime.value){
          minTime.value = keystrokeTime[i];
        }
      }
      await FirebaseFirestore.instance.collection('typeTask').add({
        'len': typeTaskIndex,
        'maxTime': maxTime,
        'minTime': minTime,
        'avgTime': typeTaskTime/typeTaskIndex.value,
        'typoCount': delCount,
        'time': typeTaskTime,
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