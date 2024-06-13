import 'dart:async';
import 'package:alco_t_dev/DataCollector.dart';
import 'package:alco_t_dev/GyroTask.dart';
import 'package:alco_t_dev/SelectionPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'korean_keyboard.dart';

class MapSearchPage extends StatefulWidget {
  @override
  State<MapSearchPage> createState() => MapSearchPageState();
}

class MapSearchPageState extends State<MapSearchPage> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController _searchController = TextEditingController();
  Set<Marker> _markers = {};
  final myController = Get.put(DataCollector());
  Stopwatch stopwatch = Stopwatch();
  Stopwatch stopwatch2 = Stopwatch();

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
                            /*myController.typeTaskStart.value = false;
                            stopwatch.stop();
                            myController.typeTaskTime.value = stopwatch.elapsedMilliseconds.toDouble();*/
                            search(searchText);
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
                        /*print('typetaskstart: ${myController.typeTaskStart.value}');
                        // 검색어가 변경될 때마다 실행되는 콜백
                        if(value.length <= 1 && myController.typeTaskStart.value == false){//시작전
                          myController.typeTaskStart.value = true;
                          stopwatch.start();
                          stopwatch2.start();
                        }
                        else{
                          stopwatch2.stop();
                          myController.keystrokeTime.add(stopwatch2.elapsedMilliseconds.toDouble());
                          stopwatch2.reset();
                          stopwatch2.start();
                        }*/
                      },
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // 검색 버튼을 눌렀을 때 실행되는 콜백
                  String searchText = _searchController.text;
                  //myController.typeTaskStart.value = false;
                  /*stopwatch.stop();
                  myController.typeTaskTime.value = stopwatch.elapsedMilliseconds.toDouble();*/
                  search(searchText);
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
              markers: _markers,
            ),
          ),
        ],
      ),
    );
  }

  void showWarningDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('경고', style: TextStyle(color: Colors.red, fontSize: 24)),
          content: Text(
            '당신은 음주 상태임이 의심됩니다.\n\n'
                '아래의 다음 확인을 눌러 정밀 확인을 실시합니다.\n\n'
                '또는 무시를 경고하고 경로 탐색을 진행합니다.\n\n'
                '이로 인해 안전운전 점수는 10 하락할 예정이며 음주운전으로 의한 사고는 본 개발사는 책임지지 않습니다.',
            style: TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('정밀 검사 실행'),
              onPressed: () {
                Navigator.of(context).pop();
                Get.to(SelectionPage(userID: '',sessionID: 0,));
                // 정밀 검사 실행 코드 추가
                 // 팝업 닫기
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('경로 탐색'),
              onPressed: () {
                // 경로 탐색 실행 코드 추가
                Navigator.of(context).pop(); // 팝업 닫기
              },
            ),
          ],
        );
      },
    );
  }

  void search(String searchText) async {
    print('실제 검색을 실행합니다: $searchText');

    final places = GoogleMapsPlaces(apiKey: 'AIzaSyAMBHK74KDN1OsyAkPWl6YoLM27KVmquro');

    PlacesSearchResponse response = await places.searchByText(searchText);

    if (response.isOkay) {
      // 검색 결과를 처리합니다.
      for (var result in response.results) {
        if (result.geometry != null && result.geometry!.location != null) {
          print('장소 이름: ${result.name}');
          print('장소 주소: ${result.formattedAddress}');
          myController.saveTypeTask();
          if (result.geometry!.location != null) {
            print('위도: ${result.geometry!.location!.lat}');
            print('경도: ${result.geometry!.location!.lng}');

            // 검색된 위치로 카메라 시점을 변경합니다.
            final GoogleMapController controller = await _controller.future;
            controller.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(
                  result.geometry!.location!.lat,
                  result.geometry!.location!.lng,
                ),
              ),
            );
          } else {
            print('위치 정보를 찾을 수 없습니다.');
          }
          print('---');
        } else {
          print('장소의 위치 정보를 찾을 수 없습니다.');
        }
        showWarningDialog();

        break;
      }
    } else {
      print('검색에 실패했습니다: ${response.errorMessage}');
    }
  }
}