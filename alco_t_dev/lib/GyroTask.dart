import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';

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
            Text(
              'ACCELEROMETER',
              style: TextStyle(fontSize: 20),
            ),
            Text(_accelerometerEvent?.x.toStringAsFixed(1) ?? '?'),
            Text(_accelerometerEvent?.y.toStringAsFixed(1) ?? '?'),
            Text('Gyro'),
            Text(_gyroscopeEvent?.x.toStringAsFixed(1) ?? '?'),
            Text(_gyroscopeEvent?.y.toStringAsFixed(1) ?? '?'),
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
  // 공의 현재 위치
  double _x = 0.0;
  double _y = 0.0;

  // 공의 이동 속도
  double _speed = 2.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    // 좌표에 따라 움직이는 애니메이션 정의
    _animation = Tween<Offset>(
      begin: Offset(_x, _y),
      end: Offset(_x , _y ),
    ).animate(_controller)
      ..addListener(() {
        setState(() {
          _x = _animation.value.dx;
          _y = _animation.value.dy;
        });
      });

    // 애니메이션 시작
    _controller.repeat(reverse: true);

    Timer.periodic(Duration(microseconds: 100), (timer) {
      setState(() {
        _x = ;
        _y = ;
      });
    });
  }
  void setBallPosition(double x, double y) {
    setState(() {
      _x = x;
      _y = y;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: CustomPaint(
        painter: BallPainter(_x, _y),
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