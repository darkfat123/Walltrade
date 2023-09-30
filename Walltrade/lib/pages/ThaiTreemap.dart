import 'dart:convert';
import 'package:Walltrade/variables/serverURL.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';

class ThaiTreemapState extends StatefulWidget {
  final String username;
  ThaiTreemapState({required this.username});
  @override
  _ThaiTreemapState createState() => _ThaiTreemapState(username: username);
}

class _ThaiTreemapState extends State<ThaiTreemapState> {
  final String username;
  List<dynamic> positions = [];
  bool isLoading = true;

  _ThaiTreemapState({required this.username});
  @override
  void initState() {
    super.initState();
    getBalance();
  }

  List<dynamic> others_List = [];
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

  // Function to preprocess data and group items with "amount" < 100000 into "Others"
  List<dynamic> othersData(List<dynamic> TH_assetData) {
    List<dynamic> othersData = [];
    double totalAmount = 0;
    double totalTH_assetDataAmount = 0;
    for (var item in TH_assetData) {
      double amount = item['amount'];
      totalTH_assetDataAmount += amount;
    }

    for (var item in TH_assetData) {
      double amount = item['amount'];
      if (amount >= totalTH_assetDataAmount*0.02) {
        othersData.add(item);
      } else {
        totalAmount += amount;
      }
    }

    if (totalAmount > 0) {
      othersData.add({
        'symbol': 'Others',
        'amount': totalAmount,
      });
    }

    return othersData;
  }

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
              .toStringAsFixed(2)); // Convert String to double
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

      var portfolioList = data2['portfolioList'];
      setState(() {
        TH_ListAssets = othersData(portfolioList); // Preprocess data
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF212436),
        title: Text('Treemap Chart หุ้นไทย'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : TH_ListAssets.isEmpty
              ? Center(
                  child: Text(
                    "ไม่มีหุ้นไทย โปรดซื้อหุ้นเพื่อแสดงผล",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : SfTreemap(
                  dataCount: TH_ListAssets.length,
                  colorMappers: [
                    TreemapColorMapper.range(
                      from: 0,
                      to: 10000,
                      color: Colors.yellow,
                    ),
                    TreemapColorMapper.range(
                      from: 10000,
                      to: 50000,
                      color: Colors.amber,
                    ),
                    TreemapColorMapper.range(
                      from: 50000,
                      to: 100000,
                      color: Colors.orange.shade800,
                    ),
                    TreemapColorMapper.range(
                      from: 100000,
                      to: double.infinity,
                      color: Colors.red,
                    ),
                  ],
                  weightValueMapper: (int index) {
                    return TH_ListAssets[index]['amount'];
                  },
                  levels: <TreemapLevel>[
                    TreemapLevel(
                      groupMapper: (int index) {
                        return TH_ListAssets[index]['symbol'];
                      },
                      labelBuilder: (BuildContext context, TreemapTile tile) {
                        double getFontSize(double weight) {
                          if (weight < 10000) return 12;
                          if (weight < 100000) return 16;
                          if (weight < 10000000) return 20;
                          return 24;
                        }

                        double fontSize = getFontSize(tile.weight);

                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                tile.group,
                                style: TextStyle(
                                    color: Colors.black, fontSize: fontSize),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '${tile.weight}',
                                style: TextStyle(
                                    color: Colors.black, fontSize: fontSize),
                              ),
                            ],
                          ),
                        );
                      },
                      tooltipBuilder: (BuildContext context, TreemapTile tile) {
                        return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                              '''Symbol: ${tile.group}\nมูลค่า : ${tile.weight} บาท''',
                              style: const TextStyle(color: Colors.black)),
                        );
                      },
                    ),
                  ],
                ),
    );
  }
}
