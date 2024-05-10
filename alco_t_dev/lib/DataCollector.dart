import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DataCollector extends GetxController{

  dataModel? data;
  RxDouble gyroX = 0.0.obs;
  RxDouble gyroY = 0.0.obs;
  RxBool taskStart = false.obs;
  RxDouble initY = 0.0.obs;
  RxDouble gyroTime = 0.0.obs;

  void saveData() async {
    try{
      await FirebaseFirestore.instance.collection('user').add(data!.toJson());
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