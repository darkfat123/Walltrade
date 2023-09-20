import 'dart:convert';
import 'package:Walltrade/pages/TradePageSell.dart';
import 'package:Walltrade/pages/MoreTechnicalOrder.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:Walltrade/pages/TradePageBuy.dart';
import 'package:Walltrade/primary.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/knowledge.dart';
import '../model/news.dart';
import '../variables/serverURL.dart';
import 'package:quickalert/quickalert.dart';
import '../variables/symbolInput.dart';
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
  double _walletBalance = 0;
  bool isLoading = true;
  double TH_Fiat = 0;
  TextEditingController symbolController = TextEditingController();
  _TradePageOptionsState({required this.username});
  bool isFetching = true;
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

  Map<String, dynamic> technicalInfo = {};

  Future<void> fetchtechnicalInfo(String symbol) async {
    final url = Uri.parse('${Constants.serverUrl}/technicalVauleOfSymbol');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'symbol': symbol});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      setState(() {
        technicalInfo = responseData;
        isFetching = false;
      });
      print(symbol);
    } else {
      throw Exception('เกิดข้อผิดพลาดในการรับข้อมูล');
    }
  }

  Future<void> getThaiFiat() async {
    var commonUrl = Uri.parse('${Constants.serverUrl}/th_portfolio');
    var headers = {'Content-Type': 'application/json'};
    var body = {'username': username};
    var response4 =
        await http.post(commonUrl, headers: headers, body: jsonEncode(body));

    if (response4.statusCode == 200) {
      var data4 = jsonDecode(response4.body);
      var th_fiat = data4['lineAvailable'];
      setState(() {
        TH_Fiat = double.parse(th_fiat);
      });
    } else {
      throw Exception(
          'Failed to retrieve TH portfolio. Error: ${response4.body}');
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
    getThaiFiat();
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
            _walletBalance = double.parse(walletBalance);
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
    return ChangeNotifierProvider(
      create: (context) => Data(),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Builder(
            builder: (BuildContext context) {
              return SingleChildScrollView(
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
                                          foregroundImage: AssetImage(
                                              "assets/img/profile.png"),
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                                          builder: (context) =>
                                              KnowledgeDetailPage(
                                            title: knowledge.title,
                                            description: knowledge.description,
                                            imageUrl: knowledge.image,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Image(
                                              fit: BoxFit.cover,
                                              image:
                                                  NetworkImage(knowledge.image),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                            ),
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  const Color(0x00000000),
                                                  const Color(0xCC000000),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                                                color: Colors.black
                                                    .withOpacity(0.5),
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
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 2),
                                                decoration: BoxDecoration(
                                                    color:
                                                        order['side'] == 'buy'
                                                            ? Color(0xFF82CD47)
                                                            : Color(0xFFBB2525),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Text(
                                                  order['side'] == 'buy'
                                                      ? '  ซื้อ  '
                                                      : ' ขาย ',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
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
                          color: const Color(0xFF2A3547),
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
                          border: Border.all(
                            strokeAlign: BorderSide.strokeAlignOutside,
                            width: 2,
                            color: Colors.blueGrey,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'สร้างคำสั่งแบบหลายเทคนิค',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                fontSize: 18,
                              ),
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
                          style: TextStyle(
                              fontSize: 12, color: Colors.yellow[900]),
                        ),
                        Text(
                          "โปรดเลือกเพียง 1 ตัวชี้วัดทางเทคนิคต่อ 1 คำสั่ง",
                          style: TextStyle(
                              fontSize: 12, color: Colors.yellow[900]),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          margin:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
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
                          child: Column(
                            children: [
                              Text(
                                "หุ้นอเมริกา",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '${NumberFormat('#,##0.##', 'en_US').format(_walletBalance)} USD',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          margin:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
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
                          child: Column(
                            children: [
                              Text(
                                "หุ้นไทย",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                '${NumberFormat('#,##0.##', 'en_US').format(TH_Fiat)} USD',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child:
                                Consumer<Data>(builder: (context, data, child) {
                              return TextField(
                                controller: symbolController,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500),
                                decoration: const InputDecoration(
                                  labelText: 'พิมพ์สัญลักษณ์หุ้น...',
                                  labelStyle: TextStyle(
                                      fontSize: 14, color: Colors.black),

                                  filled: true, // กำหนดให้มีสีพื้นหลัง
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 18.0,
                                      horizontal:
                                          10.0), // ปรับความสูงและความยาวของช่องพิมพ์ที่นี่
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(
                                      color: Color.fromARGB(255, 211, 205,
                                          205), // สีเส้นโครงรอบช่องพิมพ์ในสถานะปกติ
                                      width:
                                          2.0, // ความหนาของเส้นโครงรอบช่องพิมพ์ในสถานะปกติ
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide(
                                      color: Colors
                                          .black, // สีเส้นโครงรอบช่องพิมพ์เมื่อมีการเน้น
                                      width:
                                          2.0, // ความหนาของเส้นโครงรอบช่องพิมพ์เมื่อมีการเน้น
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  data.text = value; // อัปเดตข้อมูลใน Data
                                },
                              );
                            }),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: ElevatedButton(
                            onPressed: () {
                              symbolController.text == ''
                                  ? showDialog(
                                      context:
                                          context, // BuildContext จำเป็นต้องใช้ในการสร้าง AlertDialog
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                              "เกิดข้อผิดพลาด"), // ข้อความหัวเรื่องของ AlertDialog
                                          content: Text(
                                              "โปรดพิมพ์สัญลักษณ์หุ้นให้ถูกต้อง"), // เนื้อหาของ AlertDialog
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // ปิด AlertDialog เมื่อปุ่มถูกกด
                                              },
                                              child: Text(
                                                  "ปิด"), // ปุ่มปิด AlertDialog
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                  : showDialog(
                                      context:
                                          context, // BuildContext จำเป็นต้องใช้ในการสร้าง AlertDialog
                                      builder: (BuildContext context) {
                                        fetchtechnicalInfo(
                                            symbolController.text);
                                        return AlertDialog(
                                                title: Center(
                                                  child: Text("ค่าเทคนิค"),
                                                ), // ข้อความหัวเรื่องของ AlertDialog
                                                content: IntrinsicHeight(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        margin:
                                                            EdgeInsets.all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color(
                                                              0xFF2A3547),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.5),
                                                              spreadRadius: 2,
                                                              blurRadius: 5,
                                                              offset: Offset(0,
                                                                  3), // changes the position of the shadow
                                                            ),
                                                          ],
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              "ราคาปิดปัจจุบัน: ",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            Text(
                                                              technicalInfo[
                                                                      'close']
                                                                  .toStringAsFixed(
                                                                      2),
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        margin:
                                                            EdgeInsets.all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .grey.shade200,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.5),
                                                              spreadRadius: 2,
                                                              blurRadius: 5,
                                                              offset: Offset(0,
                                                                  3), // changes the position of the shadow
                                                            ),
                                                          ],
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "RSI: ",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 16),
                                                            ),
                                                            Text(
                                                              technicalInfo[
                                                                      'rsi']
                                                                  .toStringAsFixed(
                                                                      2),
                                                              style: TextStyle(
                                                                  fontSize: 14),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        margin:
                                                            EdgeInsets.all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .grey.shade200,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.5),
                                                              spreadRadius: 2,
                                                              blurRadius: 5,
                                                              offset: Offset(0,
                                                                  3), // changes the position of the shadow
                                                            ),
                                                          ],
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "Stochastic %K: ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                Text(
                                                                  technicalInfo[
                                                                          'stoK']
                                                                      .toStringAsFixed(
                                                                          2),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "Stochastic %D: ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                Text(
                                                                  technicalInfo[
                                                                          'stoD']
                                                                      .toStringAsFixed(
                                                                          2),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        margin:
                                                            EdgeInsets.all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .grey.shade200,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.5),
                                                              spreadRadius: 2,
                                                              blurRadius: 5,
                                                              offset: Offset(0,
                                                                  3), // changes the position of the shadow
                                                            ),
                                                          ],
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "MACD: ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                Text(
                                                                  technicalInfo[
                                                                          'macd']
                                                                      .toStringAsFixed(
                                                                          2),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "Signal: ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                Text(
                                                                  technicalInfo[
                                                                          'signal']
                                                                      .toStringAsFixed(
                                                                          2),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        margin:
                                                            EdgeInsets.all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .grey.shade200,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.5),
                                                              spreadRadius: 2,
                                                              blurRadius: 5,
                                                              offset: Offset(0,
                                                                  3), // changes the position of the shadow
                                                            ),
                                                          ],
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "EMA5: ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                Text(
                                                                  technicalInfo[
                                                                          'ema5']
                                                                      .toStringAsFixed(
                                                                          2),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "EMA10: ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                Text(
                                                                  technicalInfo[
                                                                          'ema10']
                                                                      .toStringAsFixed(
                                                                          2),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "EMA20: ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                Text(
                                                                  technicalInfo[
                                                                          'ema20']
                                                                      .toStringAsFixed(
                                                                          2),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "EMA50: ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                Text(
                                                                  technicalInfo[
                                                                          'ema50']
                                                                      .toStringAsFixed(
                                                                          2),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "EMA100: ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                Text(
                                                                  technicalInfo[
                                                                          'ema100']
                                                                      .toStringAsFixed(
                                                                          2),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  "EMA200: ",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                                Text(
                                                                  technicalInfo[
                                                                          'ema200']
                                                                      .toStringAsFixed(
                                                                          2),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); // ปิด AlertDialog เมื่อปุ่มถูกกด
                                                    },
                                                    child: Text(
                                                        "ปิด"), // ปุ่มปิด AlertDialog
                                                  ),
                                                ],
                                              );
                                      },
                                    );
                            },
                            child: Container(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                color: Color(0xFF212436),
                                child: Text("ค่าเทคนิค")),
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
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0,
                                      3), // changes the position of the shadow
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Container(
                                child: TabBar(
                                  unselectedLabelColor: Colors.black,
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
                                        ? Color(0xFF82CD47)
                                        : Color(
                                            0xFFBB2525), // สีค่าตัวบอกสถานะเริ่มต้น
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
              );
            },
          ),
        ),
      ),
    );
  }
}


