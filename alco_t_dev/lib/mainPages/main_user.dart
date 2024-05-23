import 'package:alco_t_dev/DataCollector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class main_user extends StatefulWidget {
  const main_user({Key? key}) : super(key: key);

  @override
  State<main_user> createState() => _main_userState();
}

class _main_userState extends State<main_user> {
  final myController = Get.put(DataCollector());
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(padding: EdgeInsets.all(20.0),
        child: Column(

        ),
      ),
    );
  }

}