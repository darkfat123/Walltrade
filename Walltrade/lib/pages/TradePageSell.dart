import 'dart:convert';

import 'package:Walltrade/pages/SettingsPage.dart';
import 'package:flutter/material.dart';
import '../variables/serverURL.dart';
import 'HistoryAutoTrade.dart';
import 'package:http/http.dart' as http;

class TradePageSell extends StatefulWidget {
  final String username;
  TradePageSell({required this.username});
  @override
  _TradePageSellState createState() => _TradePageSellState(username: username);
}

class _TradePageSellState extends State<TradePageSell> {
  final String username;
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  String _walletBalance = '';
  bool showDetails = false;
  String selectedInterval = '1 hour';
  _TradePageSellState({required this.username});
  void _handleSubmit() {
    setState(() {
      searchText = _searchController.text;
    });
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
        print(_walletBalance);
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
  Widget build(BuildContext context) {
    String username = widget.username;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFECF8F9),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: [
                  Container(
                    child: ExpansionTile(
                      title: Text(
                        'RSI',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
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
                                  decoration: InputDecoration(
                                    labelText: 'ค่าที่ต้องการขาย',
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
                  ),
                  Container(
                    child: ExpansionTile(
                      title: Text(
                        'STO',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
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
                              Text('ระบุค่า STO ที่ต้องการซื้อ'),
                              SizedBox(width: 5),
                              Expanded(
                                child: TextField(
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
                  ),
                  Container(
                    child: ExpansionTile(
                      title: Text(
                        'MACD',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
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
                              Text('ระบุค่า MACD ที่ต้องการซื้อ'),
                              SizedBox(width: 5),
                              Expanded(
                                child: TextField(
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
                  ),
                  Container(
                    child: ExpansionTile(
                      title: Text(
                        'MA',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
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
                              Text('ระบุค่า MA ที่ต้องการซื้อ'),
                              SizedBox(width: 5),
                              Expanded(
                                child: TextField(
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
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
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
          Text('โปรดเลือก Timeframe'),
          DropdownButton<String>(
            value: selectedInterval,
            onChanged: onChanged,
            items: [
              DropdownMenuItem(
                value: '1 hour',
                child: Text('1 hour'),
              ),
              DropdownMenuItem(
                value: '4 hours',
                child: Text('4 hours'),
              ),
              DropdownMenuItem(
                value: '1 day',
                child: Text('1 day'),
              ),
              DropdownMenuItem(
                value: '1 week',
                child: Text('1 week'),
              ),
              DropdownMenuItem(
                value: '1 month',
                child: Text('1 month'),
              ),
            ],
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
