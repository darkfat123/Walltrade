import 'dart:convert';
import 'dart:math';

import 'package:Walltrade/pages/PortfolioDetail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../variables/serverURL.dart';
import 'SettingsPage.dart';
import 'HistoryAutoTrade.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';
import 'Treemap.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_circle_chart/flutter_circle_chart.dart';

class WalletPage extends StatefulWidget {
  final String username;
  WalletPage({required this.username});
  @override
  _WalletPageState createState() => _WalletPageState(username: username);
}

class _WalletPageState extends State<WalletPage> {
  final String username;
  bool isLoading = false;
  double _walletBalance = 0;
  double checkBalanceChange = 0;
  double TH_balance = 0;
  double totalBalance = 0;
  double US_cash = 0;
  double TH_Fiat = 0;
  double TH_percentage = 0;
  double TH_totalProfit = 0;
  double totalPercentage = 0;
  double totalProfit = 0;
  String formattedProfit = '';
  String formatted_usCash = '';
  double _balanceChange = 0;
  double TH_marketValue = 0;
  double US_marketValue = 0;
  double _percentageChange = 0;
  double TH_chartMarketValue = 0;
  double US_chartMarketValue = 0;
  double USDtoTHB = 1;
  double totalFiat = 0;
  bool isTHStocksSelected = true;
  bool isUSStocksSelected = false;
  bool isWatchlistVisible = true;
  List<dynamic> positions = [];
  List<PositData> _positDataList = [];
  double chart = 0;
  _WalletPageState({required this.username});

  bool hideBalance = false;

  void toggleBalanceVisibility() {
    setState(() {
      hideBalance = !hideBalance;
    });
  }

  @override
  void dispose() {
    // ยกเลิก timer หรือ animation ที่ใช้งาน
    super.dispose();
  }

  Future<void> fetchPositionData() async {
    try {
      final url = Uri.parse('${Constants.serverUrl}/position');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({'username': username});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final positions = json.decode(response.body) as List<dynamic>;

        final positDataList = <PositData>[];

        for (final position in positions) {
          final marketValue = double.parse(position['market_value']);
          US_marketValue += marketValue;
          positDataList.add(PositData(
            position['symbol'],
            marketValue,
            "US", // You might want to use "US" or other logic here
          ));
        }

        final url2 = Uri.parse('${Constants.serverUrl}/th_portfolio');
        final body2 = {'username': username};

        final response2 =
            await http.post(url2, headers: headers, body: jsonEncode(body2));

        if (response2.statusCode == 200) {
          final data2 = jsonDecode(response2.body);
          final portfolioList = data2['portfolioList'] as List<dynamic>;

          for (final port in portfolioList) {
            positDataList.add(PositData(
              port['symbol'],
              port['amount'] / 34,
              "TH",
            ));
          }
        }

        setState(() {
          _positDataList = positDataList;
          isLoading = false;
        });
      }
    } catch (error) {
      print('An error occurred: $error');
    }
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
            US_cash = double.parse(walletBalance);
          },
        );
        formatted_usCash = NumberFormat('#,###.##', 'en_US').format(US_cash);
      } else {
        throw Exception(
            'Failed to retrieve wallet balance. Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> getBalances() async {
    var commonUrl = Uri.parse('${Constants.serverUrl}/th_portfolio');
    var headers = {'Content-Type': 'application/json'};
    var body = {'username': username};

    var response1 =
        await http.post(commonUrl, headers: headers, body: jsonEncode(body));
    var response2 = await http.post(
        Uri.parse('${Constants.serverUrl}/get_balance_change'),
        headers: headers,
        body: jsonEncode({'username': username}));
    var response3 = await http.post(
        Uri.parse('${Constants.serverUrl}/getBalance'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': username});

    var response4 =
        await http.post(commonUrl, headers: headers, body: jsonEncode(body));

    if (response1.statusCode == 200) {
      var data1 = jsonDecode(response1.body);

      setState(() {
        TH_percentage = data1['percentageChange'];
        TH_totalProfit = double.parse(data1['balanceProfitChange']);
        USDtoTHB = data1['USDtoTHB'];
      });
    } else {
      throw Exception(
          'Failed to retrieve TH balance. Error: ${response1.body}');
    }

    if (response2.statusCode == 200) {
      var data2 = jsonDecode(response2.body);
      var balanceChange = data2['balance_change'];
      var percentageChange = data2['percentage_change'];

      setState(() {
        _balanceChange = balanceChange;
        _percentageChange = percentageChange;
      });
      totalProfit = TH_totalProfit + _balanceChange;
      formattedProfit = NumberFormat('#,###.##', 'en_US').format(totalProfit);
      totalPercentage = TH_percentage + _percentageChange;
    } else {
      throw Exception(
          'Failed to retrieve balance change. Error: ${response2.body}');
    }

    if (response3.statusCode == 200) {
      var data3 = jsonDecode(response3.body);
      var walletBalance = data3['wallet_balance'];

      setState(() {
        _walletBalance =
            double.parse(double.parse(walletBalance).toStringAsFixed(2));
        US_cash = _walletBalance;
      });
    } else {
      throw Exception(
          'Failed to retrieve wallet balance. Error: ${response3.body}');
    }

    if (response4.statusCode == 200) {
      var data4 = jsonDecode(response4.body);
      var th_cash = data4['balance'];
      var th_fiat = data4['lineAvailable'];
      var th_marketValue = data4['marketValue'];
      setState(() {
        TH_balance = double.parse(th_cash);
        TH_Fiat = double.parse(th_fiat);
        TH_marketValue = double.parse(th_marketValue);
      });
    } else {
      throw Exception(
          'Failed to retrieve TH portfolio. Error: ${response4.body}');
    }

    TH_chartMarketValue =
        TH_marketValue <= 0 ? 0 : (TH_marketValue / TH_Fiat) * 100;
    US_chartMarketValue =
        US_marketValue <= 0 ? 0 : (US_marketValue / US_cash) * 100;
    totalFiat = US_cash / TH_Fiat;
    totalBalance = _walletBalance + TH_balance;
  }

  @override
  void initState() {
    super.initState();
    getBalances();
    getCash();
    fetchPositionData();
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
                          "กระเป๋า",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
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
                                    NotifyActivity(username: username)),
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
                                    Settings(username: username)),
                          );
                          // Handle settings button press here
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(14),
                padding: EdgeInsets.all(20),
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  color: Color(0xFF2A3547),
                  borderRadius: BorderRadius.circular(10),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "ยอดเงินคงเหลือ",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        InkWell(
                          onTap: toggleBalanceVisibility,
                          child: Icon(
                            hideBalance
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: hideBalance
                                ? "**** USD"
                                : "${NumberFormat('#,###.##', 'en_US').format(totalBalance)} USD ",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: hideBalance
                                ? "\n\u2248 **** บาท"
                                : "\u2248 ${NumberFormat('#,###.##', 'en_US').format(totalBalance * 34)} บาท",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "กำไร/ขาดทุนสุทธิวันนี้: ",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          hideBalance
                              ? "**** USD (****)"
                              : "${formattedProfit.startsWith("-") ? "$formattedProfit" : "+$formattedProfit"} USD (${totalPercentage.toStringAsFixed(4)}%)",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: totalProfit.toString().startsWith("-")
                                ? Colors.red
                                : Color(0xFF13B709),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PortfolioDetailPage(username: username)),
                  );
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Color(0xFF468B97),
                      Color(0xFF1D5B79),
                    ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    borderRadius: BorderRadius.circular(10),
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
                  padding: EdgeInsets.all(14),
                  margin: EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "รายละเอียดทั้งหมดของพอร์ตลงทุน",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Icon(
                        Icons.arrow_right_alt_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 16, right: 6),
                    width: MediaQuery.of(context).size.width * 0.5,
                    padding: EdgeInsets.all(10),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircularPercentIndicator(
                          radius: 50,
                          lineWidth: 30.0,
                          backgroundColor: Colors.red,
                          animation: true,
                          animationDuration: 1000,
                          percent: totalFiat,
                          progressColor: Color(0xFF068DA9),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.circle,
                              color: Colors.blue,
                              size: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "เงินอเมริกา",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                                Text(
                                  "\u0024$formatted_usCash",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.circle,
                              color: Colors.red,
                              size: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "เงินไทย",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                                Text(
                                  "\u0024${NumberFormat('#,###.#', 'en_US').format(TH_Fiat)}",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 16),
                          padding: EdgeInsets.all(9),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircularPercentIndicator(
                                radius: 30,
                                lineWidth: 10.0,
                                animation: true,
                                animationDuration: 1000,
                                percent: TH_chartMarketValue / 100,
                                center: new Text(
                                  "${TH_chartMarketValue.toStringAsFixed(0)}%",
                                  style: TextStyle(color: Colors.white),
                                ),
                                progressColor: Colors.yellow,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "หุ้นไทย",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  Text(
                                    "\u0E3F${NumberFormat('#,###.#', 'en_US').format(TH_marketValue * USDtoTHB)}",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 16),
                          padding: EdgeInsets.all(12),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircularPercentIndicator(
                                radius: 30,
                                lineWidth: 10.0,
                                animation: true,
                                animationDuration: 1000,
                                percent: US_chartMarketValue / 100,
                                center: new Text(
                                  "${US_chartMarketValue.toStringAsFixed(0)}%",
                                  style: TextStyle(color: Colors.white),
                                ),
                                progressColor: Colors.red,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "หุ้นอเมริกา",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  Text(
                                    "\u0024${NumberFormat('#,###.#', 'en_US').format(US_marketValue)}",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TreemapState(
                                    username: username,
                                  )),
                        );
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                        padding: EdgeInsets.all(14),
                        margin: EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "ดู Treemap Chart",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            Icon(
                              Icons.arrow_right_alt_rounded,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 300,
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
                      margin: EdgeInsets.all(14),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ), // Show CircularProgressIndicator if data is loading
                              )
                            : _positDataList
                                    .isEmpty // Check if positions list is empty
                                ? Center(
                                    child: Text(
                                    "ไม่มีหุ้นที่ถืออยู่",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ) // Show CircularProgressIndicator if data is loading
                                    )
                                : _buildTreemap(),
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

  Widget _buildTreemap() {
    return SfTreemap(
      dataCount: _positDataList.length,
      colorMappers: [
        TreemapColorMapper.range(
          from: 0,
          to: 100,
          color: Colors.yellow,
        ),
        TreemapColorMapper.range(
          from: 100,
          to: 500,
          color: Colors.amber,
        ),
        TreemapColorMapper.range(
          from: 500,
          to: 800,
          color: Colors.orange.shade800,
        ),
        TreemapColorMapper.range(
          from: 800,
          to: double.infinity,
          color: Colors.red,
        ),
      ],
      weightValueMapper: (int index) {
        return _positDataList[index].marketValue;
      },
      levels: <TreemapLevel>[
        TreemapLevel(
          groupMapper: (int index) {
            return _positDataList[index].symbol;
          },
          labelBuilder: (BuildContext context, TreemapTile tile) {
            // Function to calculate font size based on weight value
            double getFontSize(double weight) {
              if (weight < 100) return 4;
              if (weight < 1000) return 8;
              if (weight < 5000) return 10;
              if (weight < 10000) return 12;
              return 14;
            }

            double fontSize = getFontSize(tile.weight);

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tile.group,
                    style: TextStyle(color: Colors.black, fontSize: fontSize),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${NumberFormat('#,###.#', 'en_US').format(tile.weight)}',
                    style: TextStyle(color: Colors.black, fontSize: fontSize),
                  ),
                ],
              ),
            );
          },
          tooltipBuilder: (BuildContext context, TreemapTile tile) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                  '''Symbol: ${tile.group}\nมูลค่าปัจจุบัน : ${NumberFormat('#,###.#', 'en_US').format(tile.weight)} USD''',
                  style: const TextStyle(color: Colors.black)),
            );
          },
        ),
      ],
    );
  }
}

class PositData {
  final String symbol;
  final double marketValue;
  final String region;
  PositData(this.symbol, this.marketValue, this.region);
}
