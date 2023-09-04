import 'dart:convert';
import 'package:Walltrade/pages/TradePageSell.dart';
import 'package:Walltrade/pages/MoreTechnicalOrder.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:Walltrade/pages/TradePageBuy.dart';
import 'package:Walltrade/primary.dart';
import 'package:flutter/material.dart';

import '../model/knowledge.dart';
import '../model/news.dart';
import '../variables/serverURL.dart';

import 'KnowledgeDetailPage.dart';
import 'SettingsPage.dart';
import 'HistoryAutoTrade.dart';

class TradePageOptions extends StatefulWidget {
  const TradePageOptions({Key? key, required this.username}) : super(key: key);
  final String username;
  @override
  _TradePageOptionsState createState() =>
      _TradePageOptionsState(username: username);
}

final BuildKnowledge knowledge = BuildKnowledge();

class _TradePageOptionsState extends State<TradePageOptions>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final String username;
  List<dynamic> autoOrders = [];
  int _selectedIndex = 0;
  String _walletBalance = "";
  bool isLoading = true;
  _TradePageOptionsState({required this.username});

  Future<void> getAutoOrders() async {
    final url = '${Constants.serverUrl}/getAutoOrders';
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'username': username});
    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      for (final order in responseData) {
        final status = order['status'];
        if (status == 'pending') {
          autoOrders.add(order); 
        }
      }
      isLoading = false;
    } else {
      print("Error");
    }
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {
        tabController.index;
      });
    });
    getCash();
    getAutoOrders();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
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
                              height:80,
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
                          "สร้างคำสั่งเทรดอัตโนมัติ",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        iconSize: 30,
                        icon: Icon(Icons.settings),
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
              SizedBox(
                height: 10,
              ),
              FutureBuilder<List<Knowledge>>(
                future: fetchKnowledge(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Failed to load knowledge');
                  } else {
                    final knowledgeList = snapshot.data!;

                    return CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 4),
                        height: 150.0,
                      ),
                      items: knowledgeList.map((knowledge) {
                        return Builder(
                          builder: (BuildContext context) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => KnowledgeDetailPage(
                                      title: knowledge.title,
                                      description: knowledge.description,
                                      imageUrl: knowledge.image,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(knowledge.image),
                                        width:
                                            MediaQuery.of(context).size.width,
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
                                        height: 40,
                                        padding: EdgeInsets.all(8),
                                        margin: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                        child: Text(
                                          knowledge.title,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 20, left: 12.0, right: 12.0, bottom: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "คำสั่งที่รอการดำเนินการ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotifyActivity(
                                    username: username,
                                  )),
                        );
                      },
                      child: Text(
                        "เพิ่มเติม",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                  height: 110,
                  child: autoOrders.length == 0
                      ? Center(
                          child: Text("ไม่มีคำสั่งที่รอการดำเนินการ"),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: autoOrders.length,
                          itemBuilder: (context, index) {
                            final order = autoOrders[index];
                            return Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          order['symbol'],
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
                                        Container(
                                          padding: EdgeInsets.all(4),
                                          margin: EdgeInsets.symmetric(vertical:2),
                                          decoration: BoxDecoration(
                                              color: order['side'] == 'buy'
                                                  ? Colors.green
                                                  : Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Text(
                                            order['side'] == 'buy'
                                                ? '  ซื้อ  '
                                                : ' ขาย ',
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
                              ),
                            );
                          },
                        ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MoreTechnicalOrder(
                              username: username,
                            )),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  margin: EdgeInsets.all(20),
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Color(0xFFE55807),
                      Color(0xFF7E1717),
                    ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(128, 0, 0, 0),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'สร้างคำสั่งแบบหลายเทคนิค',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            fontSize: 18),
                      ),
                      Icon(
                        Icons.arrow_circle_right_outlined,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "คำเตือน: ",
                    style: TextStyle(fontSize: 12, color: Colors.yellow[900]),
                  ),
                  Text(
                    "โปรดเลือกเพียง 1 ตัวชี้วัดทางเทคนิคต่อ 1 คำสั่ง",
                    style: TextStyle(fontSize: 12, color: Colors.yellow[900]),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ยอดเงินที่ใช้งานได้: ",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "$_walletBalance USD",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                height: 800,
                child: Column(
                  children: [
                    Container(
                      height: 45,
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Container(
                          child: TabBar(
                            unselectedLabelColor: Colors.white,
                            labelColor: Colors.black,
                            indicatorWeight: 2,
                            controller: tabController,
                            tabs: [
                              Tab(
                                child: Text(
                                  'คำสั่งซื้อ',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  'คำสั่งขาย',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: tabController.index == 0
                                  ? Colors.green
                                  : Colors.red, // สีค่าตัวบอกสถานะเริ่มต้น
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          TradePageBuy(
                            username: username,
                          ),
                          TradePageSell(
                            username: username,
                          ),
                        ],
                      ),
                    ),
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
