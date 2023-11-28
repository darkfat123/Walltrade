import 'dart:convert';
import 'package:Walltrade/widget/alertDialog/InfoDialog.dart';
import 'package:Walltrade/widget/alertDialog/OrderConfirmation.dart';
import 'package:Walltrade/widget/dropdown/timeFrame.dart';
import 'package:flutter/material.dart';
import '../variables/serverURL.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../variables/symbolInput.dart';

class TradePageSell extends StatefulWidget {
  final String username;

  TradePageSell({required this.username});
  @override
  _TradePageSellState createState() => _TradePageSellState(username: username);
}

class _TradePageSellState extends State<TradePageSell> {
  TextEditingController timeIntervalController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController higherRSIController = TextEditingController();
  TextEditingController zoneMACDController = TextEditingController();
  TextEditingController crossdownSTOController = TextEditingController();
  TextEditingController zoneSTOController = TextEditingController();
  TextEditingController dayController = TextEditingController();
  String fixedZoneValue = '0';
  bool isZoneTextFieldEnabled = true;
  bool isCrossTextFieldEnabled = true;
  final String username;
  final TextEditingController _searchController = TextEditingController();
  bool macd_crossupIsChecked = false;
  String searchText = '';
  String selectedDay = '5';
  bool showDetails = false;
  String selectedInterval = '1h';
  String result = '';

  _TradePageSellState({required this.username});
  void _handleSubmit() {
    setState(() {
      searchText = _searchController.text;
    });
  }

  Future<void> placeOrderRSI(
      String qty, String side, String symbol, String interval) async {
    final url = Uri.parse('${Constants.serverUrl}/autotradeRSI');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(
      {
        'username': widget.username,
        'symbol': symbol,
        'qty': double.parse(qty),
        'side': side,
        'lowerRSI': higherRSIController.text,
        'interval': selectedInterval
      },
    );

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      setState(() {
        print(body);
        result = response.body;
      });
    } else {
      setState(() {
        result = 'เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ';
      });
    }
  }

  Future<void> placeOrderMACD(
      String qty, String side, String symbol, String interval) async {
    final url = Uri.parse('${Constants.serverUrl}/autotradeMACD');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(
      {
        'username': widget.username,
        'symbol': "BTCUSD",
        'qty': double.parse(qty),
        'side': side,
        'cross_macd': macd_crossupIsChecked,
        'zone': double.parse(zoneMACDController.text),
        'interval': selectedInterval
      },
    );

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print(body);
      setState(() {
        result = response.body;
      });
    } else {
      setState(() {
        result = 'เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ';
      });
    }
  }

  Future<void> placeOrderSTO(
      String qty, String side, String symbol, String interval) async {
    final url = Uri.parse('${Constants.serverUrl}/autotradeSTO');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(
      {
        'username': widget.username,
        'symbol': "BTCUSD",
        'qty': double.parse(qty),
        'side': side,
        'cross_sto': crossdownSTOController.text,
        'zone': zoneSTOController.text,
        'interval': selectedInterval
      },
    );

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print(body);
      setState(() {
        result = response.body;
      });
    } else {
      setState(() {
        result = 'เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ';
      });
    }
  }

  Future<void> placeOrderEMA(
      String qty, String side, String symbol, String interval) async {
    final url = Uri.parse('${Constants.serverUrl}/autotradeEMA');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(
      {
        'username': widget.username,
        'symbol': symbol,
        'qty': double.parse(qty),
        'side': side,
        'day': selectedDay,
        'interval': selectedInterval
      },
    );

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print(body);
      setState(() {
        result = response.body;
      });
    } else {
      setState(() {
        result = 'เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ';
      });
    }
  }

  @override
  void dispose() {
    // ยกเลิก timer หรือ animation ที่ใช้งาน
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Data>(builder: (context, data, child) {
      return SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Shadow color
                spreadRadius: 2, // Spread radius
                blurRadius: 5, // Blur radius
                offset: Offset(0, 3), // Offset in x and y direction
              ),
            ],
          ),
          child: Column(
            children: [
              ExpansionTile(
                title: Row(
                  children: [
                    Text(
                      'RSI',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      '(Relative Strength Index)',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                children: [
                  TimeframeDropdown(
                    selectedInterval: selectedInterval,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedInterval = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('ระบุค่า RSI ที่ต้องการขาย'),
                        SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            controller: higherRSIController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: '0-100',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.info,
                            size: 20,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return InfoAlertDialog(
                                  title: 'RSI คืออะไร?',
                                  content:
                                      'RSI สร้างขึ้นโดยวิธีการคำนวณค่าเฉลี่ยของการเปรียบเทียบราคาที่ขึ้นและลงของสินทรัพย์ในระยะเวลาที่กำหนด ช่วงค่าที่อยู่ระหว่าง 0 ถึง 100 จะสร้างคำสั่งขายเมื่อมีค่ามากกว่าหรือเท่ากับที่พิมพ์',
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('จำนวน'),
                        SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            controller: qtyController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'จำนวน',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      quickAlert(
                        context,
                        data.text,
                        qtyController.text,
                        higherRSIController.text == ''
                            ? ''
                            : 'RSI มากกว่า ${higherRSIController.text}',
                        selectedInterval,
                        'sell',
                        username,
                        (qty, type, symbol, interval, side) {
                          placeOrderRSI(qty, type, symbol, interval);
                          print(
                              'Placing order: $qty $type $symbol $interval $side');
                        },
                      );
                    },
                    child: Text('ยืนยัน'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
              ExpansionTile(
                title: Row(
                  children: [
                    Text(
                      'STO',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      '(Stochastic Oscillator)',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                children: [
                  TimeframeDropdown(
                    selectedInterval: selectedInterval,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedInterval = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('โซน STO %K และ %D'),
                        SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            controller: zoneSTOController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            enabled: isZoneTextFieldEnabled,
                            decoration: InputDecoration(
                              labelText: '0-100',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (text) {
                              if (text.isNotEmpty) {
                                setState(() {
                                  crossdownSTOController.text = "0";
                                  isCrossTextFieldEnabled = false;
                                });
                              } else {
                                setState(() {
                                  isCrossTextFieldEnabled = true;
                                  crossdownSTOController.clear();
                                });
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.info,
                            size: 20,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return InfoAlertDialog(
                                  title: 'โซน STO %K และ %D คืออะไร',
                                  content:
                                      'จะสร้างคำสั่งขายทันทีเมื่อเส้น %K และ %D มีค่ามากกว่าหรือเท่ากับโซนที่พิมพ์ โดยจะมีค่าตั้งแต่ 0-100',
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('%K ตัดลง %D และมีโซนสูงกว่า'),
                        SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            enabled: isCrossTextFieldEnabled,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            controller: crossdownSTOController,
                            decoration: InputDecoration(
                              labelText: '0-100',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (text) {
                              if (text.isNotEmpty) {
                                setState(() {
                                  zoneSTOController.text = "0";
                                  isZoneTextFieldEnabled = false;
                                });
                              } else {
                                setState(() {
                                  isZoneTextFieldEnabled = true;
                                  zoneSTOController.clear();
                                });
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.info,
                            size: 20,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return InfoAlertDialog(
                                    title:
                                        "%K ตัดลง %D และมีโซนสูงกว่า คืออะไร?",
                                    content:
                                        "จะสร้างคำสั่งขายทันทีเมื่อเส้น %K ตัดลงกับเส้น %D และมีค่าที่สูงกว่าโซนที่พิมพ์ โดยจะมีค่าตั้งแต่ 0-100");
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('จำนวน'),
                        SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            controller: qtyController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'จำนวน',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      quickAlert(
                        context,
                        data.text,
                        qtyController.text,
                        zoneSTOController.text == '' &&
                                crossdownSTOController.text == ''
                            ? ''
                            : zoneSTOController.text == '0'
                                ? "%K ตัดลง %D และมีโซนสูงกว่า ${crossdownSTOController.text}"
                                : "%K และ %D มากกว่าหรือเท่ากับ ${zoneSTOController.text}",
                        selectedInterval,
                        'sell',
                        username,
                        (qty, type, symbol, interval, side) {
                          placeOrderSTO(qty, type, symbol, interval);
                          print(
                              'Placing order: $qty $type $symbol $interval $side');
                        },
                      );
                    },
                    child: Text('Submit'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
              ExpansionTile(
                title: Row(
                  children: [
                    Text(
                      'MACD',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      '(MA Convergence Divergence)',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                children: [
                  TimeframeDropdown(
                    selectedInterval: selectedInterval,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedInterval = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('MACD ตัดลง Signal และมีโซนที่สูงกว่า 0'),
                        SizedBox(width: 5),
                        Checkbox(
                          value: macd_crossupIsChecked,
                          onChanged: (bool? newValue) {
                            setState(() {
                              macd_crossupIsChecked = newValue ?? false;
                              print(macd_crossupIsChecked);
                              if (macd_crossupIsChecked) {
                                zoneMACDController.text = fixedZoneValue;
                              } else {
                                zoneMACDController.text =
                                    ''; // ไม่ต้องใส่ค่าเมื่อ Checkbox ไม่ถูกติ๊ก
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.info,
                            size: 20,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return InfoAlertDialog(
                                  title:
                                      'MACD ตัดลง Signal และมีโซนสูงกว่า 0 คืออะไร?',
                                  content:
                                      'เป็นสัญญาณการขายพื้นฐานของ MACD ที่จะขายเมื่อเส้น MACD ตัดลงกับเส้น Signal และเส้นทั้งสองจะต้องมีค่าที่สูงกว่า 0',
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('โซน MACD & Signal'),
                        SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            controller: zoneMACDController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            enabled: !macd_crossupIsChecked,
                            decoration: InputDecoration(
                              labelText: 'ค่าที่ต้องการซื้อ',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.info,
                            size: 20,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return InfoAlertDialog(
                                    title: "โซน MACD & Signal คืออะไร?",
                                    content:
                                        "จะสร้างคำสั่งขายทันทีเมื่อค่าของเส้น MACD และเส้น Signal มีค่าเท่ากับมากกว่าค่าที่พิมพ์");
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('จำนวน'),
                        SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            controller: qtyController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'จำนวน',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      quickAlert(
                        context,
                        data.text,
                        qtyController.text,
                        !macd_crossupIsChecked && zoneMACDController.text == ''
                            ? ''
                            : macd_crossupIsChecked
                                ? "MACD & Signal ตัดลงและมีค่ามากกว่า 0"
                                : "MACD & Signal มากกว่าหรือเท่ากับ ${zoneMACDController.text}",
                        selectedInterval,
                        'sell',
                        username,
                        (qty, type, symbol, interval, side) {
                          placeOrderMACD(qty, type, symbol, interval);
                          print(
                              'Placing order: $qty $type $symbol $interval $side');
                        },
                      );
                    },
                    child: Text('Submit'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
              ExpansionTile(
                title: Row(
                  children: [
                    Text(
                      'EMA',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      '(Exponential MA)',
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                children: [
                  TimeframeDropdown(
                    selectedInterval: selectedInterval,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedInterval = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: EMADropdown(
                      selectedDay: selectedDay,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedDay = newValue!;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('จำนวน'),
                        SizedBox(width: 5),
                        Expanded(
                          child: TextField(
                            controller: qtyController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'เช่น 0.001, 5, 100',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 10.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      quickAlert(
                        context,
                        data.text,
                        qtyController.text,
                        "ซื้อเมื่อราคามากกว่าหรือเท่ากับ EMA$selectedDay",
                        selectedInterval,
                        'sell',
                        username,
                        (qty, type, symbol, interval, side) {
                          placeOrderEMA(qty, type, symbol, interval);
                          print(
                              'Placing order: $qty $type $symbol $interval $side');
                        },
                      );
                    },
                    child: Text('ยืนยัน'),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class EMADropdown extends StatelessWidget {
  final String selectedDay;
  final Function(String?) onChanged;

  const EMADropdown({
    required this.selectedDay,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            'จำนวนวันของ EMA',
            style: TextStyle(color: Colors.black),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              borderRadius: BorderRadius.circular(10),
              value: selectedDay,
              onChanged: onChanged,
              icon: const Icon(Icons.arrow_drop_down_circle,
                  color: Colors.black, size: 20),
              items: const [
                DropdownMenuItem(
                  value: '5',
                  child: Text(
                    'EMA5',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                DropdownMenuItem(
                  value: '10',
                  child: Text(
                    'EMA10',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                DropdownMenuItem(
                  value: '20',
                  child: Text(
                    'EMA20',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                DropdownMenuItem(
                  value: '50',
                  child: Text(
                    'EMA50',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                DropdownMenuItem(
                  value: '100',
                  child: Text(
                    'EMA100',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                DropdownMenuItem(
                  value: '200',
                  child: Text(
                    'EMA200',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.info,
              size: 20,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return InfoAlertDialog(
                    title: 'จำนวนวันของ EMA คืออะไร?',
                    content:
                        'ระยะเวลาที่ใช้ในการคำนวณค่าเฉลี่ยเคลื่อนที่ของข้อมูลราคาหรือสถิติในช่วงเวลานั้น ค่า EMA ที่มีจำนวนวันน้อยจะมีการผันผวนที่เร็วขึ้น ในขณะที่ค่า EMA ที่มีจำนวนวันมากขึ้นจะมีการผันผวนที่ช้าลง',
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
