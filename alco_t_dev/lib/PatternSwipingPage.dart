import 'package:flutter/material.dart';
import 'dart:math';
//import 'package:sensors_plus/sensors_plus.dart';


class PatternSwipingPage extends StatefulWidget {
  @override
  _PatternSwipingState createState() => _PatternSwipingState();
}

class _PatternSwipingState extends State<PatternSwipingPage> {
  Offset? offset;           // 현재 터치 위치
  List<int> codes = [];     // 지나간 원 순서
  List<List<int>> guidelines = [
    [6,1,8,7,3],
    [0,4,2,5,7,3],
    [0,1,2,4,6,7,8],
    [3,1,5,7,0],
  ];  // 그려야 될 패턴
  DateTime? start;          // 시작 시간. 처음으로 원에 닿은 시간을 기준으로 함
  List<Offset> pos = [];    // 움직인 위치 기록(x,y)
  List<int> pos_time = [];  // 움직인 시간 기록(ms)
  /*
  List<List<double>> acc = []; // 가속도계 기록(x,y,z)
  List<List<double>> gyro = []; // 자이로 기록(x,y,z)
  bool acc_available = false;
  bool gyro_available = false;
  Duration sensorInterval = SensorInterval.normalInterval;
  */

  Random random = Random();
  int guidelineIndex = 0;


  @override
  void initState(){
    super.initState();
    guidelineIndex = random.nextInt(guidelines.length);
  }

  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    var _sizePainter = Size.square(_width * 2/3);
    return Scaffold(
        // appBar: AppBar(title: Text(widget.title)),
        backgroundColor: Colors.white70,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.only(bottom: _width/16),
                child: const Text("아래 패턴을 따라 그리세요", style: TextStyle(fontSize: 16)),
              )
            ),
            Expanded(
              flex: 4,
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: _sizePainter.width/4, right: _sizePainter.width/4),
                decoration: BoxDecoration(
                    color: const Color.fromRGBO(64, 64, 64, 16),
                    borderRadius: BorderRadius.circular(12)),
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    painter: _LockScreenPainter(
                        codes: codes, offset: offset, onSelect: _onSelect, guidelines: guidelines, guidelineIndex: guidelineIndex),
                    size: _sizePainter,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container()
            ),
          ],
        ),
      );
  }

  void _onPanStart(DragStartDetails event) {
    _clearCodes();
    start = DateTime.now();
  }

  void _onPanUpdate(DragUpdateDetails event) {
    if (codes.isEmpty){
      start = DateTime.now(); // 처음 원을 지날 때를 시작 기준으로 한다
    }
    else{
      // 움직임 기록
      pos_time.add(DateTime.now().difference(start!).inMilliseconds);
      pos.add(event.localPosition);
      /*
      // 가속도계 기록
      if(acc_available){
        accelerometerEventStream(samplingPeriod: sensorInterval).listen(
          (AccelerometerEvent event) {
            acc.add([event.x,event.y,event.z]);
          },
          onError: (e) {
            acc_available = false;
          },
          cancelOnError: true,
        );
      }
      // 자이로 기록
      if(gyro_available){
        gyroscopeEventStream(samplingPeriod: sensorInterval).listen(
          (GyroscopeEvent event) {
            gyro.add([event.x,event.y,event.z]);
          },
          onError: (e) {
            gyro_available = false;
          },
          cancelOnError: true,
        );
      }
      */
    }
    setState(() => offset = event.localPosition);
  }

  void _onPanEnd(DragEndDetails event){
    if(codes.isNotEmpty){
      // 통과 여부 판단
      bool success = false;
      int len = guidelines[guidelineIndex].length;
      if (codes.length == len){
        success = true;
        if(codes[0] == guidelines[guidelineIndex][0]){
          for(int i=0; i<len; i++){
            if(codes[i]!=guidelines[guidelineIndex][i]){
              success = false;
              break;
            }
          }
        }
        else{
          for(int i=0; i<len; i++){
            if(codes[i]!=guidelines[guidelineIndex][len-1-i]){
              success = false;
              break;
            }
          }
        }
      }

      // 다음 패턴 선택
      if(success){
        guidelineIndex = random.nextInt(guidelines.length);
      }
      ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      // 학습 데이터 <pos.dx, pos.dy, pos_time, success> 전송
      ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    }
    _clearCodes();
  }

  _onSelect(int code) {
    if (codes.isEmpty || codes.last != code) {
      codes.add(code);
    }
  }

  _clearCodes() => setState(() {
    codes = [];
    offset = null;
    start = null;
    pos = [];
    pos_time = [];
  });
}


class _LockScreenPainter extends CustomPainter {
  final int _totalNode = 9;
  final int _col = 3;
  Size size = Size(0,0);

  final List<int> codes;
  final int guidelineIndex;
  final List<List<int>> guidelines;
  final Offset? offset;
  final Function(int code) onSelect;

  final Map<String, Color> _palette = {
    "white": Colors.white,
    "grey": Color.fromRGBO(128,128,128,64),
  };

  _LockScreenPainter({
    required this.codes,
    required this.offset,
    required this.onSelect,
    required this.guidelines,
    required this.guidelineIndex,
  });

  double get _gridSize => size.width / _col;

  Paint _painter(Color color, bool stroke) {
    return Paint()
      ..color = color
      ..style = (stroke? PaintingStyle.stroke : PaintingStyle.fill);
  }

  // 원 위치
  Offset _getOffsetByIndex(int i) {
    var _dxCode = _gridSize * (i % _col + .5);
    var _dyCode = _gridSize * ((i / _col).floor() + .5);
    var _offsetCode = Offset(_dxCode, _dyCode);
    return _offsetCode;
  }

  // 원 path
  Path _getCirclePath(Offset offset, double radius) {
    var _rect = Rect.fromCircle(radius: radius, center: offset);
    return Path()..addOval(_rect);
  }

  // 원 그리기
  void _drawCircle(Canvas canvas, Offset offset, double radius, Color color,
      [bool isDot = false]) {
    var _path = _getCirclePath(offset, radius);
    var _painter = this._painter(color, false);
    canvas.drawPath(_path, _painter);
  }

  // 선 그리기
  void _drawLine(Canvas canvas, Offset start, Offset end, Color? color) {
    var _painter = this._painter(color!, true)
      ..strokeWidth = 4.0;
    var _path = Path();
    _path.moveTo(start.dx, start.dy);
    _path.lineTo(end.dx, end.dy);
    canvas.drawPath(_path, _painter);
  }

  @override
  void paint(Canvas canvas, Size size) {
    this.size = size;
    final List<int> guideline = guidelines[guidelineIndex];

    for (var i = 0; i < _totalNode; i++) {
      // 원 그리기
      var _offset = _getOffsetByIndex(i);  // 원 위치
      var _radius = _gridSize / 2.0 * 0.12;  // 원 반지름
      _drawCircle(canvas, _offset, _radius, _palette["white"]!, true);

      // 아직 지나지 않은 원 위를 지나가면 선택에 추가
      var _pathGesture = _getCirclePath(_offset, _radius);
      if (offset != null && !codes.contains(i)){
        if(_pathGesture.contains(offset!)) {
          // 터치 위치가 원과 일치하는 경우
          onSelect(i);
        }
        else if(codes.isNotEmpty){
          // 선이 원에 닿은 경우
          Offset last = _getOffsetByIndex(codes.last);
          Offset v1 = offset! - last;
          Offset v2 = (_getOffsetByIndex(i) - last);
          if(((v2.direction - v1.direction).abs() < 0.08) && (v1.distance >= v2.distance)){
            v1 = v1*(v2.distance/v1.distance)*0.9981;
            if(_pathGesture.contains(last+v1)){
              onSelect(i);
            }
          }
        }
      }
    }

    // 가이드라인 그리기
    for(int i=1 ; i<guideline.length ; i++){
      var _start = _getOffsetByIndex(guideline[i-1]);
      var _end = _getOffsetByIndex(guideline[i]);
      _drawLine(canvas, _start, _end, _palette["grey"]);
    }

    // 지금까지 지난 경로 그리기
    for(int i=1; i<codes.length; i++){
      var _start = _getOffsetByIndex(codes[i-1]);
      var _end = _getOffsetByIndex(codes[i]);
      _drawLine(canvas, _start, _end, _palette["white"]);
    }
    // 마지막으로 선택된 원에서 현재 터치 위치를 잇는 직선 그리기
    if(offset != null && codes.isNotEmpty){
      var _start = _getOffsetByIndex(codes.last);
      _drawLine(canvas, _start, offset!, _palette["white"]);
    }
  }

  @override
  bool shouldRepaint(_LockScreenPainter oldDelegate) {
    return offset != oldDelegate.offset;
  }
}