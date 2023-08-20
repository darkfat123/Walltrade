import 'dart:convert';
import 'package:Walltrade/variables/serverURL.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';

class USTreemapState extends StatefulWidget {
  final String username;
  USTreemapState({required this.username});
  @override
  _USTreemapState createState() => _USTreemapState(username:username);
}


class _USTreemapState extends State<USTreemapState> {
  List<PositData> _positDataList = [];
  List<dynamic> positions = [];
  final String username;
   _USTreemapState({required this.username});
  

  @override
  void initState() {
    super.initState();
    fetchPositionData();
  }

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
        double costBasis = double.parse(position['cost_basis']);

        // เพิ่มข้อมูล PositData เข้าไปใน List ที่สร้างไว้
        _positDataList.add(PositData(
          position['symbol'],
          marketValue,
          costBasis,
        ));
      }
      print(_positDataList);
    } else {
      print('Failed to fetch position data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF212436),
        title: Text('Treemap Chart'),
      ),
      body: positions.isEmpty // Check if positions list is empty
          ? Center(
              child:
                  CircularProgressIndicator(), // Show CircularProgressIndicator if data is loading
            )
          : SfTreemap(
              dataCount: _positDataList.length,
              colorMappers: [
                TreemapColorMapper.range(
                  from: 0,
                  to: 100,
                  color: Colors.yellow,
                ),
                TreemapColorMapper.range(
                  from: 100,
                  to: 250,
                  color: Colors.amber,
                ),
                TreemapColorMapper.range(
                  from: 250,
                  to: 350,
                  color: Colors.orange.shade800,
                ),
                TreemapColorMapper.range(
                  from: 350,
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
                      if (weight < 50) return 4;
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

class TreemapData {
  final String country;
  final double usersInMillions;

  TreemapData(this.country, this.usersInMillions);
}

class PositData {
  final String symbol;
  final double marketValue;
  final double costBasis;

  PositData(this.symbol, this.marketValue, this.costBasis);
}
