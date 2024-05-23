import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'korean_keyboard.dart'; // korean_keyboard.dart 파일을 import

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
                    // 텍스트 필드를 탭하면 한국어 키보드가 나타나도록 설정
                    FocusScope.of(context).requestFocus(FocusNode());
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        // 한국어 키보드를 띄웁니다.
                        return KoreanKeyboard(
                          insert: (List<String> texts) {
                            setState(() {
                              _searchController.text = texts.join('');
                            });
                          },
                          submit: () {
                            // Submit 버튼을 눌렀을 때 실행되는 콜백
                            String searchText = _searchController.text;
                            showConfirmationPopup(context, searchText);
                            _searchController.text = '';
                          },
                          cancel: () {
                            // Cancel 버튼을 눌렀을 때 실행되는 콜백
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
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
        ],
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
