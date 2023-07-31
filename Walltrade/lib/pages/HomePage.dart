import 'dart:convert';
import 'package:Walltrade/pages/FAQpage.dart';
import 'package:flutter_octicons/flutter_octicons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:Walltrade/pages/SettingsPage.dart';
import 'package:Walltrade/pages/moreNews2.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../model/news.dart';
import '../variables/serverURL.dart';
import 'notify_and_activity.dart';

class HomePage extends StatefulWidget {
  final String username;
  HomePage({required this.username});
  @override
  _HomePageState createState() => _HomePageState(username: username);
}

final StaticValues staticValues = StaticValues();

class _HomePageState extends State<HomePage> {
  List<String> watchlist = [];
  final String username;
  String _walletBalance = '';
  String _balanceChange = '';
  String _percentageChange = '';
  List<String> stockSymbols = [];
  
  Map<String, double> stockPrices = {};
  Map<String, double> stockPercentage = {};

  bool isChecked = false;

  bool isLoading = true;
  String ans = '';

  _HomePageState({required this.username});
  int index = 1;

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

  Future<void> getBalanceChange() async {
    var url = Uri.parse('${Constants.serverUrl}/get_balance_change');
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({'username': username}); // Replace with your username

    try {
      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var balanceChange = data['balance_change'];
        var percentageChange = data['percentage_change'];
        setState(() {
          _balanceChange = balanceChange.toStringAsFixed(2);
          _percentageChange = percentageChange.toStringAsFixed(3);
        });
      } else {
        throw Exception(
            'Failed to retrieve balance change. Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> getStockPrices() async {
    var url = '${Constants.serverUrl}/getStockPriceUS';
    var body = jsonEncode({'username': username});

    var response = await http.post(Uri.parse(url),
        body: body, headers: {'Content-Type': 'application/json'});
    var data = jsonDecode(response.body);
    ans = data.toString();
    if (data != null && data is List<dynamic>) {
      data.forEach(
        (item) {
          var symbol = item['symbol'];
          var price = item['price'];
          var percentage = item['percentage'];
          setState(() {
            stockSymbols.add(symbol);
            stockPrices[symbol] = price;
            stockPercentage[symbol] = percentage;
          });
        },
      );
    }
  }

  Future<void> deleteWatchlist(String symbol) async {
    var url = '${Constants.serverUrl}/deleteWatchlist';
    var body = jsonEncode(
        {'username': username, 'symbol': symbol}); // Add the 'symbol' parameter

    var response = await http.post(
      Uri.parse(url),
      body: body,
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      print(
          'Failed to delete watchlist item. Status code: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    getBalanceChange();
    getBalance();
    getStockPrices();
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
                                      end: Alignment.bottomCenter),
                                  shape: BoxShape.circle),
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
                                        AssetImage("assets/img/profile.png"),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Center(
                          child: Text(
                            "สวัสดี! $username",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
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
                                builder: (context) => NotifyActivity()),
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
                                builder: (context) => Settings(
                                      username: username,
                                    )),
                          );
                          // Handle settings button press here
                        },
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 80),
                          Container(
                            alignment: Alignment.topCenter,
                            child: Text(
                              'ยอดเงินคงเหลือ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            alignment: Alignment.topCenter,
                            child: Text(
                              '\$ $_walletBalance',
                              style: TextStyle(
                                fontSize: 40,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Center(
                            child: Container(
                              width: 180,
                              decoration: BoxDecoration(
                                color: Color(0xFF212436),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              padding: EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _balanceChange.toString().startsWith("-")
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    size: 18,
                                    color: _balanceChange
                                            .toString()
                                            .startsWith("-")
                                        ? Color(0xFFFF002E)
                                        : Color(0xFF00FFA3),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "$_balanceChange USD ($_percentageChange%)",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: _balanceChange
                                              .toString()
                                              .startsWith("-")
                                          ? Color(0xFFFF002E)
                                          : Color(0xFF00FFA3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    height: 100,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Home(
                                              username: username,
                                              initialIndex: 1,
                                            ),
                                            // Pass the index of the widget to navigate to (2 for TradePageOptions)
                                          ),
                                        );
                                      },
                                      child: FaIcon(
                                        FontAwesomeIcons.handHoldingDollar,
                                        size: 40,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        shape: CircleBorder(),
                                        padding: EdgeInsets.all(30),
                                        backgroundColor: Color(0xFF212436),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'ซื้อขาย',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Container(
                                    height: 100,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Home(
                                              username: username,
                                              initialIndex: 2,
                                            ),
                                            // Pass the index of the widget to navigate to (2 for TradePageOptions)
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: CircleBorder(),
                                        padding: EdgeInsets.all(30),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      child: FaIcon(
                                        FontAwesomeIcons.robot,
                                        size: 40,
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFF5E00),
                                            Color(0xFFFF0000),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'คำสั่งเทรดอัตโนมัติ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Container(
                                    height: 100,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => FAQPage(),
                                            // Pass the index of the widget to navigate to (2 for TradePageOptions)
                                          ),
                                        );
                                      },
                                      child: Icon(
                                        Icons.question_mark_rounded,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        shape: CircleBorder(),
                                        padding: EdgeInsets.all(30),
                                        backgroundColor: Color(0xFF212436),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'คำถามที่พบบ่อย',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "รายการเฝ้าดู",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('รายการเฝ้าดู'),
                                              content: Text(
                                                  'รายการเฝ้าดูจะแสดงสิ่งที่เราสนใจจากที่เราได้เพิ่มลงรายการ จะแสดงราคาปัจจุบันและเปอร์เซ็นต์การเปลี่ยนแปลงของราคาเปิดและปิดในวันนั้น'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
                                                  },
                                                  child: Text('ตกลง'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Icon(
                                        Icons.info_outline,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text("ลบรายการเฝ้าดู"),
                                          content: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            child: Wrap(
                                              spacing: 8.0,
                                              runSpacing: 8.0,
                                              children:
                                                  stockSymbols.map((symbol) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    deleteWatchlist(symbol);
                                                    setState(() {
                                                      stockSymbols.removeWhere(
                                                          (item) =>
                                                              item == symbol);
                                                    });
                                                  },
                                                  child: Chip(
                                                    label: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          symbol,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        SizedBox(width: 4),
                                                        FaIcon(
                                                          FontAwesomeIcons
                                                              .circleMinus,
                                                          size: 16,
                                                          color: Colors.red,
                                                        ),
                                                      ],
                                                    ),
                                                    backgroundColor:
                                                        Color(0xFF212436),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: FaIcon(FontAwesomeIcons.trashAlt,
                                      size: 18),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 110,
                            child: ans == '{error: Empty}'
                                ? Center(
                                    child: Text(
                                      'ไม่มีรายการเฝ้าดู',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  )
                                : stockSymbols.isEmpty
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                            color: Color(0xFFECF8F9)),
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: stockSymbols.length,
                                          itemBuilder: (context, index) {
                                            var symbol = stockSymbols[index];
                                            var price = stockPrices[symbol];
                                            var percentage =
                                                stockPercentage[symbol];
                                            return Padding(
                                              padding: EdgeInsets.all(6.0),
                                              child: Container(
                                                width: 100,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF212436),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            symbol,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          Text(
                                                            '$price',
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: percentage! >
                                                                        0
                                                                    ? Color(
                                                                        0xFF0AFF96)
                                                                    : percentage <
                                                                            0
                                                                        ? Color(
                                                                            0xFFFF002E)
                                                                        : Colors
                                                                            .white),
                                                          ),
                                                          Text(
                                                            percentage > 0
                                                                ? '+$percentage%'
                                                                : '$percentage%',
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: percentage >
                                                                        0
                                                                    ? Color(
                                                                        0xFF0AFF96)
                                                                    : percentage <
                                                                            0
                                                                        ? Color(
                                                                            0xFFFF002E)
                                                                        : Colors
                                                                            .white),
                                                          ),
                                                        ],
                                                      ),
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
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "บทความและข่าวสาร",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NewsListPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "เพิ่มเติม",
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          FutureBuilder<List<News>>(
                            future: staticValues.fetchNews(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final newsList = snapshot
                                    .data!; // Extract the fetched news list
                                return CarouselSlider(
                                  options: CarouselOptions(
                                    autoPlay: true,
                                    autoPlayInterval: Duration(seconds: 5),
                                    height: 170.0,
                                  ),
                                  items: newsList.map((news) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image(
                                                  fit: BoxFit.cover,
                                                  image:
                                                      NetworkImage(news.image),
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
                                                alignment:
                                                    Alignment.bottomCenter,
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
                                return CircularProgressIndicator();
                              }
                            },
                          ),

                          // Add other widgets below if needed
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
