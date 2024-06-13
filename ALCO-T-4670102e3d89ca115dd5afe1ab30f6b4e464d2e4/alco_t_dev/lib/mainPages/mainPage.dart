import 'package:alco_t_dev/DataCollector.dart';
import 'package:alco_t_dev/mainPages/main_home.dart';
import 'package:alco_t_dev/mainPages/main_map.dart';
import 'package:alco_t_dev/mainPages/main_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class mainPage extends StatefulWidget {
  const mainPage({Key? key}) : super(key: key);

  @override
  State<mainPage> createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  final myController = Get.put(DataCollector());
  int selectedIndex = 0;
  List<Widget> _pages = [
    main_home(),
    main_map(),
    main_user()
  ];
  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('안녕하세요! ${myController.userName.value}', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Color.fromRGBO(255, 77, 77, 1)
      ),
      body: Container(
        height: MediaQuery.of(context).size.height-100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
          child: _pages[selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '네비게이션',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '내 정보',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Color.fromRGBO(255, 77, 77, 1),
        onTap: onItemTapped,
      ),
    );
  }
}