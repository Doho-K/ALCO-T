import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSearchPage extends StatefulWidget {
  @override
  State<MapSearchPage> createState() => MapSearchPageState();
}

class MapSearchPageState extends State<MapSearchPage> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _searchController = TextEditingController();

  // 초기 카메라 위치 : 중앙대학교
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.505272, 126.957327),
    zoom: 14,
  );

  // 커스텀 키보드 버튼
  final List<List<String>> keyboardLayout = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['ㅂ', 'ㅈ', 'ㄷ', 'ㄱ', 'ㅅ', 'ㅛ', 'ㅕ', 'ㅑ', 'ㅐ', 'ㅔ'],
    ['ㅁ', 'ㄴ', 'ㅇ', 'ㄹ', 'ㅎ', 'ㅗ', 'ㅓ', 'ㅏ', 'ㅣ'],
    ['↑', 'ㅋ', 'ㅌ', 'ㅊ', 'ㅍ', 'ㅠ', 'ㅜ', 'ㅡ', '←'],
    ['.', 'space', '.'],
  ];

  // 키보드가 떠있는지 여부를 나타내는 변수
  bool _isKeyboardVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ALCO-T Google Maps'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // 텍스트 필드를 탭하면 커스텀 키보드가 나타나도록 설정
                    setState(() {
                      _isKeyboardVisible = true;
                    });
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _searchController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: '  목적지를 빠르게 입력해주세요',
                      ),
                      onChanged: (value) {
                        // 검색어가 변경될 때마다 실행되는 콜백
                      },
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // 검색 버튼을 눌렀을 때 실행되는 콜백
                  String searchText = _searchController.text;
                  showConfirmationPopup(context, searchText);
                  _searchController.text = '';
                },
                icon: Icon(Icons.search),
              ),
            ],
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex, // 초기 카메라 위치
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          if (_isKeyboardVisible)
            CustomKeyboard(
              keyboardLayout: keyboardLayout,
              onKeyPressed: (String key) {
                if (key == '↑') {
                  setState(() {
                    if (keyboardLayout[1][0] == 'ㅂ') {
                      keyboardLayout[1] = ['ㅃ', 'ㅉ', 'ㄸ', 'ㄲ', 'ㅆ', 'ㅛ', 'ㅕ', 'ㅑ', 'ㅐ', 'ㅔ'];
                    } else {
                      keyboardLayout[1] = ['ㅂ', 'ㅈ', 'ㄷ', 'ㄱ', 'ㅅ', 'ㅛ', 'ㅕ', 'ㅑ', 'ㅐ', 'ㅔ'];
                    }
                  });
                } else if (key == '←') {
                  setState(() {
                    String currentText = _searchController.text;
                    if (currentText.isNotEmpty) {
                      _searchController.text = currentText.substring(0, currentText.length - 1);
                    }
                  });
                } else if (key == 'space'){
                  setState(() {
                    _searchController.text += ' ';
                  });
                } else {
                  setState(() {
                    _searchController.text += key;
                  });
                }
              },
            ),
        ],
      ),
    );
  }
}

class CustomKeyboard extends StatelessWidget {
  final List<List<String>> keyboardLayout;
  final Function(String) onKeyPressed;

  CustomKeyboard({required this.onKeyPressed, this.keyboardLayout = const []});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: Colors.grey[300],
      child: Column(
        children: keyboardLayout.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              return Expanded(
                child: GestureDetector(
                  onTapDown: (TapDownDetails details) {
                    Offset position = details.localPosition;
                    double xPos = position.dx;
                    double yPos = position.dy;
                    // firebase로 전송할 데이터
                    print('Button "$key" tapped at ($xPos, $yPos)');
                    print('time : ${DateTime.now().millisecondsSinceEpoch}' '(ms)');
                    // onKeyPressed 콜백 함수에 버튼의 값을 전달합니다.
                    onKeyPressed(key);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      key,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

void showConfirmationPopup(BuildContext context, String searchText) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('확인'),
        content: Text('$searchText 가 맞습니까?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              search(searchText);
              Navigator.of(context).pop();
            },
            child: Text('확인'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('취소'),
          ),
        ],
      );
    },
  );
}



void search(String searchText) {
  print('실제 검색을 실행합니다: $searchText');
  // 여기에 실제 검색 기능을 구현할 수 있습니다.
}
