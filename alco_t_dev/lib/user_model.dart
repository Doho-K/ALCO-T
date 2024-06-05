import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserModel extends ChangeNotifier {
  UserDataCollector _collector = UserDataCollector();

  User? _user;
  String? _name;
  double? _weight;
  double? _height;
  bool? _sex;

  User? get user => _user;
  String? get name => _name;
  double? get weight => _weight;
  double? get height => _height;
  bool? get sex => _sex;

  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  void setUserInfo(String name, double weight, double height, bool sex){
    _name = name;
    _weight = weight;
    _height = height;
    _sex = sex;

    _collector.setData(UserDataModel(user: _user!, name: name, weight: weight, height: height, sex: sex));
    _collector.saveData();
    
    notifyListeners();
  }
}

class UserDataCollector extends GetxController{

  UserDataModel? _data;

  void setData(UserDataModel dataInstance){
    _data = dataInstance;
  }

  void saveData() async {
    try{
      final querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('user', isEqualTo: _data!.user)
        .get();
      if (querySnapshot.docs.isNotEmpty) {
        // 이미 있는 유저면 추가하지 않고 필드값만 업데이트
        final docId = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('user')
            .doc(docId)
            .update(_data!.toJson());
      } else {
        // 처음 온 유저면 새로 추가
        await FirebaseFirestore.instance.collection('user').add(_data!.toJson());
      }
    } catch(e){
      print(e);
    }
  }
}

class UserDataModel{
  User user;
  String name;
  double weight;
  double height;
  bool sex;

  UserDataModel({required this.user, required this.name, required this.weight, required this.height, required this.sex});

  UserDataModel.fromJson(Map<String, dynamic> json)
      : user = json['user'],
        name = json['name'],
        weight = json['weight'],
        height = json['height'],
        sex = json['sex'];

  Map<String,dynamic> toJson(){
    return {
      'user': user,
      'name': name,
      'weight': weight,
      'height': height,
      'sex': sex,
    };
  }
}