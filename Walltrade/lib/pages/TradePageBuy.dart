import 'dart:convert';
import 'package:flutter/material.dart';
import '../variables/serverURL.dart';
import 'package:http/http.dart' as http;

class TradePageBuy extends StatefulWidget {
  final String username;
  final String symbol;
  TradePageBuy({required this.username,required this.symbol});
  @override
  _TradePageBuyState createState() => _TradePageBuyState(username: username,symbol:symbol);
}

class _TradePageBuyState extends State<TradePageBuy> {
  TextEditingController timeIntervalController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController lowerRSIController = TextEditingController();
  TextEditingController zoneMACDController = TextEditingController();
  TextEditingController crossupSTOController = TextEditingController();
  TextEditingController zoneSTOController = TextEditingController();
  TextEditingController dayController = TextEditingController();
  String fixedZoneValue = '0';
  bool isZoneTextFieldEnabled = true;
  bool isCrossTextFieldEnabled = true;
  final String username;
  final TextEditingController _searchController = TextEditingController();
  bool macd_crossupIsChecked = false;
  String searchText = '';
  String _walletBalance = '';
  bool showDetails = false;
  String selectedInterval = '1h';
  String result = '';
  _TradePageBuyState({required this.username, required this.symbol});
  final String symbol;
  void _handleSubmit() {
    setState(() {
      searchText = _searchController.text;
    });
  }

  Future<void> placeOrderRSI(String qty, String side) async {
    final url = Uri.parse('${Constants.serverUrl}/autotradeRSI');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(
      {
        'username': widget.username,
        'symbol': symbol,
        'qty': double.parse(qty),
        'side': side,
        'lowerRSI': lowerRSIController.text
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

  Future<void> placeOrderMACD(String qty, String side) async {
    final url = Uri.parse('${Constants.serverUrl}/autotradeMACD');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(
      {
        'username': widget.username,
        'symbol': "BTCUSD",
        'qty': double.parse(qty),
        'side': side,
        'cross_macd': macd_crossupIsChecked,
        'zone': double.parse(zoneMACDController.text)
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

  Future<void> placeOrderSTO(String qty, String side) async {
    final url = Uri.parse('${Constants.serverUrl}/autotradeSTO');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(
      {
        'username': widget.username,
        'symbol': "BTCUSD",
        'qty': double.parse(qty),
        'side': side,
        'cross_sto': crossupSTOController.text,
        'zone': zoneSTOController.text
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

  Future<void> placeOrderEMA(String qty, String side) async {
    final url = Uri.parse('${Constants.serverUrl}/autotradeEMA');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(
      {
        'username': widget.username,
        'symbol': "BTCUSD",
        'qty': double.parse(qty),
        'side': side,
        'day': dayController.text,
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

  Future<void> getBalance() async {
    var url = Uri.parse('${Constants.serverUrl}/getBalance');
    var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
    var body = {'username': username};

    try {
      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var walletBalance = data['wallet_balance'];
        setState(
          () {
            _walletBalance = walletBalance.toString();
          },
        );
      } else {
        throw Exception(
            'Failed to retrieve wallet balance. Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getBalance();
  }

  @override
  void dispose() {
    // ยกเลิก timer หรือ animation ที่ใช้งาน
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      Text('ระบุค่า RSI ที่ต้องการซื้อ'),
                      SizedBox(width: 5),
                      Expanded(
                        child: TextField(
                          controller: lowerRSIController,
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
                          decoration: InputDecoration(
                            labelText: 'จำนวน',
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
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('ยืนยันคำสั่งซื้อ'),
                          content: IntrinsicHeight(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "ประเภทคำสั่ง: ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Chip(
                                        backgroundColor: Colors.green,
                                        label: Text(
                                          "ซื้อ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white),
                                        )),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'จำนวน: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '${qtyController.text} หน่วย',
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'เทคนิคที่ใช้: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      'RSI น้อยกว่า ${lowerRSIController.text} ',
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: Text('ตกลง'),
                              onPressed: () {
                                placeOrderRSI(qtyController.text, 'buy');
                                Navigator.of(context).pop();

                                // แสดง Snackbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Order placed successfully!'), // ข้อความที่ต้องการแสดงใน Snackbar
                                    duration: Duration(
                                        seconds:
                                            2), // ระยะเวลาในการแสดง Snackbar
                                  ),
                                );
                              },
                            ),
                          ],
                        );
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
                      Text('จำนวน'),
                      SizedBox(width: 5),
                      Expanded(
                        child: TextField(
                          controller: qtyController,
                          decoration: InputDecoration(
                            labelText: 'จำนวน',
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
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('ยืนยัน'),
                          content: Text('Submit button pressed!'),
                          actions: [
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                placeOrderSTO(qtyController.text, 'buy');
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
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
                      Text('MACD ตัดขึ้น Signal และมีโซนที่ต่ำกว่า 0'),
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
                          decoration: InputDecoration(
                            labelText: 'จำนวน',
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
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('ยืนยัน'),
                          content: Text('กด OK เพื่อยืนยันการสั่งซื้อ'),
                          actions: [
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                placeOrderMACD(qtyController.text, "buy");
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('ระบุวันของ EMA'),
                      SizedBox(width: 5),
                      Expanded(
                        child: TextField(
                          controller: dayController,
                          decoration: InputDecoration(
                            labelText: 'จำนวนวันที่ต้องการใช้',
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
                          decoration: InputDecoration(
                            labelText: 'จำนวน',
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
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('ยืนยัน'),
                          content: Text('Submit button pressed!'),
                          actions: [
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                placeOrderEMA(qtyController.text, "buy");
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Submit'),
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
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(10),
              value: selectedInterval,
              onChanged: onChanged,
              items: const [
                DropdownMenuItem(
                  value: '1h',
                  child: Text(
                    '1 hour',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                DropdownMenuItem(
                  value: '4h',
                  child: Text(
                    '4 hours',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                DropdownMenuItem(
                  value: '1D',
                  child: Text(
                    '1 day',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                DropdownMenuItem(
                  value: '1W',
                  child: Text(
                    '1 week',
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
      ),
    );
  }
}
