import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverCall extends StatefulWidget {
  @override
  _DriverCallState createState() => _DriverCallState();
}
class Driver {
  final String name;
  final String phoneNumber;
  final String carModel;
  final String carNumber;

  Driver({
    required this.name,
    required this.phoneNumber,
    required this.carModel,
    required this.carNumber,
  });
}
class _DriverCallState extends State<DriverCall> {
  final List<Driver> drivers = [
    Driver(name: '김 기사', phoneNumber: '123-456-7890', carModel: '현대 소나타', carNumber: '01ABC1234'),
    Driver(name: '박 기사', phoneNumber: '987-654-3210', carModel: '기아 스포티지', carNumber: '02XYZ5678'),
    Driver(name: '이 기사', phoneNumber: '555-666-7777', carModel: '도요타 콜로라', carNumber: '03LMN9101'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('대리운전 매칭',style: TextStyle(color: Colors.black,fontSize: 15,fontWeight: FontWeight.w600)), backgroundColor: Color.fromRGBO(255, 77, 77, 1)
      ),
      body: ListView.builder(
        itemCount: drivers.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: Icon(Icons.person, size: 50),
              title: Text(drivers[index].name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('전화번호: ${drivers[index].phoneNumber}'),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DriverDetailPage(driver: drivers[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DriverDetailPage extends StatelessWidget {
  final Driver driver;

  DriverDetailPage({required this.driver});

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('기사님 정보', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: Color.fromRGBO(255, 77, 77, 1)
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 100),
            SizedBox(height: 16),
            Text('기사님 이름: ${driver.name}', style: TextStyle(fontSize: 24)),
            SizedBox(height: 16),
            Text('전화번호: ${driver.phoneNumber}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('운전 차종: ${driver.carModel}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('대리 고유 번호: ${driver.carNumber}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _makePhoneCall(driver.phoneNumber);
              },
              child: Text('기사님께 연결'),
            ),
          ],
        ),
      ),
    );
  }
}
