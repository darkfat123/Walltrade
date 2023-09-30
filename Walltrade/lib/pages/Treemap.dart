import 'dart:convert';
import 'package:Walltrade/variables/serverURL.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';

class TreemapState extends StatefulWidget {
  final String username;
  TreemapState({required this.username});
  @override
  _TreemapState createState() => _TreemapState(username: username);
}

class _TreemapState extends State<TreemapState> {
  List<PositData> _positDataList = [];
  List<dynamic> positions = [];
  final String username;
  _TreemapState({required this.username});

  @override
  void initState() {
    super.initState();
    fetchPositionData();
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

        double totalMarketValue = 0;
        List<String> otherSymbols = [];

        double totalMarketValue2 = 0;
        for (var data in positions) {
          final marketValue2 = double.parse(data['market_value']);
          totalMarketValue2 += marketValue2;
          print(marketValue2);
        }

        for (final position in positions) {
          final marketValue = double.parse(position['market_value']);
          if (marketValue < totalMarketValue2 * 0.02) {
            totalMarketValue += marketValue;
            otherSymbols.add(position['symbol']);
          } else {
            positDataList.add(PositData(
              position['symbol'],
              marketValue,
              "US",
            ));
          }
        }

        // Add "Others" if there are any entries
        if (otherSymbols.isNotEmpty) {
          positDataList.add(PositData(
            'Others',
            totalMarketValue,
            "US",
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
        });
      }
    } catch (error) {
      print('An error occurred: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF212436),
        title: Text('Treemap Chart'),
      ),
      body: _positDataList.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SfTreemap(
              dataCount: _positDataList.length,
              colorMappers: [
                TreemapColorMapper.range(
                  from: 0,
                  to: 50,
                  color: Colors.yellow.shade300,
                ),
                TreemapColorMapper.range(
                    from: 50, to: 200, color: Colors.yellow),
                TreemapColorMapper.range(
                  from: 200,
                  to: 500,
                  color: Colors.amber,
                ),
                TreemapColorMapper.range(
                  from: 500,
                  to: 1000,
                  color: Colors.orange,
                ),
                TreemapColorMapper.range(
                  from: 1000,
                  to: 10000,
                  color: Colors.orange.shade900,
                ),
                TreemapColorMapper.range(
                  from: 10000,
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
                    double getFontSize(double weight) {
                      if (weight < 50) return 2;
                      if (weight < 100) return 4;
                      if (weight < 500) return 8;
                      if (weight < 1000) return 12;
                      if (weight < 10000) return 14;
                      if (weight < 50000) return 16;
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
                            '${NumberFormat('#,###.#', 'en_US').format(tile.weight)}',
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
                          '''Symbol: ${tile.group}\nมูลค่าปัจจุบัน : ${NumberFormat('#,###.#', 'en_US').format(tile.weight)} USD''',
                          style: const TextStyle(color: Colors.black)),
                    );
                  },
                ),
              ],
            ),
    );
  }
}

class PositData {
  final String symbol;
  final double marketValue;
  final String region;

  PositData(this.symbol, this.marketValue, this.region);
}
