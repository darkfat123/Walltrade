import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<void> _predictStock() async {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFECF8F9),
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
                              fontSize: 24, fontWeight: FontWeight.w600),
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
                padding: const EdgeInsets.all(20.0),
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
                    TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        labelText: 'พิมพ์อักษรย่อของหุ้น',
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _predictStock,
                        child: Text(
                          'ทำนาย',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ),
                    ),
                    Text(
                      _prediction,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
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
                        height: 180.0,
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
