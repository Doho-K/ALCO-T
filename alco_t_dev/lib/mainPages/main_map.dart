import 'package:alco_t_dev/DataCollector.dart';
import 'package:alco_t_dev/MapSearchPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class main_map extends StatefulWidget {
  const main_map({Key? key}) : super(key: key);

  @override
  State<main_map> createState() => _main_mapState();
}

class _main_mapState extends State<main_map> {
  final myController = Get.put(DataCollector());
  @override
  Widget build(BuildContext context) {
    return MapSearchPage();
  }
}