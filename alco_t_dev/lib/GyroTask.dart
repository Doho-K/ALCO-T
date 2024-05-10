import 'package:alco_t_dev/DataCollector.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'package:get/get.dart';
import 'dart:math';

class GyroTask extends StatefulWidget {
  @override
  _GyroTaskState createState() => _GyroTaskState();
}

class _GyroTaskState extends State<GyroTask> {
  static const Duration _ignoreDuration = Duration(milliseconds: 20);

  AccelerometerEvent? _accelerometerEvent;
  GyroscopeEvent? _gyroscopeEvent;

  DateTime? _accelerometerUpdateTime;
  DateTime? _gyroscopeUpdateTime;

  int? _accelerometerLastInterval;
  int? _gyroscopeLastInterval;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  Duration sensorInterval = SensorInterval.normalInterval;
  final myController = Get.put(DataCollector());
  Timer? _timer;
  int _count = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gyro Task'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('$_count',style: TextStyle(fontSize: 48),),
            /*Text(
              'ACCELEROMETER',
              style: TextStyle(fontSize: 20),
            ),
            Text(myController.gyroX.value.toString() ?? '?'),
            Text(_accelerometerEvent?.y.toStringAsFixed(1) ?? '?'),
            Text('Gyro'),
            Text(_gyroscopeEvent?.x.toStringAsFixed(1) ?? '?'),
            Text(_gyroscopeEvent?.y.toStringAsFixed(1) ?? '?'),*/
            //Countdown(),
            MovingBall(initialX: 0.0, initialY: 0.0),

          ],
        ),
      ),
    );



  }
  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _streamSubscriptions.add(
      accelerometerEventStream(samplingPeriod: sensorInterval).listen(
            (AccelerometerEvent event) {
          final now = DateTime.now();
          setState(() {
            _accelerometerEvent = event;
            if (_accelerometerUpdateTime != null) {
              final interval = now.difference(_accelerometerUpdateTime!);
              if (interval > _ignoreDuration) {
                _accelerometerLastInterval = interval.inMilliseconds;
              }
            }
            myController.gyroX.value = _accelerometerEvent!.x.toDouble();
            myController.gyroY.value = _accelerometerEvent!.y.toDouble();
          });
          _accelerometerUpdateTime = now;
        },
        onError: (e) {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text("Sensor Not Found"),
                  content: Text(
                      "It seems that your device doesn't support Accelerometer Sensor"),
                );
              });
        },
        cancelOnError: true,
      ),
    );
    _streamSubscriptions.add(
      gyroscopeEventStream(samplingPeriod: sensorInterval).listen(
            (GyroscopeEvent event) {
          final now = DateTime.now();
          setState(() {
            _gyroscopeEvent = event;
            if (_gyroscopeUpdateTime != null) {
              final interval = now.difference(_gyroscopeUpdateTime!);
              if (interval > _ignoreDuration) {
                _gyroscopeLastInterval = interval.inMilliseconds;
              }
            }
          });
          _gyroscopeUpdateTime = now;

        },
        onError: (e) {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text("Sensor Not Found"),
                  content: Text(
                      "It seems that your device doesn't support Gyroscope Sensor"),
                );
              });
        },
        cancelOnError: true,
      ),
    );
  }
  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_count > 0) {
        setState(() {
          _count--;
        });
      }
      else {
        timer.cancel();
        myController.initY.value = _accelerometerEvent!.y.toDouble()-2;
        myController.taskStart.value = true;

      }
    });
  }
}

class MovingBall extends StatefulWidget {
  final double initialX;
  final double initialY;


  MovingBall({required this.initialX, required this.initialY});
  @override
  _MovingBallState createState() => _MovingBallState();
}

class _MovingBallState extends State<MovingBall> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  final myController = Get.put(DataCollector());
  Random random = Random();

  int missionIndex = 0;
  // 공의 현재 위치
  double _x = 0.0;
  double _y = 0;
  int missionX = 0;
  int missionY = 0;
  Stopwatch stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    missionIndex = random.nextInt(4);
    if(missionIndex==0){
      missionX = -140;
      missionY = 200;
    }
    else if(missionIndex==1){
      missionX = 140;
      missionY = 200;
    }
    else if(missionIndex==2){
      missionX = -140;
      missionY = -200;
    }
    else{
      missionX = 140;
      missionY = -200;
    }

    Timer.periodic(Duration(milliseconds: 50), (timer) {
      setState(() {
        if(myController.taskStart.value == true){
          if(stopwatch.isRunning == false){
            stopwatch.start();
          }
          if(_x<=200&&_x>=-200){
            _x = _x-myController.gyroX.value.toDouble();
          }
          else{
            if(_x>0){
              _x = 200;
            }
            else{
              _x = -200;
            }
          }
          if(_y<=300&&_y>=-400){
            _y = _y+myController.gyroY.value.toDouble()-myController.initY.value.toDouble();
          }
          else{
            if(_y>0){
              _y = 300;
            }
            else{
              _y = -400;
            }
          }
          if(distanceBetweenPoints(_x, _y, missionX.toDouble(), missionY.toDouble())<3){
            myController.taskStart.value = false;
            myController.gyroTime.value = stopwatch.elapsedMilliseconds.toDouble();
            stopwatch.stop();
          }
        }

      });
    });
  }

  /*void setBallPosition(double x, double y) {
    setState(() {
      _x = x;
      _y = y;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }*/
  double distanceBetweenPoints(double x1, double y1, double x2, double y2) {
    double dx = x2 - x1;
    double dy = y2 - y1;
    return sqrt(dx * dx + dy * dy);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Text(myController.initY.value.toString()),
          Text(myController.gyroY.value.toString()),
          Text(myController.gyroTime.value.toString()),
          CustomPaint(
            painter: BallPainter(_x, _y),
          ),
          CustomPaint(
            painter: BallPainter2(missionX.toDouble(), missionY.toDouble()),
          )
        ],
      ),
    );
  }
}

class BallPainter extends CustomPainter {
  final double x;
  final double y;

  BallPainter(this.x, this.y);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.blue;
    canvas.drawCircle(Offset(x, y), 20, paint);
  }

  @override
  bool shouldRepaint(BallPainter oldDelegate) => true;
}

class BallPainter2 extends CustomPainter {
  final double x;
  final double y;

  BallPainter2(this.x, this.y);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(x, y), 20, paint);
  }

  @override
  bool shouldRepaint(BallPainter2 oldDelegate) => true;
}

class Countdown extends StatefulWidget {
  @override
  _CountdownState createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  int _count = 3;

  @override
  void initState() {
    super.initState();

    // 1초마다 _count를 1씩 감소시키는 타이머 설정
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_count > 0) {
        setState(() {
          _count--;
        });
      } else {
        timer.cancel(); // 타이머 취소
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_count',
      style: TextStyle(fontSize: 48),
    );
  }
}