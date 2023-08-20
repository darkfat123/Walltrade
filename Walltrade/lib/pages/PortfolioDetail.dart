import 'dart:convert';
import 'package:Walltrade/pages/ThaiTreemap.dart';
import 'package:http/http.dart' as http;
import 'package:Walltrade/variables/serverURL.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'USTreemap.dart';

class PortfolioDetailPage extends StatefulWidget {
  final String username;
  PortfolioDetailPage({required this.username});
  @override
  _PortfolioDetailPageState createState() =>
      _PortfolioDetailPageState(username: username);
}

class _PortfolioDetailPageState extends State<PortfolioDetailPage>
    with SingleTickerProviderStateMixin {
  final String username;
  late TabController tabController;

// เพิ่มตัวแปร PageController

  int _currentIndex = 0;
  _PortfolioDetailPageState({required this.username});

  @override
  void initState() {
    super.initState();
    getBalance();
    fetchPositionData();
    getCash();

    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  bool hideBalance = false;
  void toggleBalanceVisibility() {
    setState(() {
      hideBalance = !hideBalance;
    });
  }

  double _walletBalance = 0;
  double TH_balance = 0;
  double TH_Fiat = 0;
  double US_Fiat = 0.1;
  double TH_marketValue = 0;
  double US_marketValue = 0;
  double TH_chartMarketValue = 0;
  double US_chartMarketValue = 0;
  double totalFiat = 0;
  double TH_ProfitChange = 0;
  double TH_percentageChange = 0;
  double totalbalance = 0;
  double US_cash = 0;
  double US_totalChart = 0;
  double TH_totalChart = 0;
  double totalBalance = 0;
  List<dynamic> TH_ListAssets = [];
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
          US_cash = _walletBalance;
        });
      } else {
        throw Exception(
            'Failed to retrieve wallet balance. Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }

    var url2 = Uri.parse('${Constants.serverUrl}/th_portfolio');
    var headers2 = {'Content-Type': 'application/json'};
    var body2 = {'username': username};
    var response =
        await http.post(url2, headers: headers2, body: jsonEncode(body2));
    if (response.statusCode == 200) {
      var data2 = jsonDecode(response.body);
      var th_cash = data2['balance'];
      var th_fiat = data2['lineAvailable'];
      var th_marketValue = data2['marketValue'];
      var balanceProfitChange = data2['balanceProfitChange'];
      var percentageProfitChange = data2['percentageChange'];
      var portfolioList = data2['portfolioList'];
      setState(() {
        TH_balance = double.parse(th_cash);
        TH_Fiat = double.parse(th_fiat);
        TH_marketValue = double.parse(th_marketValue);
        TH_ProfitChange = double.parse(balanceProfitChange);
        TH_percentageChange = percentageProfitChange;
        TH_totalChart = TH_marketValue / TH_Fiat;
        TH_ListAssets = portfolioList;
      });
    }

    TH_chartMarketValue = (TH_marketValue / TH_balance) * 100;
    US_chartMarketValue = (US_marketValue / US_cash) * 100;
    totalFiat = US_cash / TH_balance;
    totalBalance = _walletBalance + TH_balance;
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
            US_Fiat = double.parse(walletBalance);
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

  double _balanceChange = 0;
  double _percentageChange = 0;
  Future<void> getBalanceChange() async {
    // US HTTP request
    var url2 = Uri.parse('${Constants.serverUrl}/get_balance_change');
    var headers2 = {'Content-Type': 'application/json'};
    var body2 = jsonEncode({'username': username});

    var response2 = await http.post(url2, headers: headers2, body: body2);
    try {
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
      } else {
        throw Exception(
            'Failed to retrieve balance change. Error: ${response2.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  List<dynamic> positions = [];
  List<PositData> _positDataList = [];
  Future<void> fetchPositionData() async {
    var url = Uri.parse('${Constants.serverUrl}/position');
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({'username': username});
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      setState(() {
        positions = json.decode(response.body);
      });
      for (var position in positions) {
        // Explicitly convert market_value and cost_basis to double
        double marketValue = double.parse(position['market_value']);
        double costBasis = double.parse(position['avg_entry_price']);
        double unrealized_pl = double.parse(position['unrealized_pl']);
        double unrealized_plpc = double.parse(position['unrealized_plpc']);
        US_marketValue += marketValue;
        // เพิ่มข้อมูล PositData เข้าไปใน List ที่สร้างไว้
        _positDataList.add(PositData(position['symbol'], marketValue, costBasis,
            unrealized_pl, unrealized_plpc));
      }
      print("US Fiat: $US_Fiat");
      print("US Market: $US_marketValue");
      US_totalChart = (US_marketValue / US_Fiat);
    } else {
      print('Failed to fetch position data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('พอร์ตลงทุน'),
      ),
      body: Container(
        color: Color(0xFFECF8F9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: PageView(
                controller: PageController(viewportFraction: 0.9),
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    margin: EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFF2A3547),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "มูลค่าคงเหลือหุ้นไทย (TH)",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            InkWell(
                              onTap: toggleBalanceVisibility,
                              child: Icon(
                                hideBalance
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          hideBalance
                              ? "**** USD (****)"
                              : "${NumberFormat('#,###.##', 'en_US').format(TH_balance)} USD ",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xFFECF8F9),
                              ),
                              child: Text(
                                hideBalance
                                    ? "**** USD (****)"
                                    : "${NumberFormat('#,###.##', 'en_US').format(TH_ProfitChange).startsWith("-") ? "$TH_ProfitChange" : "+$TH_ProfitChange"} USD (${TH_percentageChange.toStringAsFixed(4)}%)",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color:
                                      TH_ProfitChange.toString().startsWith("-")
                                          ? Colors.red
                                          : Color(0xFF13B709),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    margin: EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "มูลค่าคงเหลือหุ้นอเมริกา (US)",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            InkWell(
                              onTap: toggleBalanceVisibility,
                              child: Icon(
                                hideBalance
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          hideBalance
                              ? "**** USD (****)"
                              : "${NumberFormat('#,###.##', 'en_US').format(US_cash)} USD ",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
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
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xFF2A3547),
                              ),
                              child: Text(
                                hideBalance
                                    ? "**** USD (****)"
                                    : "${NumberFormat('#,###.##', 'en_US').format(_balanceChange).startsWith("-") ? "$_balanceChange" : "+$_balanceChange"} USD (${_percentageChange.toStringAsFixed(4)}%)",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color:
                                      _balanceChange.toString().startsWith("-")
                                          ? Colors.red
                                          : Color(0xFF13B709),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            DotsIndicator(
              dotsCount: 2,
              position: _currentIndex,
              decorator: DotsDecorator(
                activeColor: Colors.red,
                size: const Size.square(9.0),
                activeSize: const Size(18.0, 9.0),
                activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            Container(
              height: 580,
              padding: EdgeInsets.all(16),
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  SingleChildScrollView(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "ทรัพย์สินหุ้นไทย (TH Stock Assets)",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18),
                            ),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 16, right: 6),
                            width: MediaQuery.of(context).size.width * 0.5,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                CircularPercentIndicator(
                                  radius: 50,
                                  lineWidth: 25.0,
                                  backgroundColor: Color(0xFF068DA9),
                                  animation: true,
                                  animationDuration: 1000,
                                  percent: TH_totalChart,
                                  progressColor: Colors.red,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                        "${(100 - TH_totalChart * 100).toStringAsFixed(1)}%"),
                                    Text("ต่อ"),
                                    Text(
                                        "${(TH_totalChart * 100).toStringAsFixed(1)}%"),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
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
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            color: Color(0xFF068DA9),
                                            size: 16,
                                          ),
                                          SizedBox(
                                            width: 12,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "เงินสดไทย",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14),
                                              ),
                                              Text(
                                                hideBalance
                                                    ? "****"
                                                    : NumberFormat(
                                                            '#,###.##', 'en_US')
                                                        .format(TH_Fiat),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
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
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                          SizedBox(
                                            width: 12,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "หุ้นไทย",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14),
                                              ),
                                              Text(hideBalance
                                                    ? "****"
                                                    : 
                                                NumberFormat('#,###.#', 'en_US')
                                                    .format(TH_marketValue),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
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
                                        ThaiTreemapState(username: username)),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(14),
                              margin: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 6),
                              decoration: BoxDecoration(
                                  color: Colors.red.shade900,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "ดู Treemap หุ้นไทย",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
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
                            height: 4,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 12),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics:
                                  NeverScrollableScrollPhysics(), // ปิดการเลื่อน
                              itemCount: TH_ListAssets.length,
                              itemBuilder: (context, index) {
                                var item = TH_ListAssets[index];
                                print((item['percentProfit'].runtimeType));
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 6),
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
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
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        Text(
                                          item['symbol'],
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 2, horizontal: 10),
                                          child: Row(
                                            children: [
                                              Text(hideBalance
                                                    ? "****"
                                                    : 
                                                "${NumberFormat('#,###.#', 'en_US').format(item['profit'])}\u0E3F",
                                                style: TextStyle(
                                                    color: NumberFormat(
                                                                '#,###.##',
                                                                'en_US')
                                                            .format(
                                                                item['profit'])
                                                            .startsWith('-')
                                                        ? Color(0xFFFF002E)
                                                        : Color(0xFF0AFF96),
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                "(${NumberFormat('#,###.##', 'en_US').format(item['percentProfit'])}%)",
                                                style: TextStyle(
                                                    color: NumberFormat(
                                                                '#,###.##',
                                                                'en_US')
                                                            .format(item[
                                                                'percentProfit'])
                                                            .startsWith('-')
                                                        ? Color(0xFFFF002E)
                                                        : Color(0xFF0AFF96),
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          'ราคาเฉลี่ยต่อหน่วย: ${item['averagePrice']}',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Text(hideBalance
                                                    ? "****"
                                                    : 
                                          'มูลค่าทั้งหมด: ${NumberFormat('#,###.#', 'en_US').format(item['amount'])} บาท',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    trailing: Text(hideBalance
                                                    ? "****"
                                                    : 
                                      'จำนวน: ${NumberFormat('#,###.#', 'en_US').format(item['actualVolume'])} หน่วย',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "ทรัพย์สินหุ้นอเมริกา (US Stock Assets)",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 16, right: 6),
                          width: MediaQuery.of(context).size.width * 0.5,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              CircularPercentIndicator(
                                radius: 50,
                                lineWidth: 30.0,
                                backgroundColor: Color(0xFF068DA9),
                                animation: true,
                                animationDuration: 1000,
                                percent: US_totalChart,
                                progressColor: Colors.red,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      "${(100 - US_totalChart * 100).toStringAsFixed(1)}%"),
                                  Text("ต่อ"),
                                  Text(
                                      "${(US_totalChart * 100).toStringAsFixed(1)}%"),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
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
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: Color(0xFF068DA9),
                                          size: 16,
                                        ),
                                        SizedBox(
                                          width: 12,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "เงินสดอเมริกา",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14),
                                            ),
                                            Text(hideBalance
                                                    ? "****"
                                                    : 
                                              NumberFormat('#,###.##', 'en_US')
                                                  .format(US_Fiat),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
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
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: Colors.red,
                                          size: 16,
                                        ),
                                        SizedBox(
                                          width: 12,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "หุ้นอเมริกา",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14),
                                            ),
                                            Text(hideBalance
                                                    ? "****"
                                                    : 
                                              NumberFormat('#,###.#', 'en_US')
                                                  .format(US_marketValue),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ],
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
                                      USTreemapState(username: username)),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(14),
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 6),
                            decoration: BoxDecoration(
                                color: Colors.red.shade900,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "ดู Treemap หุ้นอเมริกา",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16),
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
                          height: 4,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(vertical: 12),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics:
                                NeverScrollableScrollPhysics(), // ปิดการเลื่อน
                            itemCount: positions.length,
                            itemBuilder: (context, index) {
                              var position = positions[index];

                              return Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 6),
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Color(0xFF2A3547),
                                  borderRadius: BorderRadius.circular(20),
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
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Text(
                                        position['symbol'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 2, horizontal: 10),
                                        child: Row(
                                          children: [
                                            position['unrealized_pl']
                                                    .toString()
                                                    .startsWith('-')
                                                ? Text(
                                                  hideBalance
                                                    ? "****"
                                                    : 
                                                    "\u0024${NumberFormat('#,###.#', 'en_US').format(double.parse(position['unrealized_pl']))}",
                                                    style: TextStyle(
                                                        color: position[
                                                                    'unrealized_pl']
                                                                .toString()
                                                                .startsWith('-')
                                                            ? Color(0xFFFF002E)
                                                            : Color(0xFF0AFF96),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  )
                                                : Text(
                                                  hideBalance
                                                    ? "****"
                                                    : 
                                                    "\u0024+${NumberFormat('#,###.#', 'en_US').format(double.parse(position['unrealized_pl']))}",
                                                    style: TextStyle(
                                                        color: position[
                                                                    'unrealized_pl']
                                                                .toString()
                                                                .startsWith('-')
                                                            ? Color(0xFFFF002E)
                                                            : Color(0xFF0AFF96),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  ),
                                            SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              
                                              "(${NumberFormat('#,###.##', 'en_US').format(double.parse(position['unrealized_plpc']))}%)",
                                              style: TextStyle(
                                                  color: position[
                                                              'unrealized_plpc']
                                                          .toString()
                                                          .startsWith('-')
                                                      ? Color(0xFFFF002E)
                                                      : Color(0xFF0AFF96),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Text(
                                        'ราคาเฉลี่ยต่อหน่วย: ${NumberFormat('#,###.#', 'en_US').format(double.parse(position['avg_entry_price']))}',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.white),
                                      ),
                                      Text(
                                        hideBalance
                                                    ? "****"
                                                    : 
                                        'มูลค่าทั้งหมด: ${NumberFormat('#,###.#', 'en_US').format(double.parse(position['market_value']))}',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    hideBalance
                                                    ? "****"
                                                    : 
                                    'จำนวน: ${NumberFormat('#,###.###', 'en_US').format(double.parse(position['quantity']))} หน่วย',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white),
                                  ),
                                ),
                              );
                            },
                          ),
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
    );
  }
}

class PositData {
  final String symbol;
  final double marketValue;
  final double costBasis;

  final double unrealized_pl;
  final double unrealized_plpc;

  PositData(this.symbol, this.marketValue, this.costBasis, this.unrealized_pl,
      this.unrealized_plpc);
}
