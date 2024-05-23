import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PatternSwipingPage extends StatefulWidget {
  final String userID;
  final int sessionID;
  final int inPattern;
  final int randPattern;

  PatternSwipingPage({required this.userID, required this.sessionID, required this.inPattern, required this.randPattern});

  @override
  _PatternSwipingState createState() => _PatternSwipingState();
}

class _PatternSwipingState extends State<PatternSwipingPage> {
  Offset? offset;           // 현재 터치 위치
  List<int> codes = [];     // 지나간 원 순서
  List<int> passingTime = [];     // 해당 원을 지나간 시간
  List<List<int>> patternPool = [
    [0,1,6,5,8],
    [0,5,6,1,8],
    [3,1,5,7,0],
    [6,1,8,7,3],
    [0,4,2,5,7,3],
    [0,1,2,4,6,7,8],
    [0,1,3,4,5,7,8],
    [0,1,6,7,2,5,8],
    [0,7,3,4,5,1,8],
    [3,0,1,2,5,4,7],
    [7,6,4,2,1,0,8],
    [0,1,2,3,4,5,6,7,8],
    [3,0,1,2,5,4,6,7,8],
    [4,3,1,5,7,6,0,2,8],
    [6,3,7,0,4,8,1,5,2],
    [7,6,5,8,1,2,3,0,4],
  ];  // 그려야 될 패턴
  DateTime? start;          // 시작 시간. 처음으로 원에 닿은 시간을 기준으로 함
  List<Offset> pos = [];    // 움직인 위치 기록(x,y)
  List<int> pos_timestamp = [];   // 움직인 시간 기록(ms)
  List<List<double>> acc = [];    // 가속도계 기록(x,y,z)
  List<int> acc_timestamp = [];   // 가속도계 갱신 시간 기록(ms)
  List<List<double>> gyro = [];   // 자이로 기록(x,y,z)
  List<int> gyro_timestamp = [];  // 자이로 갱신 시간 기록(ms)
  bool acc_available = true;
  bool gyro_available = true;
  Duration sensorInterval = SensorInterval.normalInterval;

  Random random = Random();
  List<bool> inPool = [];
  int index = 0;
  List<int> pattern = [];
  List<Offset> grids = [];
  int trial = 0;

  final int INTERVAL = 5;  // 기록 간격
  int timeBefore = -100;       // 이전 기록 시간
  
  PatternDataCollector? collector;

  @override
  void initState(){
    super.initState();
    collector = PatternDataCollector(userID: widget.userID, sessionID: widget.sessionID);
    for(int i=0; i<widget.inPattern; i++){
      inPool.add(false);
    }
    for(int i=0; i<widget.randPattern; i++){
      inPool.add(true);
    }
    inPool.shuffle();
    setPattern();
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: const Text("아래 패턴을 따라 그리세요", style: TextStyle(fontSize: 16)),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: _width/16),
                      child: const Text("(빨간점부터 시작)", style: TextStyle(fontSize: 16)),
                    ),
                  ]
                )
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
                        codes: codes, offset: offset, onSelect: _onSelect, pattern: pattern, pos: pos, grids: grids),
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
    setState(() => offset = event.localPosition);
  }

  void _onPanUpdate(DragUpdateDetails event) {
    if (codes.isEmpty){
      start = DateTime.now(); // 처음 원을 지날 때를 시작 기준으로 한다
    }
    else{
      // 움직임 기록
      if(codes.length < pattern.length){
        int interval = DateTime.now().difference(start!).inMilliseconds;
        if(interval - timeBefore > INTERVAL){
          timeBefore = interval;
          pos_timestamp.add(interval);
          pos.add(event.localPosition);
        }
        // 가속도계 기록
        if(acc_available){
          accelerometerEventStream(samplingPeriod: sensorInterval).listen(
            (AccelerometerEvent event) {
              if(acc.isEmpty){
                acc.add([event.x,event.y,event.z]);
                acc_timestamp.add(interval);
              }
              else{
                var lastEvent = acc.last;
                if(lastEvent[0] != event.x || lastEvent[1] != event.y || lastEvent[2] != event.z){
                  acc.add([event.x,event.y,event.z]);
                  acc_timestamp.add(interval);
                }
              }
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
              if(gyro.isEmpty){
                gyro.add([event.x,event.y,event.z]);
                gyro_timestamp.add(interval);
              }
              else{
                var lastEvent = gyro.last;
                if(lastEvent[0] != event.x || lastEvent[1] != event.y || lastEvent[2] != event.z){
                  gyro.add([event.x,event.y,event.z]);
                  gyro_timestamp.add(interval);
                }
              }
            },
            onError: (e) {
              gyro_available = false;
            },
            cancelOnError: true,
          );
        }
      }
    }
    setState(() => offset = event.localPosition);
  }

  void _onPanEnd(DragEndDetails event){
    trial++;
    if(codes.isNotEmpty){
      // 통과 여부 판단
      bool success = false;
      int len = pattern.length;
      if (codes.length == len){
        success = true;
        for(int i=0; i<len; i++){
          if(codes[i]!=pattern[i]){
            success = false;
            break;
          }
        }
      }

      // 데이터를 파이어베이스에 전송
      collector!.setData(patternDataModel(index, trial, pattern, codes, passingTime, grids, inPool[index], success, pos_timestamp, pos, acc_timestamp, acc, gyro_timestamp, gyro));
      collector!.saveData();

      // 다음 패턴 선택
      if(success){
        index++;
        if(index < inPool.length){
          setPattern();
          trial = 0;
        }
        else{
          Navigator.pop(context);
        }
      }
    }
    _clearCodes();
  }

  _onSelect(int code) {
    if (codes.isEmpty || codes.last != code) {
      codes.add(code);
      passingTime.add(DateTime.now().difference(start!).inMilliseconds);
    }
  }

  _clearCodes() => setState(() {
    codes = [];
    passingTime = [];
    grids = [];
    offset = null;
    start = null;
    pos_timestamp = [];
    pos = [];
    acc_timestamp = [];
    acc = [];
    gyro_timestamp = [];
    gyro = [];
    timeBefore = -INTERVAL*2;
  });
  
  setPattern(){
    if(inPool[index]){
      pattern = patternPool[random.nextInt(patternPool.length)];
    }
    else{
      pattern = randomPattern();
    }
    grids = [];
  }
  randomPattern(){
    List<int> pattern = [];
    int length = random.nextInt(3)+5; // 패턴 길이 == 5~7
    pattern.add(random.nextInt(9)); // 시작점
    while(pattern.length != length){
      // 다음 점 선택
      int next = random.nextInt(9);
      if(pattern.contains(next)){
        continue;
      }

      // 다음 점과 직전 점 사이에 다른 미선택 점 있는지 확인
      int diff = next - pattern.last;
      if(diff<0){
        diff = -diff;
      }
      if(diff%2 == 0){
        if(diff == 4 && pattern.last != 2 && pattern.last != 6){
        }
        else if(diff == 2 && !((pattern.last%3==0 && next%3==2) || (pattern.last%3==2 && next%3==0))){
        }
        else{
          // 사잇점 있으면 해당 점 선택
          int mid = (next + pattern.last) ~/ 2;
          if(pattern.contains(mid)){
            if(pattern[pattern.length-2] == mid){
              // 가이드라인 표기 문제로, 1->2->0과 같은 순서의 패턴은 그리지 않는다
              continue;
            }
          }
          else{
            pattern.add(mid);
            if(pattern.length == length){
              break;
            }
          }
        }
      }
      pattern.add(next);
    }

    // 너무 간단한 패턴인지 확인. 패턴이 최소 3개의 직선으로 이루어지게
    int change = 0;
    for(int i=2; i<length; i++){
      List<int> A = [ pattern[i-2]~/3, pattern[i-2]%3 ];
      List<int> B = [ pattern[i-1]~/3, pattern[i-1]%3 ];
      List<int> C = [ pattern[i]~/3, pattern[i]%3 ];
      List<int> v1 = [ B[0]-A[0], B[1]-A[1] ];
      List<int> v2 = [ C[0]-B[0], C[1]-B[1] ];
      if(v1[0]!=v2[0] || v1[1]!= v2[1]){
        change++;
      }
    }
    if(change<3){
      pattern = randomPattern();
    }

    return pattern;
  }
}


class _LockScreenPainter extends CustomPainter {
  final int _totalNode = 9;
  final int _col = 3;
  Size size = Size(0,0);

  final List<int> codes;
  final List<int> pattern;
  final Offset? offset;
  final Function(int code) onSelect;

  final Map<String, Color> _palette = {
    "white": Colors.white,
    "grey": Color.fromRGBO(128,128,128,64),
    "red" : Colors.red,
  };

  final List<Offset> pos;

  final List<Offset> grids;

  _LockScreenPainter({
    required this.codes,
    required this.offset,
    required this.onSelect,
    required this.pattern,
    required this.pos,
    required this.grids,
  }){
    for(int i=0; i<9; i++){
      grids.add(_getOffsetByIndex(i));
    }
  }

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

    for (var i = 0; i < _totalNode; i++) {
      // 원 그리기
      var _offset = _getOffsetByIndex(i);  // 원 위치
      var _radius = _gridSize / 2.0 * 0.18;  // 원 반지름
      _drawCircle(canvas, _offset, _radius, _palette["white"]!, true);
      if(i == pattern[0]){
        _drawCircle(canvas, _offset, _radius, _palette["red"]!, true);
      }
      else{
          _drawCircle(canvas, _offset, _radius, _palette["white"]!, true);
      }

      /*
      // 기록된 pos 경로 그리기
      for(var j=1; j<pos.length; j++){
        _drawLine(canvas, pos[j-1], pos[j], Colors.red);
      }
      */

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
    for(int i=1 ; i<pattern.length ; i++){
      var _start = _getOffsetByIndex(pattern[i-1]);
      var _end = _getOffsetByIndex(pattern[i]);
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

class PatternDataCollector extends GetxController{
  String userID;
  int sessionID;
  patternDataModel? _data;

  PatternDataCollector({required this.userID, required this.sessionID});

  void setData(patternDataModel dataInstance){
    _data = dataInstance;
    _data!.userID = userID;
    _data!.sessionID = sessionID;
  }

  void saveData() async {
    try{
      await FirebaseFirestore.instance.collection('pattern').add(_data!.toJson());
    }
    catch(e){
      print(e);
    }
  }

}

class patternDataModel{
  String userID = ""; // 유저 정보와 연결하기 위함
  int sessionID = 0;  // 한 번의 테스트당 복수 개의 패턴을 그리므로, 각 테스트를 하나의 세션으로 구분
  
  int _patternCount = 0; // 몇 번째 패턴 시도중인지
  int _submitCount = 0;  // 해당 패턴에서 몇 번째 제출인지

  Timestamp? _submitTime;
  List<int> _pattern = [];
  List<int> _codes = [];
  List<int> _passingTime = [];
  List<double> _grids_x = [];
  List<double> _grids_y = [];
  bool _inPool = false;
  bool _success = false;

  List<int> _posTimestamp = [];
  List<double> _pos_x = [];
  List<double> _pos_y = [];
  List<int> _accTimestamp = [];
  List<double> _acc_x = [];
  List<double> _acc_y = [];
  List<double> _acc_z = [];
  List<int> _gyroTimestamp = [];
  List<double> _gyro_x = [];
  List<double> _gyro_y = [];
  List<double> _gyro_z = [];

  patternDataModel(int patternCount, int submitCount, List<int> pattern, List<int> codes, List<int> passingTime, List<Offset> grids, bool inPool, bool success, List<int> pos_timestamp, List<Offset> pos, List<int> acc_timestamp, List<List<double>> acc, List<int> gyro_timestamp, List<List<double>> gyro){
    _patternCount = patternCount;
    _submitCount = submitCount;
    _pattern = pattern;
    _codes = codes;
    _passingTime = passingTime;
    _grids_x = grids.map((offset) => offset.dx).toList();
    _grids_y = grids.map((offset) => offset.dy).toList();
    _inPool = inPool;
    _success = success;
    _posTimestamp = pos_timestamp;
    _pos_x = pos.map((offset) => offset.dx).toList();
    _pos_y = pos.map((offset) => offset.dy).toList();
    _accTimestamp = acc_timestamp;
    _acc_x = acc.map((accInstance) => accInstance[0]).toList();
    _acc_y = acc.map((accInstance) => accInstance[1]).toList();
    _acc_z = acc.map((accInstance) => accInstance[2]).toList();
    _gyroTimestamp = gyro_timestamp;
    _gyro_x = gyro.map((gyroInstance) => gyroInstance[0]).toList();
    _gyro_y = gyro.map((gyroInstance) => gyroInstance[1]).toList();
    _gyro_z = gyro.map((gyroInstance) => gyroInstance[2]).toList();
  }

  patternDataModel.fromJson(Map<String, dynamic> json)
      : userID = json['userID'],
        sessionID = json['sessionID'],
        
        _patternCount = json['patternCount'], 
        _submitCount = json['submitCount'],
        _submitTime = json['submitTime'],
        _pattern = json['pattern'],
        _codes = json['codes'],
        _passingTime = json['passingTime'],
        _grids_x = json['pattern_offset_x'],
        _grids_y = json['pattern_offset_y'],
        _inPool = json['inPool'],
        _success = json['success'],
        _posTimestamp = json['posTimestamp'],
        _pos_x = json['pos_x'],
        _pos_y = json['pos_y'],
        _accTimestamp = json['accTimestamp'],
        _acc_x = json['acc_x'],
        _acc_y = json['acc_y'],
        _acc_z = json['acc_z'],
        _gyroTimestamp = json['gyroTimestamp'],
        _gyro_x = json['gyro_x'],
        _gyro_y = json['gyro_y'],
        _gyro_z = json['gyro_z'];

  Map<String,dynamic> toJson(){
    return {
      'userID': userID,
      'sessionID': sessionID,
      'patternCount': _patternCount,
      'submitCount': _submitCount,
      'submitTime': _submitTime ?? FieldValue.serverTimestamp(),
      'pattern': _pattern,
      'codes': _codes,
      'passingTime': _passingTime,
      'pattern_offset_x': _grids_x,
      'pattern_offset_y': _grids_y,
      'inPool': _inPool,
      'success': _success,
      'posTimestamp': _posTimestamp,
      'pos_x': _pos_x,
      'pos_y': _pos_y,
      'accTimestamp': _accTimestamp,
      'acc_x': _acc_x,
      'acc_y': _acc_y,
      'acc_z': _acc_z,
      'gyroTimestamp': _gyroTimestamp,
      'gyro_x': _gyro_x,
      'gyro_y': _gyro_y,
      'gyro_z': _gyro_z,
    };
  }
}