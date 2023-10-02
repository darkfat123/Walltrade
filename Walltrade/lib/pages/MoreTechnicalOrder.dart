import 'dart:convert';

import 'package:Walltrade/pages/HistoryAutoTrade.dart';
import 'package:Walltrade/pages/SettingsPage.dart';
import 'package:Walltrade/primary.dart';
import 'package:Walltrade/widget/alertDialog/InfoDialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/quickalert.dart';
import '../variables/serverURL.dart';

class MoreTechnicalOrder extends StatefulWidget {
  final String username;
  MoreTechnicalOrder({required this.username});
  @override
  _MoreTechnicalOrderState createState() =>
      _MoreTechnicalOrderState(username: username);
}

class _MoreTechnicalOrderState extends State<MoreTechnicalOrder> {
  final String username;
  _MoreTechnicalOrderState({required this.username});
  List<String> selectedMenus = [];
  Map<String, bool> menuSelectionStatus = {
    'RSI': false,
    'STO': false,
    'MACD': false,
    'EMA': false
  };
  bool macd_crossupIsChecked = false;
  TextEditingController lowerRSIController = TextEditingController();
  TextEditingController zoneMACDController = TextEditingController();
  TextEditingController zoneSTOController = TextEditingController();
  TextEditingController crossupSTOController = TextEditingController();
  TextEditingController dayController = TextEditingController();
  TextEditingController symbolController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  bool isCrossTextFieldEnabled = true;
  bool isZoneTextFieldEnabled = true;
  String selectedInterval = '1 hour';

  String selectedDay = '5';

  void toggleContainer(String menu) {
    setState(() {
      if (selectedMenus.contains(menu)) {
        selectedMenus.remove(menu);
        menuSelectionStatus[menu] = false;
      } else {
        selectedMenus.add(menu);
        menuSelectionStatus[menu] = true;
      }
      print(menuSelectionStatus);
    });
  }

  Future<void> multiAutotrade(String side) async {
    var url = Uri.parse('${Constants.serverUrl}/multiAutotrade');
    var headers = {'Content-Type': 'application/json'};
    var body = {
      'username': username,
      'isRSI': menuSelectionStatus['RSI'],
      'isSTO': menuSelectionStatus['STO'],
      'isMACD': menuSelectionStatus['MACD'],
      'isEMA': menuSelectionStatus['EMA'],
      'symbol': symbolController.text.toUpperCase(),
      'qty': double.parse(qtyController.text),
      'side': side,
      'rsi': lowerRSIController.text,
      'zone_sto': zoneSTOController.text,
      'cross_sto': crossupSTOController.text,
      'zone_macd': zoneMACDController.text,
      'cross_macd': macd_crossupIsChecked,
      'day': selectedDay,
    };

    var response =
        await http.post(url, headers: headers, body: jsonEncode(body));

    // ตรวจสอบสถานะการตอบสนอง
    if (response.statusCode == 200) {
      // สำเร็จ
      print('ส่งข้อมูลสำเร็จ');
    } else {
      // ไม่สำเร็จ
      print('การส่งข้อมูลไม่สำเร็จ');
    }
  }

  Widget moreInfoSymbol() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: primary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes the position of the shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "เทคนิคที่ต้องการใช้: ${selectedMenus.join(', ')}",
                style: TextStyle(
                    color: Colors.amber.shade800, fontWeight: FontWeight.w600),
              ),
            ),
            TimeframeDropdown(
              selectedInterval: selectedInterval,
              onChanged: (String? newValue) {
                setState(() {
                  selectedInterval = newValue!;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'สัญลักษณ์หุ้น',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: symbolController,
                    style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'เช่น META, AAPL, PTT, SCB',
                      labelStyle: TextStyle(fontSize: 14, color: Colors.white),
                      filled: true, // กำหนดให้มีสีพื้นหลัง
                      fillColor:
                          Color(0xFF2A3547), // สีพื้นหลังของช่องพิมพ์ TextField
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal:
                              10.0), // ปรับความสูงและความยาวของช่องพิมพ์ที่นี่
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color:
                              Colors.white, // สีเส้นโครงรอบช่องพิมพ์ในสถานะปกติ
                          width:
                              2.0, // ความหนาของเส้นโครงรอบช่องพิมพ์ในสถานะปกติ
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors
                              .white, // สีเส้นโครงรอบช่องพิมพ์เมื่อมีการเน้น
                          width:
                              2.0, // ความหนาของเส้นโครงรอบช่องพิมพ์เมื่อมีการเน้น
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'จำนวนหุ้น',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: qtyController,
                    style: TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'เช่น 0.1,1000,5',
                      labelStyle: TextStyle(fontSize: 14, color: Colors.white),
                      filled: true, // กำหนดให้มีสีพื้นหลัง
                      fillColor:
                          Color(0xFF2A3547), // สีพื้นหลังของช่องพิมพ์ TextField
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal:
                              10.0), // ปรับความสูงและความยาวของช่องพิมพ์ที่นี่
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color:
                              Colors.white, // สีเส้นโครงรอบช่องพิมพ์ในสถานะปกติ
                          width:
                              2.0, // ความหนาของเส้นโครงรอบช่องพิมพ์ในสถานะปกติ
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors
                              .white, // สีเส้นโครงรอบช่องพิมพ์เมื่อมีการเน้น
                          width:
                              2.0, // ความหนาของเส้นโครงรอบช่องพิมพ์เมื่อมีการเน้น
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (selectedMenus.length < 2) {
                      QuickAlert.show(
                          context: context,
                          type: QuickAlertType.error,
                          text:
                              'โปรดเลือกเทคนิคชี้วัดที่ต้องการใช้อย่างน้อย 2 เทคนิค',
                          title: "เกิดข้อผิดพลาด",
                          confirmBtnText: "ตกลง",
                          confirmBtnTextStyle: TextStyle(color: Colors.white),
                          width: 0,
                          confirmBtnColor: primary);
                    } else {
                      multiAutotrade('buy');
                    }
                  },
                  child: const Text("ซื้อ"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF82CD47),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedMenus.length < 2) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('เกิดข้อผิดพลาด'),
                            content: const Text(
                                'โปรดเลือกเทคนิคชี้วัดที่ต้องการใช้อย่างน้อย 2 เทคนิค'),
                            actions: [
                              TextButton(
                                child: const Text('ตกลง'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      multiAutotrade('sell');
                    }
                  },
                  child: const Text("ขาย"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBB2525),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildEMA() {
    return Container(
        key: const ValueKey('EMA'),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes the position of the shadow
            ),
          ],
        ), // ใช้เมธอด getMenuColor เพื่อเลือกสีเมนู

        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: primary,
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'EMA (Exponential Moving Average)',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.white),
                  )
                ],
              ),
            ),
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
          ],
        ));
  }

  Widget buildRSI() {
    return Container(
      key: const ValueKey('RSI'),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes the position of the shadow
          ),
        ],
      ), // ใช้เมธอด getMenuColor เพื่อเลือกสีเมนู
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset:
                      const Offset(0, 3), // changes the position of the shadow
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'RSI (Relative Strength Index)',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.white),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('ระบุค่า RSI ที่ต้องการซื้อ'),
                const SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: lowerRSIController,
                    decoration: const InputDecoration(
                      labelText: '0-100',
                      border: OutlineInputBorder(),
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
                        return InfoAlertDialog(
                          title: 'RSI คืออะไร?',
                          content:
                              'RSI สร้างขึ้นโดยวิธีการคำนวณค่าเฉลี่ยของการเปรียบเทียบราคาที่ขึ้นและลงของสินทรัพย์ในระยะเวลาที่กำหนด (โดยทั่วไปใช้ระยะเวลา 14 วัน) และแปลงผลลัพธ์เป็นช่วงค่าที่อยู่ระหว่าง 0 ถึง 100',
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget buildMACD() {
    return Container(
        key: const ValueKey('MACD'),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes the position of the shadow
            ),
          ],
        ), // ใช้เมธอด getMenuColor เพื่อเลือกสีเมนู

        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: primary,
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'MACD (Moving Average Convergence Divergence)',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.white),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text('MACD ตัด Signal และมีโซนต่ำกว่าหรือมากกว่า 0'),
                  const SizedBox(width: 5),
                  Checkbox(
                    value: macd_crossupIsChecked,
                    onChanged: (bool? newValue) {
                      setState(() {
                        macd_crossupIsChecked = newValue ?? false;
                        print(macd_crossupIsChecked);
                        if (macd_crossupIsChecked) {
                          zoneMACDController.text = '0';
                        } else {
                          zoneMACDController.text =
                              ''; // ไม่ต้องใส่ค่าเมื่อ Checkbox ไม่ถูกติ๊ก
                        }
                      });
                    },
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
                          return InfoAlertDialog(
                            title:
                                'MACD ตัดขึ้นหรือตัดลง Signal และมีโซนต่ำกว่าหรือมากกว่า 0 คืออะไร?',
                            content:
                                'เป็นสัญญาณการซื้อพื้นฐานของ MACD ที่จะซื้อหรือขายเมื่อเส้น MACD ตัดขึ้นหรือตัดลงกับเส้น Signal และเส้นทั้งสองจะต้องมีค่าที่ต่ำกว่าหรือมากกว่า 0',
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
                  const Text('โซน MACD & Signal'),
                  const SizedBox(width: 5),
                  Expanded(
                    child: TextField(
                      controller: zoneMACDController,
                      enabled: !macd_crossupIsChecked,
                      decoration: const InputDecoration(
                        labelText: 'ค่าที่ต้องการซื้อ',
                        border: OutlineInputBorder(),
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
                          return InfoAlertDialog(
                              title: "โซน MACD & Signal คืออะไร?",
                              content:
                                  "จะสร้างคำสั่งซื้อหรือขายทันทีเมื่อค่าของเส้น MACD และเส้น Signal มีค่าเท่ากับหรือน้อยกว่าหรือมากกว่าค่าที่พิมพ์");
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget buildSTO() {
    return Container(
      key: const ValueKey('STO'),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes the position of the shadow
          ),
        ],
      ), // ใช้เมธอด getMenuColor เพื่อเลือกสีเมนู

      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset:
                      const Offset(0, 3), // changes the position of the shadow
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'STO (Stochastic Oscillator)',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.white),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('โซน STO %K และ %D'),
                const SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: zoneSTOController,
                    enabled: isZoneTextFieldEnabled,
                    decoration: const InputDecoration(
                      labelText: '0-100',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text) {
                      if (text.isNotEmpty) {
                        setState(() {
                          crossupSTOController.text = "0";
                          isCrossTextFieldEnabled = false;
                        });
                      } else {
                        setState(() {
                          isCrossTextFieldEnabled = true;
                          crossupSTOController.clear();
                        });
                      }
                    },
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
                        return InfoAlertDialog(
                          title: 'โซน STO %K และ %D คืออะไร',
                          content:
                              'จะสร้างคำสั่งซื้อหรือขายทันทีเมื่อเส้น %K และ %D มีค่าน้อยกว่าหรือมากกว่าเท่ากับโซนที่พิมพ์ โดยจะมีค่าตั้งแต่ 0-100',
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
                const Text('%K ตัด %D และมีโซนต่ำกว่าหรือมากกว่า'),
                const SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    enabled: isCrossTextFieldEnabled,
                    controller: crossupSTOController,
                    decoration: const InputDecoration(
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
                  icon: const Icon(
                    Icons.info,
                    size: 24,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return InfoAlertDialog(
                            title:
                                "%K ตัดขึ้นหรือตัดลง %D และมีโซนต่ำกว่าหรือมากกว่า คืออะไร?",
                            content:
                                "จะสร้างคำสั่งซื้อทันทีเมื่อเส้น %K ตัดขึ้นหรือตัดลงกับเส้น %D และมีค่าที่ต่ำกว่าหรือมากกว่า(ขึ้นอยู่กับซื้อหรือขาย)โซนที่พิมพ์ โดยจะมีค่าตั้งแต่ 0-100");
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "สร้างคำสั่งซื้อแบบหลายเทคนิค",
              style: TextStyle(fontSize: 18),
            ),
            Row(
              children: [
                IconButton(
                  iconSize: 20,
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Settings(username: username),
                        ));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            moreInfoSymbol(),
            Container(
              margin: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      toggleContainer('RSI');
                      print(menuSelectionStatus['RSI']);
                    },
                    child: Container(
                      width: 60, // กำหนดความกว้างของปุ่ม
                      height: 60, // กำหนดความสูงของปุ่ม
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFF2A3547), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 3), // changes the position of the shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                        color: menuSelectionStatus['RSI'] == true
                            ? Color(0xFF2A3547)
                            : Colors.white, // สีพื้นหลังของปุ่ม
                      ),
                      child: menuSelectionStatus['RSI'] == true
                          ? Center(
                              child: Text(
                                'RSI',
                                style: TextStyle(
                                  color: Colors.white, // สีข้อความ
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                'RSI',
                                style: TextStyle(
                                  color: Colors.black, // สีข้อความ
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      toggleContainer('STO');
                    },
                    child: Container(
                      width: 60, // กำหนดความกว้างของปุ่ม
                      height: 60, // กำหนดความสูงของปุ่ม
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFF2A3547), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 3), // changes the position of the shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(
                            10), // กำหนดให้รูปร่างเป็นวงกลม
                        color: menuSelectionStatus['STO'] == true
                            ? Color(0xFF2A3547)
                            : Colors.white, // สีพื้นหลังของปุ่ม
                        // สีพื้นหลังของปุ่ม
                      ),
                      child: menuSelectionStatus['STO'] == true
                          ? Center(
                              child: Text(
                                'STO',
                                style: TextStyle(
                                  color: Colors.white, // สีข้อความ
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                'STO',
                                style: TextStyle(
                                  color: Colors.black, // สีข้อความ
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      toggleContainer('MACD');
                    },
                    child: Container(
                      width: 60, // กำหนดความกว้างของปุ่ม
                      height: 60, // กำหนดความสูงของปุ่ม
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFF2A3547), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 3), // changes the position of the shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(
                            10), // กำหนดให้รูปร่างเป็นวงกลม
                        color: menuSelectionStatus['MACD'] == true
                            ? Color(0xFF2A3547)
                            : Colors.white, // สีพื้นหลังของปุ่ม
                        // สีพื้นหลังของปุ่ม
                      ),
                      child: menuSelectionStatus['MACD'] == true
                          ? Center(
                              child: Text(
                                'MACD',
                                style: TextStyle(
                                  color: Colors.white, // สีข้อความ
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                'MACD',
                                style: TextStyle(
                                  color: Colors.black, // สีข้อความ
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      toggleContainer('EMA');
                    },
                    child: Container(
                      width: 60, // กำหนดความกว้างของปุ่ม
                      height: 60, // กำหนดความสูงของปุ่ม
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color(0xFF2A3547), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 3), // changes the position of the shadow
                          ),
                        ],
                        borderRadius: BorderRadius.circular(
                            10), // กำหนดให้รูปร่างเป็นวงกลม
                        color: menuSelectionStatus['EMA'] == true
                            ? Color(0xFF2A3547)
                            : Colors.white, // สีพื้นหลังของปุ่ม
                      ),
                      child: menuSelectionStatus['EMA'] == true
                          ? Center(
                              child: Text(
                                'EMA',
                                style: TextStyle(
                                  color: Colors.white, // สีข้อความ
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                'EMA',
                                style: TextStyle(
                                  color: Colors.black, // สีข้อความ
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: selectedMenus.map((menu) {
                return menu == 'RSI'
                    ? buildRSI()
                    : menu == 'STO'
                        ? buildSTO()
                        : menu == 'MACD'
                            ? buildMACD()
                            : buildEMA();
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeframeDropdown extends StatelessWidget {
  final String selectedInterval;
  final Function(String?) onChanged;

  const TimeframeDropdown({
    required this.selectedInterval,
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
            'Timeframe',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.black,
              borderRadius: BorderRadius.circular(10),
              value: selectedInterval,
              onChanged: onChanged,
              items: const [
                DropdownMenuItem(
                  value: '1 hour',
                  child: Text(
                    '1 hour',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DropdownMenuItem(
                  value: '4 hours',
                  child: Text(
                    '4 hours',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DropdownMenuItem(
                  value: '1 day',
                  child: Text(
                    '1 day',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                DropdownMenuItem(
                  value: '1 week',
                  child: Text(
                    '1 week',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.info,
              size: 24,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timeline_sharp,
                            color: Colors.amber,
                            size: 72,
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          Text(
                            'Timeframe คืออะไร?',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'ระยะเวลาที่ใช้ในการวิเคราะห์และตัดสินใจในการซื้อหรือขายสินทรัพย์ทางการเงิน เช่น หุ้นหรือสกุลเงิน ระยะเวลาในการเทรดมักถูกแบ่งออกเป็นหลายช่วง โดยที่แต่ละช่วงมีลักษณะและค่าทางเทคนิคในการเทรดต่างกัน',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStatePropertyAll(
                                        Color(0xFFEC5B5B)),
                                    padding: MaterialStatePropertyAll(
                                        EdgeInsets.all(12))),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'ออก',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
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
              dropdownColor: const Color.fromARGB(255, 226, 218, 218),
              borderRadius: BorderRadius.circular(10),
              value: selectedDay,
              onChanged: onChanged,
              icon: const Icon(Icons.arrow_drop_down_circle),
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
              size: 24,
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
