library korean_keyboard;

import 'dart:ffi';

import 'package:alco_t_dev/DataCollector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class KoreanKeyboard extends StatefulWidget {
  KoreanKeyboard(
      {Key? key,
        required this.insert,
        required this.submit,
        required this.cancel})
      : super(key: key);
  final Function(List<String> value)? insert;
  final Function? submit;
  final Function? cancel;
  @override
  _KoreanKeyboardState createState() =>
      _KoreanKeyboardState(this.submit!, this.insert!, this.cancel!);
}

class _KoreanKeyboardState extends State<KoreanKeyboard> {
  Offset _position = Offset.zero;
  _KoreanKeyboardState(this.submit, this.changeText, this.cancel);
  List<String> wholeText = [];
  Function submit;
  Function changeText;
  Function cancel;
  final myController = Get.put(DataCollector());
  Stopwatch stopwatch = Stopwatch();
  Stopwatch stopwatch2 = Stopwatch();

  var specialKeys = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    [
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
    ],
    ['', '', '', '', '', '', '', '?', 'DEL'],
    ['BACK', 'ㄱㄴㄷ', 'SPACE', 'NEXT']
  ];

  var lowerKeys = [
    ['ㅂ', 'ㅈ', 'ㄷ', 'ㄱ', 'ㅅ', 'ㅛ', 'ㅕ', 'ㅑ', 'ㅐ', 'ㅔ'],
    [
      'ㅁ',
      'ㄴ',
      'ㅇ',
      'ㄹ',
      'ㅎ',
      'ㅗ',
      'ㅓ',
      'ㅏ',
      'ㅣ',
    ],
    ['SHIFT', 'ㅋ', 'ㅌ', 'ㅊ', 'ㅍ', 'ㅠ', 'ㅜ', 'ㅡ', 'DEL'],
    ['BACK', '123', 'SPACE', 'NEXT']
  ];

  var upperKeys = [
    ['ㅃ', 'ㅉ', 'ㄸ', 'ㄲ', 'ㅆ', 'ㅛ', 'ㅕ', 'ㅑ', 'ㅒ', 'ㅖ'],
    [
      'ㅁ',
      'ㄴ',
      'ㅇ',
      'ㄹ',
      'ㅎ',
      'ㅗ',
      'ㅓ',
      'ㅏ',
      'ㅣ',
    ],
    ['SHIFT', 'ㅋ', 'ㅌ', 'ㅊ', 'ㅍ', 'ㅠ', 'ㅜ', 'ㅡ', 'DEL'],
    ['BACK', '123', 'SPACE', 'NEXT']
  ];

  @override
  void initState() {
    super.initState();
  }

  List<String> initConsonantList = [
    'ㄱ',
    'ㄲ',
    'ㄴ',
    'ㄷ',
    'ㄸ',
    'ㄹ',
    'ㅁ',
    'ㅂ',
    'ㅃ',
    'ㅅ',
    'ㅆ',
    'ㅇ',
    'ㅈ',
    'ㅉ',
    'ㅊ',
    'ㅋ',
    'ㅌ',
    'ㅍ',
    'ㅎ'
  ];
  List<String> middleConsonantList = [
    'ㅏ',
    'ㅐ',
    'ㅑ',
    'ㅒ',
    'ㅓ',
    'ㅔ',
    'ㅕ',
    'ㅖ',
    'ㅗ',
    'ㅘ',
    'ㅙ',
    'ㅚ',
    'ㅛ',
    'ㅜ',
    'ㅝ',
    'ㅞ',
    'ㅟ',
    'ㅠ',
    'ㅡ',
    'ㅢ',
    'ㅣ'
  ];
  List<String> lastConsonantList = [
    '',
    'ㄱ',
    'ㄲ',
    'ㄱㅅ',
    'ㄴ',
    'ㄴㅈ',
    'ㄴㅎ',
    'ㄷ',
    'ㄹ',
    'ㄹㄱ',
    'ㄹㅁ',
    'ㄹㅂ',
    'ㄹㅅ',
    'ㄹㅌ',
    'ㄹㅍ',
    'ㄹㅎ',
    'ㅁ',
    'ㅂ',
    'ㅂㅅ',
    'ㅅ',
    'ㅆ',
    'ㅇ',
    'ㅈ',
    'ㅊ',
    'ㅋ',
    'ㅌ',
    'ㅍ',
    'ㅎ'
  ];

//list index = value
//1 = 132 자음 , 133 모음 자음
//2= 177(ㄱ 0번), 143(ㅏ 0번) 모음

  String decodeChild(int value) {
    if (value == -1) return '';
    return initConsonantList[value];
  }

  String decodeParent(int value) {
    if (value == -1) return '';
    return middleConsonantList[value];
  }

  int encodeChild(String value) {
    return initConsonantList.indexOf(value);
  }

  int encodeParent(String value) {
    return middleConsonantList.indexOf(value);
  }

  bool isParent(String value) {
    //모음(true)인지 자음(false)인지 구분
    return middleConsonantList.contains(value) ? true : false;
  }

  int lastConvertToInit(int lastValue) {
    return initConsonantList.indexOf(lastConsonantList[lastValue]);
  }

  void reset() {
    structList.add(KoreanStruct(initConsonant, middleConsonant, lastConsonant));
    initConsonant = -1;
    middleConsonant = -1;
    lastConsonant = -1;
  }

  void overFlow() {
    int temp = lastConsonant;
    lastConsonant = -1;
    wholeText[wholeText.length - 1] = mergeUnicode();
    reset();
    initConsonant = lastConvertToInit(temp);
  }

  int encodeLast(String value, int before) {
    String search;
    if (before == -1) {
      search = value;
    } else {
      search = decodeChild(lastConvertToInit(before)) + value;
    }
    return lastConsonantList.indexOf(search);
  }

  int mixParent(String value) {
    switch (decodeParent(middleConsonant)) {
      case 'ㅗ':
        if (value == 'ㅏ') return encodeParent('ㅘ');
        if (value == 'ㅐ') return encodeParent('ㅙ');
        if (value == 'ㅣ') return encodeParent('ㅚ');

        break;
      case 'ㅜ':
        if (value == 'ㅓ') return encodeParent('ㅝ');
        if (value == 'ㅔ') return encodeParent('ㅞ');
        if (value == 'ㅣ') return encodeParent('ㅟ');
        break;
      case 'ㅡ':
        if (value == 'ㅣ') return encodeParent('ㅢ');
        break;
    }
    return middleConsonant;
  }

  void delete() {
    if (lastConsonant >= 0) {
      if (isStacking(lastConsonant) > 0) {
        int stackingIntolast =
        encodeLast(lastConsonantList[lastConsonant][0], -1);
        lastConsonant = stackingIntolast;
        wholeText[wholeText.length - 1] = mergeUnicode();
      } else {
        lastConsonant = -1;
        wholeText[wholeText.length - 1] = mergeUnicode();
      }
    } else if (lastConsonant == -1 && middleConsonant >= 0) {
      middleConsonant = -1;
      wholeText[wholeText.length - 1] = decodeChild(initConsonant);
    } else if (initConsonant >= 0) {
      initConsonant = -1;
      if (wholeText.length > 0) {
        wholeText.removeLast();
        if (structList.length > 0) structList.removeLast();
      }
    } else {
      if (wholeText.length > 0) {
        wholeText.removeLast();
        if (structList.length > 0) structList.removeLast();
      }
    }
  }

  void toInitState() {
    wholeText.clear();
    structList.clear();
    initConsonant = -1;
    middleConsonant = -1;
    lastConsonant = -1;
  }

  void insert(String key) {
    if (key == '') {
    } else if (key == '123' || key == 'ㄱㄴㄷ') {
      pressedNumMode = !pressedNumMode;
      setState(() {});
    } else if (key == 'SPACE') {
      reset();
      wholeText.add(' ');
    } else if (key == 'SHIFT') {
      pressedSHIFT = !pressedSHIFT;
      setState(() {});
      return;
    } else if (key == '→') {
      reset();
      // return;
    } else if (key == 'BACK') {
      reset();
      wholeText.clear();
      structList.clear();
      wholeText = cancel() ?? [];
      return;
    } else if (key == 'NEXT') {
      toInitState();
      wholeText = submit() ?? [];
      return;
    } else if (key == 'DEL') {
      delete();
    } else if (isParent(key)) {
      //모음인 경우
      if (initConsonant == -1 && middleConsonant == -1 && lastConsonant == -1) {
        //중성까지 있는 경우 or 아무것도 없는 경우
        reset();
        middleConsonant = encodeParent(key);
        wholeText.add(key);
      } else if (middleConsonant >= 0 && lastConsonant == -1) {
        //중성까지 있는 경우
        middleConsonant = mixParent(key);
        if (initConsonant == -1) {
          //모음만 있는 경우
          wholeText[wholeText.length - 1] = decodeParent(middleConsonant);
        } else {
          //초성, 중성이 있는 경우
          wholeText[wholeText.length - 1] = mergeUnicode();
        }
      } else if (initConsonant >= 0 && middleConsonant == -1) {
        middleConsonant = encodeParent(key);
        wholeText[wholeText.length - 1] = mergeUnicode();
      } else if (lastConsonant >= 0) {
        //초, 중, 종성이 모두 있는 경우
        if (isStacking(lastConsonant) != -1) {
          //겹받침이라면
          int stackingIntoInit = isStacking(lastConsonant);
          int stackingIntolast =
          encodeLast(lastConsonantList[lastConsonant][0], -1);
          lastConsonant = stackingIntolast;
          wholeText[wholeText.length - 1] = mergeUnicode();
          reset();
          initConsonant = stackingIntoInit;
          middleConsonant = encodeParent(key);
          wholeText.add(mergeUnicode());
        } else {
          //홀받침이라면
          overFlow();
          middleConsonant = encodeParent(key);
          wholeText.add(mergeUnicode());
        }
      }
    } else {
      //자음인 경우
      if ((initConsonant == -1) ||
          (initConsonant >= 0 && middleConsonant == -1)) {
        //자음만 있는 경우, 아무것도 없는 경우
        reset();
        initConsonant = encodeChild(key);
        wholeText.add(key);
      } else if (initConsonant >= 0 &&
          middleConsonant >= 0 &&
          lastConsonant == -1) {
        //종성에 위치
        if (isDoubleConsonants(key)) {
          reset();
          initConsonant = encodeChild(key);
          wholeText.add(key);
        } else {
          lastConsonant = encodeLast(key, lastConsonant);
          wholeText[wholeText.length - 1] = mergeUnicode();
        }
      } else if (lastConsonant >= 0) {
        //종성이 존재할 경우

        if (isStacking(lastConsonant) != -1) {
          //겹받침 이라면
          reset();
          initConsonant = encodeChild(key);
          wholeText.add(key);
        } else {
          //홀받침이라면
          int stackingTest = encodeLast(key, lastConsonant);
          if (isStacking(stackingTest) == -1) {
            //겹받침 생성 불가능
            reset();
            initConsonant = encodeChild(key);
            wholeText.add(key);
          } else {
            //겹받침 생성 가능
            lastConsonant = stackingTest;
            wholeText[wholeText.length - 1] = mergeUnicode();
          }
        }
      }
    }
    changeText(wholeText);
    pressedSHIFT = false;
    hapticFeedback(false, context);
  }

  String mergeUnicode() {
    int initValue = initConsonant == -1 ? 0 : initConsonant;
    int middleValue = middleConsonant == -1 ? 0 : middleConsonant;
    int lastValue = lastConsonant == -1 ? 0 : lastConsonant;

    int unicode = ((initValue * 588) + (middleValue * 28) + lastValue) + 44032;
    return String.fromCharCode(unicode);
  }

  bool isDoubleConsonants(String key) {
    return ['ㅃ', 'ㅉ', 'ㄸ'].contains(key);
  }

  int isStacking(int unicode) {
    if (unicode > lastConsonantList.length - 1 || unicode == -1) {
      return -1;
    }
    //겹받침인지 검사
    if (lastConsonantList[unicode].length == 2) {
      //겹받침임
      return initConsonantList.indexOf(lastConsonantList[unicode][1]);
    } else {
      //겹받침이 아님
      return -1;
    }
  }

  // Widget deleteBtn() {}

  // Widget nextBtn() {}

  List<KoreanStruct> structList = [];
  // TextEditingController _text = TextEditingController();
  int initConsonant = -1;
  int middleConsonant = -1;
  int lastConsonant = -1;
  bool pressedSHIFT = false;
  bool pressedNumMode = false;
  var currentText;
  @override
  Widget build(BuildContext context) {
    var mode = pressedNumMode
        ? specialKeys
        : pressedSHIFT
        ? upperKeys
        : lowerKeys;

    return Container(
        color:
        const Color(0xFFDDDDDD),
        padding: const EdgeInsets.only(bottom: 3, top: 0, left: 4, right: 4),
        margin: const EdgeInsets.only(bottom: 3, top: 3),
        child: Column(
          children: [
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: mode.length,
                itemBuilder: (context, upperIndex) {
                  bool onPress = false;
                  var keysIntoLine = mode[upperIndex].map<Widget>((key) {
                    return StatefulBuilder(
                        builder: (context, setState) => InkWell(
                          onTapCancel: () {
                            onPress = false;
                            setState(() {});
                          },
                          onTap: () {
                            setState((){
                              _position = Offset.zero; // 초기화
                            });
                            insert(key);
                            Future.delayed(
                                const Duration(milliseconds: 100), () {
                              onPress = false;
                              setState(() {});
                            });
                          },
                          onTapDown: (TapDownDetails details) {
                            if(myController.typeTaskStart.value == false){
                              myController.typeTaskStart.value = true;
                              stopwatch.start();
                              stopwatch2.start();
                            }
                            final Offset localPosition = details.localPosition;
                            double xPos = localPosition.dx;
                            double yPos = localPosition.dy;
                            DateTime now = DateTime.now();
                            int time = now.millisecondsSinceEpoch;
                            // firebase로 전송할 데이터
                            if(myController.typeTaskStart.value == true){
                              if(key == "NEXT"){
                                myController.typeTaskStart.value = false;
                                stopwatch.stop();
                                myController.typeTaskTime.value = stopwatch.elapsedMilliseconds.toDouble();
                                stopwatch.reset();

                              }
                              if(key == "DEL"){
                                if(myController.typeTaskIndex.value > 0){
                                  myController.typeTaskIndex.value -= 1;
                                  myController.delCount.value += 1;
                                }
                              }
                              else{
                                myController.typeTaskIndex.value += 1;
                                stopwatch2.stop();
                                myController.keystrokeTime.add(stopwatch2.elapsedMilliseconds.toDouble());
                                //print('keystrokeTime: ${stopwatch2.elapsedMilliseconds.toDouble()}');
                                stopwatch2.reset();
                                stopwatch2.start();
                              }
                            }
                            print('Button "$key" tapped at ($xPos, $yPos)');
                            print('time : "${time} (ms)"');
                            setState(() {});
                          },
                          child: Container(
                              margin: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width /
                                    375 *
                                    2,
                                right: MediaQuery.of(context).size.width /
                                    375 *
                                    2,
                                top: 8,
                              ),
                              padding: const EdgeInsets.only(
                                  top: 10, bottom: 10),
                              alignment: Alignment.center,
                              constraints: BoxConstraints(
                                minWidth: key == 'SPACE'
                                    ? MediaQuery.of(context).size.width *
                                    0.54
                                    : key.length > 2
                                    ? MediaQuery.of(context)
                                    .size
                                    .width /
                                    (lowerKeys[0].length / 1.3)
                                    : MediaQuery.of(context)
                                    .size
                                    .width /
                                    (lowerKeys[0].length) *
                                    0.87,
                                minHeight:
                                MediaQuery.of(context).size.height /
                                    812 *
                                    46,
                              ),
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFA8A8A8),
                                      offset: const Offset(0, 3.0),
                                      blurRadius: 0,
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(7),
                                  color: (key == 'SHIFT' && pressedSHIFT)
                                      ? const Color.fromRGBO(
                                      209, 214, 217, 1)
                                      : key == 'SPACE'
                                      ? onPress
                                      ? const Color(0xFFA8A8A8)
                                      : Colors.white
                                      : onPress
                                      ? const Color.fromRGBO(
                                      209, 214, 217, 1)
                                      : Colors.white),
                              child: Text(
                                key == 'SPACE'
                                    ? ''
                                    : key == 'SHIFT'
                                    ? '⇧'
                                    : key == 'DEL'
                                    ? '⌫'
                                    : key == 'BACK'
                                    ? '←'
                                    : key == 'NEXT'
                                    ? '→'
                                    : key,
                                style: TextStyle(
                                    color: const Color(0xFF121517),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17),
                              )),
                        ));
                  }).toList();
                  keysIntoLine = keysIntoLine.toList();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: keysIntoLine,
                  );
                }),
          ],
        ));
  }

  void hapticFeedback(bool strong, context) async {
    if (strong) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }
}

class KoreanStruct {
  KoreanStruct(this.init, this.middle, this.last);
  int init;
  int middle;
  int last;
}