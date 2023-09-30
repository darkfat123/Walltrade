import 'dart:convert';
import 'dart:math';
import 'package:Walltrade/pages/FAQpage.dart';
import 'package:Walltrade/pages/HistoryAutoTrade.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:Walltrade/pages/SettingsPage.dart';
import 'package:Walltrade/pages/moreNews2.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../model/news.dart';
import '../variables/serverURL.dart';
import 'package:intl/intl.dart';

import '../widget/snackBar/DeleteWatchlistSuccess.dart';
import 'FirebaseAuth/auth.dart';

class HomePage extends StatefulWidget {
  final String username;
  HomePage({required this.username});
  final User? user = Auth().currentUser;
  @override
  _HomePageState createState() => _HomePageState(username: username);
}

late Future<List<News>> _newsFuture;

class _HomePageState extends State<HomePage> {
  List<String> watchlist = [];
  final String username;
  double _walletBalance = 0;
  int value = 0;
  double totalBalance = 0;
  double totalProfit = 0;
  double _balanceChange = 0;
  double TH_percentage = 0;
  double totalPercentage = 0;
  double TH_totalProfit = 0;
  double _percentageChange = 0;
  List<String> stockSymbols = [];
  double TH_balance = 0;

  Map<String, double> stockPrices = {};
  Map<String, double> stockPercentage = {};
  Map<String, String> stockTags = {};

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

        setState(() {
          _walletBalance = double.parse(double.parse(walletBalance)
              .toStringAsFixed(2)); // แปลง String เป็น double
          print(_walletBalance.runtimeType);
          print(_walletBalance);
        });
      } else {
        throw Exception(
            'Failed to retrieve wallet balance. Error: ${response.body}');
      }
    } catch (e) {
      _walletBalance = 0;
    }
  }

  Future<void> getBalanceChange() async {
    // TH HTTP request
    var url1 = Uri.parse('${Constants.serverUrl}/th_portfolio');
    var headers1 = {'Content-Type': 'application/json'};
    var body1 = {'username': username};
    var response1 =
        await http.post(url1, headers: headers1, body: jsonEncode(body1));
    double USDtoTHB = 0;
    if (response1.statusCode == 200) {
      var data1 = jsonDecode(response1.body);
      var th_cash = data1['balance'];
      setState(() {
        TH_balance = double.parse(th_cash);
        TH_percentage = data1['percentageChange'];
        TH_totalProfit = double.parse(data1['balanceProfitChange']);
        USDtoTHB = data1['USDtoTHB'];
        totalBalance = _walletBalance + TH_balance;
      });
    } else {
      setState(() {
        TH_percentage = 0;
        TH_totalProfit = 0;
      });
    }

    // US HTTP request
    var url2 = Uri.parse('${Constants.serverUrl}/get_balance_change');
    var headers2 = {'Content-Type': 'application/json'};
    var body2 = jsonEncode({'username': username});

    var response2 = await http.post(url2, headers: headers2, body: body2);
    if (response2.statusCode == 200) {
      var data2 = jsonDecode(response2.body);
      var balanceChange = data2['balance_change'];
      var percentageChange = data2['percentage_change'];
      setState(() {
        _balanceChange = balanceChange;
        print("US totalProfit: $_balanceChange");

        _percentageChange = percentageChange;
        print("US percentage: $_percentageChange");
      });
      totalProfit = (TH_totalProfit / USDtoTHB) + _balanceChange;
      totalPercentage = TH_percentage + _percentageChange;
      print("Total profit: $totalProfit");
      print("Total percentage: $totalPercentage");
    } else {
      setState(() {
        totalProfit = 0;
        totalPercentage = 0;
      });
    }
  }

  List<String> watchlist_TH = [];
  List<String> watchlist_US = [];
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
          var tags = item['tags'];
          setState(() {
            stockSymbols.add(symbol);
            stockPrices[symbol] = price.toDouble();
            stockPercentage[symbol] = percentage.toDouble();
            if (tags == "TH") {
              watchlist_TH.add(symbol);
            } else {
              watchlist_US.add(symbol);
            }
          });
        },
      );
    }
    print(watchlist_TH);
    print(watchlist_US);
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
    _newsFuture = StaticValues().fetchNews(username: username);
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
                        icon: Icon(Icons.access_time),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HistoryAutoTradePage(
                                      username: username,
                                    )),
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
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Container(
                            alignment: Alignment.topCenter,
                            child: Text(
                              '\$${NumberFormat('#,##0.##', 'en_US').format(totalBalance)}',
                              style: TextStyle(
                                fontSize: 36,
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
                                    totalProfit.toString().startsWith("-")
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    size: 18,
                                    color:
                                        totalProfit.toString().startsWith("-")
                                            ? Color(0xFFFF002E)
                                            : Color(0xFF00FFA3),
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "${totalProfit.toStringAsFixed(2)} USD (${totalPercentage.toStringAsFixed(3)}%)",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color:
                                          totalProfit.toString().startsWith("-")
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
                                      fontSize: 14,
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
                                      fontSize: 14,
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
                                      fontSize: 14,
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
                                          fontSize: 16),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Row(
                                      children: [
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
                                            size: 18,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        AnimatedToggleSwitch<
                                            int>.rollingByHeight(
                                          current: value,
                                          indicatorIconScale: 1,
                                          values: const [0, 1, 2],
                                          style: ToggleStyle(
                                              backgroundColor:
                                                  Color(0xFF424554)),
                                          onChanged: (i) {
                                            setState(() => value = i);
                                            print(value);
                                          },
                                          iconList: [
                                            Icon(Icons.all_inclusive_rounded,
                                                size: 16, color: Colors.white),
                                            Container(
                                              margin: EdgeInsets.all(4),
                                              child: Text(
                                                "US",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.all(4),
                                              child: Text(
                                                "TH",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ],
                                          height: 30,
                                          spacing: 0.5,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          title: Text("ลบรายการเฝ้าดู"),
                                          content: StatefulBuilder(
                                            builder: (context,
                                                setStateInsideDialog) {
                                              return Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.7,
                                                child: Wrap(
                                                  spacing: 6.0,
                                                  runSpacing: 6.0,
                                                  children: stockSymbols
                                                      .map((symbol) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        deleteWatchlist(symbol);
                                                        setState(() {
                                                          stockSymbols
                                                              .removeWhere(
                                                                  (item) =>
                                                                      item ==
                                                                      symbol);
                                                        });
                                                        setStateInsideDialog(
                                                            () {
                                                          stockSymbols
                                                              .removeWhere(
                                                                  (item) =>
                                                                      item ==
                                                                      symbol);
                                                        });
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          DeleteWatchlistSnackBar(
                                                              symbol: symbol),
                                                        );
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
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .white,
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
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: FaIcon(FontAwesomeIcons.trashAlt,
                                      size: 16),
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
                                          color: Colors.white,
                                        ),
                                        child: value == 1
                                            ? ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: watchlist_US.length,
                                                itemBuilder: (context, index) {
                                                  var symbol =
                                                      watchlist_US[index];
                                                  var price =
                                                      stockPrices[symbol];
                                                  var percentage =
                                                      stockPercentage[symbol];

                                                  return Container(
                                                    margin: EdgeInsets.all(6.0),
                                                    width: 100,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF212436),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12.0),
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                symbol,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              ),
                                                              Text(
                                                                '$price',
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.w500,
                                                                    color: percentage! > 0
                                                                        ? Color(0xFF0AFF96)
                                                                        : percentage < 0
                                                                            ? Color(0xFFFF002E)
                                                                            : Colors.white),
                                                              ),
                                                              Text(
                                                                percentage > 0
                                                                    ? '+$percentage%'
                                                                    : '$percentage%',
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.w500,
                                                                    color: percentage > 0
                                                                        ? Color(0xFF0AFF96)
                                                                        : percentage < 0
                                                                            ? Color(0xFFFF002E)
                                                                            : Colors.white),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        // Add additional information or widgets related to the stock here
                                                      ],
                                                    ),
                                                  );
                                                },
                                              )
                                            : value == 2
                                                ? ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        watchlist_TH.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      var symbol =
                                                          watchlist_TH[index];
                                                      var price =
                                                          stockPrices[symbol];
                                                      var percentage =
                                                          stockPercentage[
                                                              symbol];

                                                      return Container(
                                                        margin:
                                                            EdgeInsets.all(6.0),
                                                        width: 100,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xFF212436),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      12.0),
                                                              child: Column(
                                                                children: [
                                                                  Text(
                                                                    symbol,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '$price',
                                                                    style: TextStyle(
                                                                        fontSize: 14,
                                                                        fontWeight: FontWeight.w500,
                                                                        color: percentage! > 0
                                                                            ? Color(0xFF0AFF96)
                                                                            : percentage < 0
                                                                                ? Color(0xFFFF002E)
                                                                                : Colors.white),
                                                                  ),
                                                                  Text(
                                                                    percentage >
                                                                            0
                                                                        ? '+$percentage%'
                                                                        : '$percentage%',
                                                                    style: TextStyle(
                                                                        fontSize: 14,
                                                                        fontWeight: FontWeight.w500,
                                                                        color: percentage > 0
                                                                            ? Color(0xFF0AFF96)
                                                                            : percentage < 0
                                                                                ? Color(0xFFFF002E)
                                                                                : Colors.white),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            // Add additional information or widgets related to the stock here
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        stockSymbols.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      var symbol =
                                                          stockSymbols[index];
                                                      var price =
                                                          stockPrices[symbol];
                                                      var percentage =
                                                          stockPercentage[
                                                              symbol];

                                                      return Container(
                                                        margin:
                                                            EdgeInsets.all(6.0),
                                                        width: 100,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xFF212436),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .all(
                                                                      12.0),
                                                              child: Column(
                                                                children: [
                                                                  Text(
                                                                    symbol,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '$price',
                                                                    style: TextStyle(
                                                                        fontSize: 14,
                                                                        fontWeight: FontWeight.w500,
                                                                        color: percentage! > 0
                                                                            ? Color(0xFF0AFF96)
                                                                            : percentage < 0
                                                                                ? Color(0xFFFF002E)
                                                                                : Colors.white),
                                                                  ),
                                                                  Text(
                                                                    percentage >
                                                                            0
                                                                        ? '+$percentage%'
                                                                        : '$percentage%',
                                                                    style: TextStyle(
                                                                        fontSize: 14,
                                                                        fontWeight: FontWeight.w500,
                                                                        color: percentage > 0
                                                                            ? Color(0xFF0AFF96)
                                                                            : percentage < 0
                                                                                ? Color(0xFFFF002E)
                                                                                : Colors.white),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            // Add additional information or widgets related to the stock here
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  )),
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
                                    fontSize: 16,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NewsListPage(
                                          username: username,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "เพิ่มเติม",
                                    style: TextStyle(
                                      fontSize: 12,
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
                            future: _newsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final newsList = snapshot.data!;
                                print(newsList);
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
                                                  errorBuilder: (BuildContext
                                                          context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                    // สร้างวิตเจ็ตแสดงถ้าเกิดข้อผิดพลาดในการโหลดรูปภาพ
                                                    return Center(
                                                      child: Text(
                                                        'ไม่สามารถโหลดรูปภาพได้',
                                                        style: TextStyle(
                                                            fontSize: 22),
                                                      ),
                                                    );
                                                  },
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
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              news.symbol != ''
                                                  ? news.symbol
                                                              .split(",")
                                                              .length <
                                                          6
                                                      ? Container(
                                                          margin:
                                                              EdgeInsets.all(
                                                                  10.0),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient: LinearGradient(
                                                                colors: [
                                                                  Color(
                                                                      0xFFFF5E00),
                                                                  Color(
                                                                      0xFFFF0000),
                                                                ],
                                                                begin: Alignment
                                                                    .topCenter,
                                                                end: Alignment
                                                                    .bottomCenter),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.0),
                                                          ),
                                                          child: Text(
                                                            news.symbol,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        )
                                                      : Container(
                                                          margin:
                                                              EdgeInsets.all(
                                                                  10.0),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  6.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient: LinearGradient(
                                                                colors: [
                                                                  Color(
                                                                      0xFFFF5E00),
                                                                  Color(
                                                                      0xFFFF0000),
                                                                ],
                                                                begin: Alignment
                                                                    .topCenter,
                                                                end: Alignment
                                                                    .bottomCenter),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20.0),
                                                          ),
                                                          child: Text(
                                                            '${news.symbol.split(",").take(6).join(",")} and more',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 10),
                                                          ),
                                                        )
                                                  : Container()
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
                                return Center(
                                    child: CircularProgressIndicator());
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
