import 'package:Walltrade/model/pricePoints.dart';
import 'package:Walltrade/widget/bottomSheet/PredictResultSheet.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import '../model/technicalAnaylyze.dart';
import '../variables/serverURL.dart';
import 'HistoryAutoTrade.dart';
import 'SettingsPage.dart';

class PredictPage extends StatefulWidget {
  @override
  _PredictPageState createState() => _PredictPageState();
}

class _PredictPageState extends State<PredictPage> {
  TextEditingController _textEditingController = TextEditingController();
  String _prediction = '';
  String selectedInterval = '1D';
  bool isPredicting = true;
  late final List<PricePoint> points;

  Future<void> _predictStock() async {
    isPredicting = true;
    String stockName = _textEditingController.text;
    if (stockName.isEmpty) {
      setState(() {
        _prediction = 'Please enter a stock name.';
      });
      return;
    }

    var url = Uri.parse('${Constants.serverUrl}/predict');
    final headers = {'Content-Type': 'application/json'};
    String body = jsonEncode({'name': stockName});

    try {
      http.Response response =
          await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _prediction = data['prediction'];
          isPredicting = false;
        });
      } else {
        throw Exception('Prediction failed.');
      }
    } catch (e) {
      setState(() {
        _prediction = 'error caught: $e';
      });
    }
  }

  String editPredictLength(String text) {
    text = text == '1D'
        ? 'วันถัดไป'
        : text == '2D'
            ? '2 วันถัดไป'
            : '3 วันถัดไป';
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Handle the press event here
                          },
                          child: CircleAvatar(
                            radius: 25,
                            backgroundImage:
                                AssetImage('assets/img/profile.png'),
                            backgroundColor: Colors.transparent,
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFE55807),
                                    Color(0xFF7E1717),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Padding(
                                //this padding will be your border size
                                padding: const EdgeInsets.all(3.5),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    foregroundImage:
                                        AssetImage("assets/img/profile.png"),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          "ทำนายราคาหุ้น",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        iconSize: 30,
                        icon: Icon(Icons.notifications),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    NotifyActivity(username: 'foczz123')),
                          );
                          // Handle settings button press here
                        },
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 50,
                      child: IconButton(
                        iconSize: 30,
                        icon: Icon(Icons.settings),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Settings(username: 'foczz123')),
                          );
                          // Handle settings button press here
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, bottom: 20.0, right: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        margin:
                            EdgeInsets.only(left: 16, bottom: 16, right: 16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF2A3547),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(
                                  0, 3), // changes the position of the shadow
                            ),
                          ],
                        ),
                        child: Text(
                          "ข้อควรระวัง: การลงทุนในหุ้นเป็นเรื่องที่มีความเสี่ยงสูง การใช้โมเดลทำนายอาจไม่แม่นยำเสมอไป โปรดพิจารณาเพิ่มเติม",
                          style: TextStyle(
                              color: Colors.yellow.shade800, fontSize: 14),
                        )),
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(
                                0, 3), // changes the position of the shadow
                          ),
                        ],
                      ),
                      child: Container(
                        margin: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _textEditingController,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                labelText: 'พิมพ์ Symbol หุ้นที่จะทำนาย..',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            PredictLengthDropdown(
                              selectedInterval: selectedInterval,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedInterval = newValue!;
                                });
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: _predictStock,
                                child: Text(
                                  'ทำนาย',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Container(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  _predictStock();
                                  if (!isPredicting) {
                                    setState(() {
                                      showModalBottomSheet(
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return buildPredictSheet(
                                                prediction: _prediction,
                                                context: context);
                                          });
                                    });
                                  }
                                },
                                child: Text(
                                  'ทำนายหุ้นหลายรายการ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Container(
                              height: 40,
                              color: Colors.black,
                              child: ElevatedButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return buildPredictSheet(
                                            prediction: _prediction,
                                            context: context);
                                      });
                                },
                                child: Text(
                                  "รายละเอียดผลลัพธ์การทำนาย",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Column(
                              children: [
                                Text(
                                  "ผลลัพธ์การทำนายใน ${editPredictLength(selectedInterval)} ของ ${_textEditingController.text} คือ $_prediction",
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "ราคาวันนี้ 296.21",
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "ราคาจะขึ้นในวันถัดไป",
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ],
                            ),

                            /*AspectRatio(
                              aspectRatio: 2,
                              child: LineChart(
                                LineChartData(
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: pricePoints.map((point) {
                                        return FlSpot(point.x, point.y);
                                      }).toList(),
                                    ),
                                    LineChartBarData(
                                      spots: [
                                        FlSpot(0, 3),
                                        FlSpot(1, 5),
                                        FlSpot(2, 5),
                                        FlSpot(3, 10),
                                        FlSpot(4, 2),
                                        FlSpot(5, 5),
                                        FlSpot(6, 4),
                                        FlSpot(7, 8),
                                        // ... ข้อมูลเส้นกราฟแสดงข้อมูลแบบเส้นที่สอง
                                      ],
                                      color: Colors
                                          .red, // สีของเส้นกราฟแสดงข้อมูลแบบเส้นที่สอง
                                      isCurved:
                                          true, // แสดงเส้นกราฟแบบโค้งหรือไม่
                                    ),
                                  ],
                                ),
                              ),
                            ),*/
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30, bottom: 10),
                    child: Text(
                      "วิเคราะห์กราฟ",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
              FutureBuilder<List<TechnicalAnaylyze>>(
                future: fetchTechnicalAnaylyze(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final newsList =
                        snapshot.data!; // Extract the fetched news list
                    return CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 5),
                        height: 160.0,
                      ),
                      items: newsList.map((news) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(news.image),
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          const Color(0x00000000),
                                          const Color(0xCC000000),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      child: Text(
                                        news.title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Failed to load news');
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PredictLengthDropdown extends StatelessWidget {
  final String selectedInterval;
  final Function(String?) onChanged;

  const PredictLengthDropdown({
    required this.selectedInterval,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('ระยะเวลาที่ต้องการทำนาย'),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedInterval,
            onChanged: onChanged,
            items: [
              DropdownMenuItem(
                value: '1D',
                child: Text('วันถัดไป'),
              ),
              DropdownMenuItem(
                value: '2D',
                child: Text('2 วันถัดไป'),
              ),
              DropdownMenuItem(
                value: '3D',
                child: Text('3 วันถัดไป'),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.info,
            size: 24,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('More Info'),
                  content: Text('Additional information about timeframes.'),
                  actions: [
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}
