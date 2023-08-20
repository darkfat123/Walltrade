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
  _ThaiTreemapState({required this.username});
  @override
  void initState() {
    super.initState();
    getBalance();
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
        backgroundColor: Color(0xFF212436),
        title: Text('Treemap Chart หุ้นไทย'),
      ),
      body: TH_ListAssets.isEmpty // Check if positions list is empty
          ? Center(
              child:
                  CircularProgressIndicator(), // Show CircularProgressIndicator if data is loading
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
                    // Function to calculate font size based on weight value
                    double getFontSize(double weight) {
                      if (weight < 50) return 6;
                      if (weight < 100) return 12;
                      if (weight < 1000) return 14;
                      return 18;
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
                          '''Symbol: ${tile.group}\nมูลค่าปัจจุบัน : ${tile.weight} USD''',
                          style: const TextStyle(color: Colors.black)),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
