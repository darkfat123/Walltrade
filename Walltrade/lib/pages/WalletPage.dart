import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../variables/serverURL.dart';
import 'SettingsPage.dart';
import 'notify_and_activity.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';
import 'Treemap.dart';

class WalletPage extends StatefulWidget {
  final String username;
  WalletPage({required this.username});
  @override
  _WalletPageState createState() => _WalletPageState(username: username);
}

class _WalletPageState extends State<WalletPage> {
  final String username;
  String _walletBalance = '';
  String _balanceChange = '';
  String _percentageChange = '';
  double checkBalanceChange = 0;
  bool isTHStocksSelected = true;
  bool isUSStocksSelected = false;
  bool isWatchlistVisible = true;
  List<dynamic> positions = [];
  List<PositData> _positDataList = [];
  _WalletPageState({required this.username});

  bool hideBalance = false;

  void toggleBalanceVisibility() {
    setState(() {
      hideBalance = !hideBalance;
    });
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
    } else {
      print('Failed to fetch position data');
    }
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
        setState(
          () {
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
          checkBalanceChange = double.parse(_balanceChange);
        });
      } else {
        throw Exception(
            'Failed to retrieve balance change. Error: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getBalance();
    getBalanceChange();
    fetchPositionData();
  }

  void selectTHStocks() {
    setState(() {
      isTHStocksSelected = true;
      isUSStocksSelected = false;
    });
  }

  void selectUSStocks() {
    setState(() {
      isTHStocksSelected = false;
      isUSStocksSelected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          "Wallet",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w600),
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
                height: 150,
                decoration: BoxDecoration(
                  color: Color(0xFF2A3547),
                  borderRadius: BorderRadius.circular(15),
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
                    Text(
                      hideBalance ? "**** USD" : "$_walletBalance USD",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
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
                          _balanceChange.toString().startsWith("-")  ? " " : "+",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: _balanceChange.toString().startsWith("-")
                                ? Colors.red
                                : Color(0xFF13B709),
                          ),
                        ),
                        Text(
                          hideBalance
                              ? "**** USD (****)"
                              : "$_balanceChange USD ($_percentageChange%)",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: _balanceChange.toString().startsWith("-")
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
                    MaterialPageRoute(builder: (context) => TreemapState()),
                  );
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                  margin: EdgeInsets.all(14),
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
                  borderRadius: BorderRadius.circular(20),
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
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: positions.isEmpty // Check if positions list is empty
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ), // Show CircularProgressIndicator if data is loading
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
                              labelBuilder:
                                  (BuildContext context, TreemapTile tile) {
                                // Function to calculate font size based on weight value
                                double getFontSize(double weight) {
                                  if (weight < 50) return 4;
                                  if (weight < 500) return 10;
                                  if (weight < 1000) return 12;
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
                                            color: Colors.black,
                                            fontSize: fontSize),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        '${tile.weight}',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: fontSize),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              tooltipBuilder:
                                  (BuildContext context, TreemapTile tile) {
                                return Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                      '''Symbol: ${tile.group}\nมูลค่าปัจจุบัน : ${tile.weight} USD''',
                                      style:
                                          const TextStyle(color: Colors.black)),
                                );
                              },
                            ),
                          ],
                        ),
                ),
              ),
              Text(
                "สินทรัพย์ที่มีอยู่",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Container(
                margin: EdgeInsets.all(14),
                padding: EdgeInsets.all(20),
                width: double.infinity,
                height: positions.length *
                    103.5, // ความสูงขึ้นอยู่กับจำนวนรายการใน ListView
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
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
                child: ListView.builder(
                  itemCount: positions.length,
                  itemBuilder: (BuildContext context, int index) {
                    final position = positions[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Color(0xFFECF8F9),
                      ),
                      child: ListTile(
                        title: Text(
                          position['symbol'],
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('มูลค่าปัจจุบัน: ${position['market_value']}'),
                            Text('ต้นทุน: ${position['cost_basis']}'),
                          ],
                        ),
                        trailing:
                            Text('จำนวนหุ้น: ${position['quantity']} หน่วย'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PositData {
  final String symbol;
  final double marketValue;
  final double costBasis;

  PositData(this.symbol, this.marketValue, this.costBasis);
}
