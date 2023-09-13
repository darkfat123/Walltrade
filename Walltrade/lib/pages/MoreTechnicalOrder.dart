import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      'day': int.parse(dayController.text),
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
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: Color(0xFF2A3547),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // changes the position of the shadow
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes the position of the shadow
                  ),
                ],
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
                Text(
                  'สัญลักษณ์หุ้น',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: symbolController,
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
                              Colors.black, // สีเส้นโครงรอบช่องพิมพ์ในสถานะปกติ
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
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'จำนวนหุ้น',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: qtyController,
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
                              Colors.black, // สีเส้นโครงรอบช่องพิมพ์ในสถานะปกติ
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
                IconButton(
                  icon: Icon(
                    Icons.info,
                    size: 24,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('More Info'),
                          content:
                              Text('Additional information about timeframes.'),
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
            ),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedMenus.length < 2) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('เกิดข้อผิดพลาด'),
                        content: Text(
                            'โปรดเลือกเทคนิคชี้วัดที่ต้องการใช้อย่างน้อย 2 เทคนิค'),
                        actions: [
                          TextButton(
                            child: Text('ตกลง'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  multiAutotrade('buy');
                }
              },
              child: Text("ซื้อ"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedMenus.length < 2) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('เกิดข้อผิดพลาด'),
                        content: Text(
                            'โปรดเลือกเทคนิคชี้วัดที่ต้องการใช้อย่างน้อย 2 เทคนิค'),
                        actions: [
                          TextButton(
                            child: Text('ตกลง'),
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
              child: Text("ขาย"),
            )
          ],
        ),
      ),
    );
  }

  Widget buildEMA() {
    return Container(
        key: ValueKey('EMA'),
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // changes the position of the shadow
            ),
          ],
        ), // ใช้เมธอด getMenuColor เพื่อเลือกสีเมนู

        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 18),
              margin: EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: Color(0xFF2A3547),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes the position of the shadow
                  ),
                ],
              ),
              child: Row(
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
      key: ValueKey('RSI'),
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes the position of the shadow
          ),
        ],
      ), // ใช้เมธอด getMenuColor เพื่อเลือกสีเมนู
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 18),
            margin: EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: Color(0xFF2A3547),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes the position of the shadow
                ),
              ],
            ),
            child: Row(
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
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('ระบุค่า RSI ที่ต้องการซื้อ'),
                SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: lowerRSIController,
                    decoration: InputDecoration(
                      labelText: '0-100',
                      border: OutlineInputBorder(),
                    ),
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
                          content:
                              Text('Additional information about timeframes.'),
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
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Widget buildMACD() {
    return Container(
        key: ValueKey('MACD'),
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // changes the position of the shadow
            ),
          ],
        ), // ใช้เมธอด getMenuColor เพื่อเลือกสีเมนู

        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 18),
              margin: EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: Color(0xFF2A3547),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes the position of the shadow
                  ),
                ],
              ),
              child: Row(
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
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('MACD ตัดขึ้น Signal และมีโซนที่ต่ำกว่า 0'),
                  SizedBox(width: 5),
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
                            content: Text(
                                'Additional information about timeframes.'),
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('ระบุโซน MACD & Signal ที่ต้องการซื้อ'),
                  SizedBox(width: 5),
                  Expanded(
                    child: TextField(
                      controller: zoneMACDController,
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
                      size: 24,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('More Info'),
                            content: Text(
                                'Additional information about timeframes.'),
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
              ),
            ),
          ],
        ));
  }

  Widget buildSTO() {
    return Container(
      key: ValueKey('STO'),
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes the position of the shadow
          ),
        ],
      ), // ใช้เมธอด getMenuColor เพื่อเลือกสีเมนู

      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 18),
            margin: EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: Color(0xFF2A3547),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes the position of the shadow
                ),
              ],
            ),
            child: Row(
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
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('ระบุค่า STO %K และ %D ที่ต้องการซื้อ'),
                SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    controller: zoneSTOController,
                    enabled: isZoneTextFieldEnabled,
                    decoration: InputDecoration(
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
                          content:
                              Text('Additional information about timeframes.'),
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('STO %K ตัดขึ้น %D และมีโซนที่ต่ำกว่า'),
                SizedBox(width: 5),
                Expanded(
                  child: TextField(
                    enabled: isCrossTextFieldEnabled,
                    controller: crossupSTOController,
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
                    size: 24,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('More Info'),
                          content:
                              Text('Additional information about timeframes.'),
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
            ),
          ),
          SizedBox(
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
            Text("สร้างคำสั่งซื้อแบบหลายเทคนิค"),
            Row(
              children: [
                IconButton(
                  iconSize: 24,
                  icon: Icon(Icons.access_time),
                  onPressed: () {
                    // Handle settings button press here
                  },
                ),
                IconButton(
                  iconSize: 24,
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    // Handle settings button press here
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
              margin: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      toggleContainer('RSI');
                    },
                    child: Container(
                      width: 60, // กำหนดความกว้างของปุ่ม
                      height: 60, // กำหนดความสูงของปุ่ม
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF2A3547), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(
                                0, 3), // changes the position of the shadow
                          ),
                        ],
                        shape: BoxShape.circle, // กำหนดให้รูปร่างเป็นวงกลม
                        color: Color(0xFFABC270), // สีพื้นหลังของปุ่ม
                      ),
                      child: const Center(
                        child: Text(
                          'RSI',
                          style: TextStyle(
                            color: Colors.white, // สีข้อความ
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
                        border: Border.all(color: Color(0xFF2A3547), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(
                                0, 3), // changes the position of the shadow
                          ),
                        ],
                        shape: BoxShape.circle, // กำหนดให้รูปร่างเป็นวงกลม
                        color: Color(0xFFFEC868), // สีพื้นหลังของปุ่ม
                      ),
                      child: Center(
                        child: Text(
                          'STO',
                          style: TextStyle(
                            color: Colors.white, // สีข้อความ
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
                        border: Border.all(color: Color(0xFF2A3547), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(
                                0, 3), // changes the position of the shadow
                          ),
                        ],
                        shape: BoxShape.circle, // กำหนดให้รูปร่างเป็นวงกลม
                        color: Color(0xFFFDA769), // สีพื้นหลังของปุ่ม
                      ),
                      child: Center(
                        child: Text(
                          'MACD',
                          style: TextStyle(
                            color: Colors.white, // สีข้อความ
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
                        border: Border.all(color: Color(0xFF2A3547), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(
                                0, 3), // changes the position of the shadow
                          ),
                        ],
                        shape: BoxShape.circle, // กำหนดให้รูปร่างเป็นวงกลม
                        color: Color(0xFF473C33), // สีพื้นหลังของปุ่ม
                      ),
                      child: Center(
                        child: Text(
                          'EMA',
                          style: TextStyle(
                            color: Colors.white, // สีข้อความ
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
          Text(
            'Timeframe',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.black,
              borderRadius: BorderRadius.circular(10),
              value: selectedInterval,
              onChanged: onChanged,
              items: [
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
          Text(
            'จำนวนวันของ EMA',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Color.fromARGB(255, 226, 218, 218),
              borderRadius: BorderRadius.circular(10),
              value: selectedDay,
              onChanged: onChanged,
              icon: Icon(Icons.arrow_drop_down_circle),
              items: [
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
      ),
    );
  }
}
