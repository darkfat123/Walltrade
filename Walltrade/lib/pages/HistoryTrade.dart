import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../variables/serverURL.dart';

class HistoryTrade extends StatefulWidget {
  final String username;
  HistoryTrade({required this.username});
  @override
  _HistoryTrade createState() => _HistoryTrade(username: username);
}

class _HistoryTrade extends State<HistoryTrade> {
  final String username;
  List<dynamic> autoOrders = [];
  bool isLoading = true;
  _HistoryTrade({required this.username});

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
        print(order['techniques']);
      }
      print(autoOrders.length);
    } else {
      print("Error");
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
        backgroundColor: Color(0xFFECF8F9),
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
              itemCount: autoOrders.length,
              itemBuilder: (context, index) {
                final order = autoOrders[index];

                return Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.all(14),
                  height: 150,
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
                          Row(
                            children: [
                              Icon(Icons.circle,size: 14,color: Colors.yellow.shade800,),
                              SizedBox(width: 8,),
                              Text(
                                "กำลังดำเนินการ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
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
                            backgroundColor: Colors.blue.shade300,
                            label: Text(
                              order['techniques'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
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
                            "buy or sell: ",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            order['side'],
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
            Center(
              child: Text("Activity Page"),
            )
          ],
        ),
      ),
    );
  }
}
