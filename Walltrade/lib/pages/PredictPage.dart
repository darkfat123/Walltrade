import 'package:Walltrade/model/pricePoints.dart';
import 'package:Walltrade/widget/bottomSheet/PredictResultSheet.dart';
import 'package:Walltrade/widget/snackBar/AddPredictListFail.dart';
import 'package:Walltrade/widget/snackBar/AddPredictListSuccess.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quickalert/quickalert.dart';
import '../model/technicalAnalyze.dart';
import '../variables/serverURL.dart';
import 'HistoryAutoTrade.dart';
import 'SettingsPage.dart';

class PredictPage extends StatefulWidget {
  final String username;
  PredictPage({required this.username});
  @override
  _PredictPageState createState() => _PredictPageState(username: username);
}

class _PredictPageState extends State<PredictPage> {
  final String username;
  _PredictPageState({required this.username});
  TextEditingController _textEditingController = TextEditingController();
  String selectedStockNation = 'US';
  String selectedInterval = '1';
  bool isPredicting = true;

  late final List<PricePoint> points;

  List<String> dataList = ["META"];
  List<Map<String, dynamic>> symbolStockPrices = [];

  List<Map<String, dynamic>> predictdata = [];
  Future<void> _predictStock() async {
    var url = Uri.parse('${Constants.serverUrl}/predict');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'dataList': dataList,
      //'predictDay': selectedInterval,
    });
    print(body);

    try {
      http.Response response =
          await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        for (var item in data) {
          setState(() {
            predictdata.add({
              'symbol': item['symbol'],
              'prediction': item['prediction'],
              'close': item['close'],
              'real_prices_chart': item['real_prices_chart'],
              'predict_prices_chart': item['predict_prices_chart'],
            });
          });
        }
        setState(() {
          isPredicting = false;
        });
      } else {
        throw Exception('Prediction failed.');
      }
    } catch (e) {
      setState(() {
        print('error caught: $e');
      });
    }
  }

  String ans = '';
  List<String> stockSymbols = [];
  Map<String, double> stockPrices = {};
  Map<String, double> stockPercentage = {};

  Future<void> getStockPrices() async {
    var url = '${Constants.serverUrl}/getStockPriceUS';
    var body = jsonEncode({'username': username});

    var response = await http.post(Uri.parse(url),
        body: body, headers: {'Content-Type': 'application/json'});
    var data = jsonDecode(response.body);
    ans = data.toString();
    if (data != null && data is List<dynamic>) {
      for (var item in data) {
        var symbol = item['symbol'];
        var price = item['price'];
        var percentage = item['percentage'];
        setState(() {
          stockSymbols.add(symbol);
          stockPrices[symbol] = price.toDouble();
          stockPercentage[symbol] = percentage.toDouble();
        });
      }
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
  void initState() {
    super.initState();
    getStockPrices();
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
                                const AssetImage('assets/img/profile.png'),
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
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8),
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
                        icon: const Icon(Icons.access_time_rounded),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    HistoryAutoTradePage(username: username)),
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
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    Settings(username: username)),
                          );
                          // Handle settings button press here
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF212436),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 3), // changes the position of the shadow
                          ),
                        ],
                      ),
                      child: Text(
                        "ข้อควรระวัง: การลงทุนในหุ้นเป็นเรื่องที่มีความเสี่ยงสูง การใช้โมเดลทำนายอาจไม่แม่นยำเสมอไป โปรดพิจารณาเพิ่มเติม ระยะเวลารอการแสดงผลลัพธ์ขึ้นอยู่กับจำนวนหุ้นที่ต้องการทำนาย",
                        style: TextStyle(
                            color: Colors.yellow.shade800, fontSize: 14),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Container(
                      height: 110,
                      child: ans == '{error: Empty}'
                          ? const Center(
                              child: Text(
                                'ไม่มีรายการเฝ้าดู',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )
                          : stockSymbols.isEmpty
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: stockSymbols.length,
                                    itemBuilder: (context, index) {
                                      var symbol = stockSymbols[index];
                                      var price = stockPrices[symbol];
                                      var percentage = stockPercentage[symbol];
                                      return Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF212436),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      symbol,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      '$price',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: percentage! > 0
                                                              ? const Color(
                                                                  0xFF0AFF96)
                                                              : percentage < 0
                                                                  ? const Color(
                                                                      0xFFFF002E)
                                                                  : Colors
                                                                      .white),
                                                    ),
                                                    Text(
                                                      percentage > 0
                                                          ? '+$percentage%'
                                                          : '$percentage%',
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: percentage > 0
                                                              ? const Color(
                                                                  0xFF0AFF96)
                                                              : percentage < 0
                                                                  ? const Color(
                                                                      0xFFFF002E)
                                                                  : Colors
                                                                      .white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Add additional information or widgets related to the stock here
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 3), // changes the position of the shadow
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _textEditingController,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                labelText: 'เพิ่ม Symbol หุ้นที่จะทำนาย..',
                                labelStyle: const TextStyle(fontSize: 16),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 12),
                                prefixIcon: Container(
                                  alignment: Alignment.center,
                                  height: 56,
                                  width: 60,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                    border: Border.all(
                                      strokeAlign:
                                          BorderSide.strokeAlignOutside,
                                      width: 2,
                                      color: const Color(0xFF212436),
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      icon: const Icon(
                                        Icons.arrow_drop_down_rounded,
                                        color: Color(0xFF212436),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      value: selectedStockNation,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedStockNation = newValue!;
                                        });
                                      },
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'US',
                                          child: Center(
                                              child: Text(
                                            'US',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500),
                                          )),
                                        ),
                                        DropdownMenuItem(
                                          value: 'TH',
                                          child: Center(
                                              child: Text(
                                            'TH',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500),
                                          )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    if (_textEditingController.text != '') {
                                      setState(() {
                                        selectedStockNation == 'TH'
                                            ? dataList.add(
                                                '${_textEditingController.text}.BK')
                                            : dataList.add(
                                                _textEditingController.text);
                                      });

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              AddPredictListSuccessSnackBar(
                                                  symbol: _textEditingController
                                                      .text));
                                      _textEditingController.clear();
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                              AddPredictListFailSnackBar(
                                                  symbol: _textEditingController
                                                      .text));
                                      _textEditingController.clear();
                                    }
                                  },
                                  child: Container(
                                      height: 60,
                                      width: 60,
                                      decoration: const BoxDecoration(
                                          color: Color(0xFF212436),
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(10),
                                              bottomRight:
                                                  Radius.circular(10))),
                                      child: const Icon(
                                        Icons.add_circle_outline_rounded,
                                        size: 32,
                                        color: Colors.white,
                                      )),
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            /* PredictLengthDropdown(
                              selectedInterval: selectedInterval,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedInterval = newValue!;
                                });
                              },
                            ),*/

                            Container(
                              height: 40,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (dataList.length == 0) {
                                    QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.error,
                                      title: 'มีบางอย่างผิดพลาด',
                                      text:
                                          'โปรดเพิ่มหุ้นที่ต้องการทำนายลงไปในรายการทำนาย',
                                      width: 0,
                                      confirmBtnColor: const Color(0xFF212436),
                                      confirmBtnText: 'ตกลง',
                                      confirmBtnTextStyle: TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    );
                                  } else {
                                    QuickAlert.show(
                                      context: context,
                                      type: QuickAlertType.warning,
                                      barrierDismissible: true,
                                      title: 'ยืนยันการทำนาย',
                                      text:
                                          'เมื่อกดยืนยันอาจใช้เวลาสักครู่และไม่สามารถทำอะไรได้ทั้งสิ้น',
                                      width: 0,
                                      confirmBtnColor: Color(0xFF212436),
                                      confirmBtnText: 'ยืนยัน',
                                      cancelBtnText: 'ยกเลิก',
                                      cancelBtnTextStyle:
                                          TextStyle(fontSize: 14),
                                      showCancelBtn: true,
                                      onConfirmBtnTap: () {
                                        Navigator.pop(context);
                                        QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.loading,
                                          barrierDismissible: false,
                                          title: 'โปรดรอสักครู่..',
                                          text: 'กำลังทำนายราคาหุ้น',
                                          width: 0,
                                          confirmBtnColor: Color(0xFF212436),
                                          confirmBtnText: 'ตกลง',
                                          confirmBtnTextStyle: TextStyle(
                                              fontSize: 14,
                                              color: Colors.white),
                                        );
                                        _predictStock().then((_) {
                                          setState(() {
                                            // ปิด QuickAlert เมื่อ isPredicting เป็น false
                                            if (!isPredicting) {
                                              Navigator.pop(
                                                  context); // ปิด Alert
                                            }
                                            showModalBottomSheet(
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return buildPredictSheet(
                                                  data: predictdata,
                                                  context: context,
                                                );
                                              },
                                            );
                                          });
                                        });
                                      },
                                      confirmBtnTextStyle: TextStyle(
                                          fontSize: 14, color: Colors.white),
                                    );

                                    // เรียก _predictStock() เมื่อแสดง Alert แล้ว
                                  }
                                },
                                child: const Text(
                                  'ทำนายหุ้น',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Container(
                              height: 40,
                              color: Colors.black,
                              child: ElevatedButton(
                                onPressed: () {
                                  !isPredicting
                                      ? showModalBottomSheet(
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return buildPredictSheet(
                                                data: predictdata,
                                                context: context);
                                          })
                                      : showModalBottomSheet(
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Container(
                                                height: 180,
                                                decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                    30))),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Icon(
                                                      Icons.warning_rounded,
                                                      size: 84,
                                                      color:
                                                          Colors.red.shade900,
                                                    ),
                                                    const Text(
                                                      'โปรดเลือกหุ้นและทำนายหุ้นเพื่อดูรายละเอียดของผลลัพธ์',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ],
                                                ));
                                          });
                                },
                                child: const Text(
                                  "รายละเอียดผลลัพธ์การทำนาย",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      "จำนวนหุ้นที่ต้องการทำนาย ${dataList.length} หุ้น"),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: dataList.map((item) {
                                      return Chip(
                                        backgroundColor: Colors.grey.shade200,
                                        label: Text(
                                          item.toUpperCase(),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        deleteIconColor: Color(0xFFBB2525),
                                        onDeleted: () {
                                          setState(() {
                                            dataList.remove(item);
                                            print(dataList);
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 40,
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
             /* const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 30, bottom: 10),
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
                        autoPlayInterval: const Duration(seconds: 5),
                        height: 160.0,
                      ),
                      items: newsList.map((news) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
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
                                      gradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0x00000000),
                                          Color(0xCC000000),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      child: Text(
                                        news.title,
                                        style: const TextStyle(
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
                    return const Text('Failed to load news');
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),*/
              const SizedBox(
                height: 10,
              )
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
        const Text('ระยะเวลาที่ต้องการทำนาย'),
        Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: Color(0xFF212436),
              ),
              borderRadius: BorderRadius.circular(10),
              value: selectedInterval,
              onChanged: onChanged,
              items: const [
                DropdownMenuItem(
                  value: '1',
                  child: Center(child: Text('วันถัดไป')),
                ),
                DropdownMenuItem(
                  value: '2',
                  child: Center(child: Text('2 วันถัดไป')),
                ),
                DropdownMenuItem(
                  value: '3',
                  child: Center(child: Text('3 วันถัดไป')),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.info,
            size: 24,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('More Info'),
                  content:
                      const Text('Additional information about timeframes.'),
                  actions: [
                    TextButton(
                      child: const Text('OK'),
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
