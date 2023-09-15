import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../variables/serverURL.dart';

class NotifyActivity extends StatefulWidget {
  final String username;
  NotifyActivity({required this.username});
  @override
  _NotifyActivity createState() => _NotifyActivity(username: username);
}

class _NotifyActivity extends State<NotifyActivity> {
  final String username;
  List<dynamic> autoOrders = [];
  List<dynamic> autoOrdersPending = [];
  List<dynamic> autoOrdersCompleted = [];
  bool isLoading = true;
  _NotifyActivity({required this.username});

  Future<void> getAutoOrders() async {
    final url = '${Constants.serverUrl}/getAutoOrders';
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'username': username});
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      setState(() {
        autoOrders = jsonDecode(response.body);
        isLoading = false;
      });
      for (final order in autoOrders) {
        if (order['status'] == 'pending') {
          autoOrdersPending.add(order);
        } else {
          autoOrdersCompleted.add(order);
        }
      }
    } else {
      print("Error");
    }
  }

  Future<void> cancelOrder(int orderID, bool isCancel) async {
    // Replace with your Flask server's URL
    final String serverUrl = '${Constants.serverUrl}/cancelOrder';

    final Map<String, dynamic> requestData = {
      'username': username,
      'orderID': orderID,
      'isCancel': isCancel,
    };

    final response = await http.post(
      Uri.parse(serverUrl),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final message = jsonResponse.toString();
      // Handle the success message here
      print(message);
    } else {
      // Handle error
      print('Request failed with status: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    getAutoOrders();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xFF212436),
          title: Text('คำสั่งเทรดอัตโนมัติ'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'กำลังดำเนินการ'),
              Tab(text: 'สำเร็จแล้ว'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: autoOrdersPending.length,
              itemBuilder: (context, index) {
                final order = autoOrdersPending[index];
                return Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(128, 0, 0, 0),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order['symbol'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 14,
                                color: Colors.yellow.shade800,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                "กำลังดำเนินการ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              GestureDetector(
                                onTap: () {
                                  cancelOrder(order['OrderID'], true);
                                  setState(() {
                                    autoOrdersPending.remove(order);
                                    autoOrdersCompleted.add(order);
                                  });
                                  print(autoOrdersPending);
                                  final snackBar = SnackBar(
                                    content: Text('Order removed'),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                },
                                child: Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 18,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            "เทคนิคชี้วัดที่ใช้: ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Chip(
                            backgroundColor: Color(0xFF212436),
                            label: Wrap(
                              children: [
                                Text(
                                  "${order['techniques']}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "หมายเลขคำสั่ง: ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "${order['OrderID'].toString()}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "จำนวน: ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "${order['quantity'].toString()} หน่วย",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "ประเภท: ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Chip(
                            backgroundColor: order['side'] == 'buy'
                                ? Colors.green
                                : Colors.red,
                            label: Text(
                              order['side'] == 'buy' ? 'ซื้อ' : 'ขาย',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Add additional information or widgets related to the stock here
                    ],
                  ),
                );
              },
            ),
            Center(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: autoOrdersCompleted.length,
                itemBuilder: (context, index) {
                  final order = autoOrdersCompleted[index];

                  return Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromARGB(128, 0, 0, 0),
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order['symbol'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            order['status'] == 'completed'
                                ? Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 14,
                                        color: Colors.green,
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        "สำเร็จแล้ว",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                    ],
                                  )
                                : Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 14,
                                  color: Colors.red,
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "ยกเลิก",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Text(
                              "เทคนิคชี้วัดที่ใช้: ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            Chip(
                              backgroundColor: Color(0xFF212436),
                              label: Text(
                                order['techniques'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "หมายเลขคำสั่ง: ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "${order['OrderID'].toString()}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "จำนวน: ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "${order['quantity'].toString()} หน่วย",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              "ประเภท: ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              order['side'] == 'buy' ? 'ซื้อ' : 'ขาย',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),

                        // Add additional information or widgets related to the stock here
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
