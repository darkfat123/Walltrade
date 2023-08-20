import 'dart:convert';
import 'package:Walltrade/pages/ThaiTreemap.dart';
import 'package:http/http.dart' as http;
import 'package:Walltrade/variables/serverURL.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:percent_indicator/percent_indicator.dart';

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
  double TH_marketValue = 0;
  double US_marketValue = 0;
  double TH_chartMarketValue = 0;
  double US_chartMarketValue = 0;
  double totalFiat = 0;
  double TH_ProfitChange = 0;
  double TH_percentageChange = 0;
  double totalbalance = 0;
  double US_cash = 0;
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
      print(TH_ListAssets);
    }

    print(TH_marketValue);
    TH_chartMarketValue = (TH_marketValue / TH_balance) * 100;
    US_chartMarketValue = (US_marketValue / US_cash) * 100;
    totalFiat = US_cash / TH_balance;
    totalBalance = _walletBalance + TH_balance;
    print(TH_Fiat);

    print(US_cash);
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
                          "${NumberFormat('#,###.##', 'en_US').format(TH_balance)} USD ",
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
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.green)),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            "ทรัพย์สินหุ้นไทย (TH Stock Assets)",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        Center(
                          child: Container(
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
                                  radius: 60,
                                  lineWidth: 30.0,
                                  backgroundColor: Color(0xFF068DA9),
                                  animation: true,
                                  animationDuration: 1000,
                                  percent: TH_totalChart,
                                  progressColor: Colors.red,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: Colors.blue,
                                      size: 16,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "เงินสดไทย",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14),
                                        ),
                                        Text(
                                          NumberFormat('#,###.##', 'en_US')
                                              .format(TH_Fiat),
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.circle,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "หุ้นไทย",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14),
                                        ),
                                        Text(
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
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ThaiTreemapState(username:username)),
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
                          height: TH_ListAssets.length * 100,
                          child: ListView.builder(
                            itemCount: TH_ListAssets.length,
                            itemBuilder: (context, index) {
                              var item = TH_ListAssets[index];
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
                                            Text(
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
                                                  fontWeight: FontWeight.w700),
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
                                        'ราคาเฉลี่ยต่อหน่วย: ${item['averagePrice']}',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        'มูลค่าทั้งหมด: ${NumberFormat('#,###.#', 'en_US').format(item['amount'])} บาท',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
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
                  Text("เงินสดไทย ${TH_Fiat.toStringAsFixed(2)}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
