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

  // 커스텀 키보드의 버튼과 좌표 설정
  final List<List<String>> keyboardLayout = [
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['ㅂ', 'ㅈ', 'ㄷ', 'ㄱ', 'ㅅ', 'ㅛ', 'ㅕ', 'ㅑ', 'ㅐ', 'ㅔ'],
    ['ㅁ', 'ㄴ', 'ㅇ', 'ㄹ', 'ㅎ', 'ㅗ', 'ㅓ', 'ㅏ', 'ㅣ'],
    ['↑', 'ㅋ', 'ㅌ', 'ㅊ', 'ㅍ', 'ㅠ', 'ㅜ', 'ㅡ', '←'],
    ['.', 'space', '.', 'enter'],
  ];

  // 키보드가 떠있는지 여부를 나타내는 변수
  bool _isKeyboardVisible = false;

  // 마커 세트
  Set<Marker> _markers = {};

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
                        // 여기에서 검색어를 처리하거나 검색 결과를 업데이트할 수 있습니다.
                      },
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // 검색 버튼을 눌렀을 때 실행되는 콜백
                  // 여기에서 검색어를 사용하여 검색을 실행하거나, 검색 결과를 표시할 수 있습니다.
                  _searchOnMap();
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
              markers: _markers,
            ),
          ),
          // 커스텀 키보드가 표시되는지 여부에 따라 키보드를 표시하거나 숨깁니다.
          if (_isKeyboardVisible)
            CustomKeyboard(
              keyboardLayout: keyboardLayout,
              onKeyPressed: (String key) {
                // ↑ 버튼을 누르면 ㅃ ㅉ ㄸ ㄲ ㅆ 가 ㅂㅈㄷㄱㅅ로 바뀌도록 구현
                if (key == '↑') {
                  setState(() {
                    keyboardLayout[1] = ['ㅂ', 'ㅈ', 'ㄷ', 'ㄱ', 'ㅅ', 'ㅛ', 'ㅕ', 'ㅑ', 'ㅐ', 'ㅔ'];
                  });
                } else if (key == 'enter') {
                  // enter 키를 눌렀을 때 검색 기능 실행
                  _searchOnMap();
                }
              },
            ),
        ],
      ),
    );
  }

  // 구글맵에서 검색 실행
  void _searchOnMap() async {
    final String searchText = _searchController.text;
    if (searchText.isEmpty) return;

    try {
      // 검색어를 지도의 중심으로 설정하여 이동
      final GoogleMapController controller = await _controller.future;
      final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: 'YOUR_API_KEY');
      PlacesSearchResponse results = await _places.searchByText(searchText);
      if (results.isOkay) {
        final PlacesSearchResult firstPlace = results.results[0];
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(firstPlace.geometry!.location.lat, firstPlace.geometry!.location.lng),
            14.0,
          ),
        );

        // 마커 추가
        _markers.add(
          Marker(
            markerId: MarkerId(firstPlace.name!),
            position: LatLng(firstPlace.geometry!.location.lat, firstPlace.geometry!.location.lng),
            infoWindow: InfoWindow(
              title: firstPlace.name,
              snippet: firstPlace.formattedAddress,
            ),
          ),
        );

        // 지도에 마커 업데이트
        setState(() {
          _markers = _markers;
        });
      }
    } catch (e) {
      print('검색 오류: $e');
    }
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
                  onTap: () {
                    // 사용자가 버튼을 누를 때 해당 버튼의 화면 좌표를 가져옵니다.
                    RenderBox renderBox = context.findRenderObject() as RenderBox;
                    Offset offset = renderBox.localToGlobal(Offset.zero);
                    double screenWidth = MediaQuery.of(context).size.width;
                    double screenHeight = MediaQuery.of(context).size.height;
                    double buttonWidth = screenWidth / row.length;
                    double buttonHeight = screenHeight / keyboardLayout.length;
                    int rowIdx = keyboardLayout.indexWhere((r) => r.contains(key));
                    int colIdx = row.indexOf(key);
                    double xPos = offset.dx + buttonWidth * colIdx + buttonWidth / 2;
                    double yPos = offset.dy + buttonHeight * rowIdx + buttonHeight / 2;
                    // 버튼의 좌표를 출력합니다.
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

