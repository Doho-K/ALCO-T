import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

enum Shapes {
  circle,
  triangle,
  square,
  hexagon,
  star,
}

class SelectionPage extends StatefulWidget {
  final String userID;
  final int sessionID;

  SelectionPage({required this.userID, required this.sessionID});

  @override
  _SelectionState createState() => _SelectionState();
}

class _SelectionState extends State<SelectionPage> {
  Offset? offset;     // 현재 터치 위치
  int touchCount = 0; // 터치 시도 횟수

  Random random = Random();
  Size screenSize = Size(100,100);

  List<Figure> figures = [];// 도형 목록
  int num = 4;              // 그릴 도형 수
  int count = 0;

  DateTime? start;      // 문제 시작 시간
  int responseTime = 0; // 도형 고르는 데까지 걸린 시간
  Figure? selected;     // 고른 도형

  int targetIndex = -1; // 정답 도형 인덱스
  String? targetString;
  Color? targetColor;
  
  bool result = false;
  bool showProblemWidget = false;

  _SelectionPainter? _painter;

  final Map<String, Color> palette = {
    "red" : Colors.red,
    "orange" : Colors.orange,
    "yellow" : Colors.yellow,
    "green" : Colors.green,
    "blue" : Colors.blue,
    "purple" : Colors.purple,
    "brown" : Colors.brown,
    "gray" : Color.fromRGBO(100, 100, 100, 10),
  };

  SelectionDataCollector? collector;

  @override
  void initState(){
    super.initState();
    collector = SelectionDataCollector(userID: widget.userID, sessionID: widget.sessionID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("도형 선택 문제")),
      backgroundColor: Colors.white70,
      body: (showProblemWidget)? ((selected!=null)? resultWidget() : problemWidget()) : initWidget()
    );
  }

  Widget initWidget(){
    return LayoutBuilder(
      builder: (context, constraints) {
        screenSize = Size(constraints.maxWidth, constraints.maxWidth * 1.8);
        return Center(
          child: GestureDetector(
            onPanEnd: (DragEndDetails event) {
              setState(() {
                showProblemWidget = true;
                randomFigures(num);
                start = DateTime.now();
              });
            },
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("터치하면 시작합니다", style: TextStyle(fontSize: 35, color: Colors.black,), textAlign: TextAlign.center,),
                Text("화면 상단의 텍스트가 지시하는 도형을 터치하세요", style: TextStyle(fontSize: 15, color: Colors.black), textAlign: TextAlign.center,),
                Text("텍스트의 색은 정답과 상관이 없습니다", style: TextStyle(fontSize: 15, color: Colors.black), textAlign: TextAlign.center,),
              ],
            )
          )
        );
      }
    );
  }


  Widget problemWidget(){
    _painter = _SelectionPainter(offset: offset, onSelect: _onSelect, size: screenSize, palette: palette, figures: figures);
    return Column(children: [
      Container(
        alignment: Alignment.center,
        color: Colors.black,
        padding: EdgeInsets.only(bottom: 5, top: 5),
        child: Text(
          targetString!,
          style: TextStyle(color: targetColor, fontSize: 30),
        )
      ),
      Center(
        child: GestureDetector(
          onPanStart: _onPanStart,
          onPanEnd: _onPanEnd,
          child: CustomPaint(
            painter: _painter,
            size: screenSize,
          )
        )
      )
    ],);
  }

  Widget resultWidget(){
    String resultStr;
    Color color;
    if(result){
      resultStr = "정답";
      color = Colors.blue;
    }
    else{
      resultStr = "오답";
      color = Colors.red;
    }

    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            resultStr,
            style: TextStyle(color: color, fontSize: 100),
            textAlign: TextAlign.center,
          ),
          Text(
            "$responseTime ms",
            style: TextStyle(color: color, fontSize: 50),
            textAlign: TextAlign.center,
          )
        ]
      )
    );
  }

  void _onPanStart(DragStartDetails event) {
    setState(() => offset = event.localPosition);
    responseTime = DateTime.now().difference(start!).inMilliseconds;
    touchCount++;
  }

  void _onPanEnd(DragEndDetails event){
    if(selected != null){
      Offset selected_offset = selected!.offset;
      String selected_color = getColorEng(selected!.color)!;
      String selected_shape = getShapeEng(selected!.shape);

      Offset answer_offset = figures[targetIndex].offset;
      String answer_color = getColorEng(figures[targetIndex].color)!;
      String answer_shape = getShapeEng(figures[targetIndex].shape);

      Offset touched_offset = offset!;
      int touch_duration = DateTime.now().difference(start!).inMilliseconds - responseTime;

      result = (selected == figures[targetIndex]);

      collector!.setData(selectionDataModel(result, num, selected_offset, selected_color, selected_shape, answer_offset, answer_color, answer_shape, touched_offset, touchCount, responseTime, touch_duration));
      collector!.saveData();

      num++;
      setState(() {});
      Future.delayed(Duration(seconds: 1), () {
        if(num < 7){
          setState(() {
            randomFigures(num);
            offset = null;
            selected = null;
            touchCount = 0;
            result = false;
            start = DateTime.now();
          });
        }
        else{
          Navigator.pop(context);
        }
      });
    }
  }

  void _onSelect(int index){
    selected = figures[index];
  }

  List<Offset> getOffsetList(Size screenSize, int num){
    List<Offset> offsetList = [];
    double mid_x = screenSize.width/2;
    double mid_y = screenSize.height/2;
    double padding = 10;
    double d = screenSize.width/4 + padding;
    switch(num){
    case 3:
      offsetList.add(Offset(mid_x,mid_y-d));
      offsetList.add(Offset(mid_x,mid_y));
      offsetList.add(Offset(mid_x,mid_y+d));
      break;
    case 4:
      offsetList.add(Offset(mid_x,mid_y-d));
      offsetList.add(Offset(mid_x+d,mid_y));
      offsetList.add(Offset(mid_x,mid_y+d));
      offsetList.add(Offset(mid_x-d,mid_y));
      break;
    case 5:
      offsetList.add(Offset(mid_x-d,mid_y-d));
      offsetList.add(Offset(mid_x+d,mid_y-d));
      offsetList.add(Offset(mid_x-d,mid_y));
      offsetList.add(Offset(mid_x+d,mid_y));
      offsetList.add(Offset(mid_x,mid_y+d));
      break;
    case 6:
      offsetList.add(Offset(mid_x-d,mid_y-d));
      offsetList.add(Offset(mid_x+d,mid_y-d));
      offsetList.add(Offset(mid_x-d,mid_y));
      offsetList.add(Offset(mid_x+d,mid_y));
      offsetList.add(Offset(mid_x-d,mid_y+d));
      offsetList.add(Offset(mid_x+d,mid_y+d));
      break;
    }
    offsetList.shuffle();
    return offsetList;
  }

  String getShapeKor(Shapes shape){
    switch(shape){
      case Shapes.circle:
        return "원";
      case Shapes.triangle:
        return "삼각형";
      case Shapes.square:
        return "사각형";
      case Shapes.hexagon:
        return "육각형";
      case Shapes.star:
        return "별";
    }
  }

  String getShapeEng(Shapes shape){
    switch(shape){
      case Shapes.circle:
        return "circle";
      case Shapes.triangle:
        return "triangle";
      case Shapes.square:
        return "square";
      case Shapes.hexagon:
        return "hexagon";
      case Shapes.star:
        return "star";
    }
  }

  String getColorEng(Color color){
    for (var pal in palette.entries){
      if(pal.value == color){
        return pal.key;
      }
    }
    return "";
  }
  
  String getColorKor(Color color){
    String colorString = getColorEng(color);
    switch(colorString){
    case "red":
      colorString = "빨간색";
      break;
    case "orange":
      colorString = "주황색";
      break;
    case "yellow":
      colorString = "노란색";
      break;
    case "green":
      colorString = "초록색";
      break;
    case "blue":
      colorString = "파란색";
      break;
    case "purple":
      colorString = "보라색";
      break;
    case "brown":
      colorString = "갈색";
      break;
    case "gray":
      colorString = "회색";
      break;
    }
    return colorString;
  }

  void setTarget(){
    Figure targetFigure = figures[targetIndex];
    bool dup_shape = false;
    bool dup_color = false;
    
    for(var figure in figures){
      if(figure == targetFigure){
        continue;
      }
      if(figure.shape == targetFigure.shape){
        dup_shape = true;
      }
      if(figure.color == targetFigure.color){
        dup_color = true;
      }
    }

    if(!dup_shape && !dup_color){
      if(random.nextDouble()<0.5){
        targetString = getShapeKor(targetFigure.shape);
      }
      else{
        targetString = getColorKor(targetFigure.color);
      }
    }
    else if(dup_shape && dup_color){
      targetString = getColorKor(targetFigure.color) + " " + getShapeKor(targetFigure.shape);
    }
    else{
      if(dup_shape){
        targetString = getColorKor(targetFigure.color);
      }
      else{
        targetString = getShapeKor(targetFigure.shape);
      }
    }

    if(random.nextDouble()<0.5){
      targetColor = targetFigure.color;
    }
    else{
      targetColor = palette.values.toList()[random.nextInt(palette.length)];
    }
  }

  void randomFigures(int num){
    final double figureSize = screenSize.width/4;
    List<Offset> offsetList = getOffsetList(screenSize, num);
    figures = [];
    while(figures.length < num){
      bool isNew = true;

      Color newColor = palette[palette.keys.toList()[random.nextInt(palette.length)]]!;
      Shapes newShape = Shapes.values[random.nextInt(Shapes.values.length)];

      for(var fig in figures){
        if(fig.color == newColor && fig.shape == newShape){
          isNew = false;
          break;
        }
      }
      if(isNew){
        Offset newOffset = offsetList.last;
        offsetList.removeLast();
        Figure newFigure = Figure(color: newColor, shape: newShape, offset: newOffset, size: figureSize);
        figures.add(newFigure);
      }
    }
    targetIndex = random.nextInt(num);
    setTarget();
  }
}

class _SelectionPainter extends CustomPainter {
  Size size;

  final Offset? offset;
  final Function(int index) onSelect;

  List<Figure> figures;

  final Map<String, Color> palette;

  _SelectionPainter({
    required this.offset,
    required this.onSelect,
    required this.size,
    required this.palette,
    required this.figures,
  }) {}

  Paint _painter(Color color) {
    return Paint()
      ..color = color
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int i=0; i<figures.length; i++){
      figures[i].draw(canvas, _painter(figures[i].color));
    }
    if(offset!=null){
      for (int i=0; i<figures.length; i++){
        if(figures[i].getPath().contains(offset!)) {
          onSelect(i);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_SelectionPainter oldDelegate) {
    return true;
  }
}

class Figure{
  Color color;
  Shapes shape;
  Offset offset;
  double size;

  Figure({required this.color, required this.shape, required this.offset, required this.size}){}

  // 도형의 Path 구하기
  Path getPath(){
    Path result = Path();
    double d1 = (size/2);
    double d2 = (size/4);
    double d3 = d2 * sqrt(3);
    switch(shape){
      case Shapes.circle:
        var rect = Rect.fromCircle(radius: size/2, center: offset);
        result = Path()..addOval(rect);
        break;
      case Shapes.triangle:
        result.moveTo(offset.dx, offset.dy-d3);
        result.lineTo(offset.dx-d1, offset.dy+d3);
        result.lineTo(offset.dx+d1, offset.dy+d3);
        result.close();
        break;
      case Shapes.square:
        var rect = Rect.fromCircle(radius: size/2, center: offset);
        result = Path()..addRect(rect);
        break;
      case Shapes.hexagon:
        result.moveTo(offset.dx+d2, offset.dy-d3);
        result.lineTo(offset.dx-d2, offset.dy-d3);
        result.lineTo(offset.dx-d1, offset.dy);
        result.lineTo(offset.dx-d2, offset.dy+d3);
        result.lineTo(offset.dx+d2, offset.dy+d3);
        result.lineTo(offset.dx+d1, offset.dy);
        result.close();
        break;
      case Shapes.star:
        double w = size;
        double h = w * sin(72 * pi / 180);
        double a = w / 2 / cos(36 * pi / 180);
        double y1 = offset .dy - h/2 + a*sin(36 * pi / 180);
        result.moveTo(offset.dx, offset.dy-h/2);
        result.lineTo(offset.dx-a/2, offset.dy+h/2);
        result.lineTo(offset.dx+w/2, y1);
        result.lineTo(offset.dx-w/2, y1);
        result.lineTo(offset.dx+a/2, offset.dy+h/2);
        result.close();
        break;
    }
    return result;
  }

  void draw(Canvas canvas, Paint painter) {
    var path = getPath();
    canvas.drawPath(path, painter);
  }
}

class SelectionDataCollector extends GetxController{
  String userID;
  int sessionID;
  selectionDataModel? _data;

  SelectionDataCollector({required this.userID, required this.sessionID});

  void setData(selectionDataModel dataInstance){
    _data = dataInstance;
    _data!.userID = userID;
    _data!.sessionID = sessionID;
  }

  void saveData() async {
    try{
      await FirebaseFirestore.instance.collection('selection').add(_data!.toJson());
    }
    catch(e){
      print(e);
    }
  }

}

class selectionDataModel{
  String userID = ""; // 유저 정보와 연결하기 위함
  int sessionID = 0;  // 한 번의 테스트당 복수 개의 패턴을 그리므로, 각 테스트를 하나의 세션으로 구분
  int _numOfFigs = 0;  // 문제에서 주어진 도형 수

  Timestamp? _submitTime;

  bool _success = false;

  double _selected_x = 0, _selected_y = 0;
  String _selected_color = "";
  String _selected_shape = "";

  double _answer_x = 0, _answer_y = 0;
  String _answer_color = "";
  String _answer_shape = "";

  double _touched_x = 0, _touched_y = 0;
  int _touch_count = 0;
  
  int _responseTime = 0;
  int _touch_duration = 0;

  selectionDataModel(bool success, int numOfFigs, Offset selected_offset, String selected_color, String selected_shape, Offset answer_offset, String answer_color, String answer_shape, Offset touched_offset, int touchCount, int responseTime, int touch_duration){
    _success = success;
    _numOfFigs = numOfFigs;
    _selected_x = selected_offset.dx;
    _selected_y = selected_offset.dy;
    _selected_color = selected_color;
    _selected_shape = selected_shape;
    _answer_x = answer_offset.dx;
    _answer_y = answer_offset.dy;
    _answer_color = answer_color;
    _answer_shape = answer_shape;
    _touched_x = touched_offset.dx;
    _touched_y = touched_offset.dy;
    _touch_count = touchCount;
    _responseTime = responseTime;
    _touch_duration = touch_duration;
  }

  selectionDataModel.fromJson(Map<String, dynamic> json)
      : userID = json['userID'],
        sessionID = json['sessionID'],
        _success = json['success'],
        _numOfFigs = json['numberOfFigures'],
        _submitTime = json['submitTime'],
        _selected_x = json['selected_x'],
        _selected_y = json['selected_y'],
        _selected_color = json['selected_color'],
        _selected_shape = json['selected_shape'],
        _answer_x = json['answer_x'],
        _answer_y = json['answer_y'],
        _answer_color = json['answer_color'],
        _answer_shape = json['answer_shape'],
        _touched_x = json['touched_x'],
        _touched_y = json['touched_y'],
        _touch_count = json['touch_count'],
        _responseTime = json['responseTime'],
        _touch_duration = json['touch_duration'];

  Map<String,dynamic> toJson(){
    return {
      'userID': userID,
      'sessionID': sessionID,
      'success': _success,
      'numberOfFigures': _numOfFigs,
      'submitTime': _submitTime ?? FieldValue.serverTimestamp(),
      'selected_x': _selected_x,
      'selected_y': _selected_y,
      'selected_color': _selected_color,
      'selected_shape': _selected_shape,
      'answer_x': _answer_x,
      'answer_y': _answer_y,
      'answer_color': _answer_color,
      'answer_shape': _answer_shape,
      'touched_x': _touched_x,
      'touched_y': _touched_y,
      'touch_count': _touch_count,
      'responseTime': _responseTime,
      'touch_duration': _touch_duration,
    };
  }
}