import 'dart:convert';

import 'package:Walltrade/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../variables/serverURL.dart';
import 'HistoryAutoTrade.dart';

class MoreTechnicalOrder extends StatefulWidget {
  final String username;
  MoreTechnicalOrder({required this.username});
  @override
  _MoreTechnicalOrderState createState() =>
      _MoreTechnicalOrderState(username: username);
}

class _MoreTechnicalOrderState extends State<MoreTechnicalOrder> {
  TextEditingController _apiKeyController = TextEditingController();
  TextEditingController _secretKeyController = TextEditingController();
  String _walletBalance = "";
  final String username;
  _MoreTechnicalOrderState({required this.username});
  Future<void> getCash() async {
    var url = Uri.parse('${Constants.serverUrl}/getCash');
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
            _walletBalance =
                double.tryParse(walletBalance)?.toStringAsFixed(2) ?? "Invalid";
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
    getCash();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFECF8F9),
        appBar: AppBar(
          backgroundColor: Color(0xFF212436),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('สร้างคำสั่งแบบหลายเทคนิค'),
              IconButton(
                iconSize: 30,
                icon: Icon(Icons.access_time),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotifyActivity(
                              username: username,
                            )),
                  );
                  // Handle settings button press here
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color(0xFF212436),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset:
                          Offset(0, 3), // changes the position of the shadow
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Home(
                        initialIndex: 4,
                        username: username,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "ยอดเงินที่ใช้งานได้: ",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "$_walletBalance USD",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset:
                          Offset(0, 3), // changes the position of the shadow
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "หุ้นอเมริกา",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.transparent,
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration:
                                  const BoxDecoration(shape: BoxShape.circle),
                              child: Padding(
                                //this padding will be you border size
                                padding: const EdgeInsets.all(3.5),
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    foregroundImage:
                                        AssetImage("assets/img/usflag.png"),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white, // สีพื้นหลัง
                          borderRadius: BorderRadius.circular(
                              20.0), // กำหนดความโค้งของมุม
                          border: Border.all()),
                      child: TextField(
                        controller: _apiKeyController,
                        decoration: InputDecoration(
                          labelText: 'API Key',
                          border: InputBorder
                              .none, // เอาเส้นขอบของ TextField ออก เนื่องจากเราใส่ความโค้งให้กับ Container แล้ว
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical:
                                  8.0), // กำหนดระยะห่างของข้อความใน TextField
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.white, // สีพื้นหลัง
                          borderRadius: BorderRadius.circular(
                              20.0), // กำหนดความโค้งของมุม
                          border: Border.all()),
                      child: TextField(
                        controller: _secretKeyController,
                        decoration: InputDecoration(
                          labelText: 'Secret Key',
                          border: InputBorder
                              .none, // เอาเส้นขอบของ TextField ออก เนื่องจากเราใส่ความโค้งให้กับ Container แล้ว
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical:
                                  8.0), // กำหนดระยะห่างของข้อความใน TextField
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
