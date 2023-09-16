import 'dart:convert';
import 'package:Walltrade/pages/thAssetDetail.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../variables/serverURL.dart';

class AssetTHListScreen extends StatefulWidget {
  final String username;
  AssetTHListScreen({required this.username});
  @override
  _AssetTHListScreenState createState() =>
      _AssetTHListScreenState(username: username);
}

class _AssetTHListScreenState extends State<AssetTHListScreen>
    with AutomaticKeepAliveClientMixin {
  final String username;
  List<dynamic> assetList = [];
  List<dynamic> filteredList = [];
  List<dynamic> data = [];
  bool isLoading = false;
  IconData icon = FontAwesomeIcons.solidHeart;

  _AssetTHListScreenState({required this.username});

  Future<void> fetchAssetList() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await http.get(Uri.parse('${Constants.serverUrl}/thStockList'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonBody = json.decode(response.body);
        setState(() {
          assetList = List<Map<String, dynamic>>.from(jsonBody);
          filteredList = assetList;
          isLoading = false;
        });
        print(assetList);
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to fetch asset list');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching asset list: $e");
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

  Future<void> watchlist() async {
    var url = '${Constants.serverUrl}/displayWatchlist';
    var body = jsonEncode({'username': username});

    var response = await http.post(Uri.parse(url),
        body: body, headers: {'Content-Type': 'application/json'});
    data = jsonDecode(response.body);
    print(data);
  }

  void filterAssets(String searchQuery) {
    List<dynamic> tempList = [];
    tempList.addAll(assetList);
    if (searchQuery.isNotEmpty) {
      tempList = tempList.where((asset) {
        final String symbol = asset['Symbol'].toString().toLowerCase();
        return symbol.contains(searchQuery.toLowerCase());
      }).toList();
    }
    setState(() {
      filteredList = tempList;
    });
  }

  Future<void> updateWatchlist(String stockName) async {
    final url = '${Constants.serverUrl}/update_watchlist';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'name': stockName,
        'username': username, // เปลี่ยนเป็นชื่อผู้ใช้ของคุณที่นี่
      },
    );
    if (response.statusCode == 200) {
      print('Watchlist updated successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'เพิ่มลงรายการเรียบร้อยแล้ว!',
            style: TextStyle(fontSize: 16),
          ),
          // กำหนดให้ความกว้างเต็มพื้นที่ของจอแสดงผล
          backgroundColor: Colors.green, // ทำให้ Snackbar ลอยเหนือเนื้อหา
        ),
      );
    } else {
      print('Failed to update watchlist');
    }
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredList = assetList;
    fetchAssetList();
    watchlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                // Call the filterAssets method on text change
                filterAssets(value);
              },
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                labelText: 'พิมพ์อักษรย่อของหุ้น...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredList.length == 0
                    ? Center(
                        child: Text("ไม่พบรายการหุ้น"),
                      )
                    : ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final asset = filteredList[index];
                          final symbol = asset['Symbol'];
                          final fullname = asset['Fullname'];
                          final isSymbolInData = data.contains(
                              symbol); // เช็คว่า symbol อยู่ในรายการ data หรือไม่
                          return Column(
                            children: [
                              ListTile(
                                title: Text(
                                  symbol,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(
                                  fullname,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AssetTHDetailsScreen(symbol: symbol,fullname: fullname),
                                    ),
                                  );
                                },
                                trailing: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: isSymbolInData
                                      ? IconButton(
                                          icon: FaIcon(icon,
                                              size: 16, color: Colors.red),
                                          onPressed: () {
                                            deleteWatchlist(symbol);
                                            setState(() {
                                              data.remove(
                                                  symbol); // ลบ symbol ออกจาก data
                                            });
                                            print(data);
                                          },
                                        )
                                      : IconButton(
                                          icon: FaIcon(FontAwesomeIcons.heart,
                                              size: 16,
                                              color: Colors
                                                  .red), // ใช้ icon ที่กำหนดไว้
                                          onPressed: () {
                                            updateWatchlist(symbol);
                                            setState(() {
                                              data.add(
                                                  symbol); // เพิ่ม symbol เข้าไปใน data
                                            });
                                            print(data);
                                          },
                                        ),
                                ),
                              ),
                              Divider(
                                indent: 10,
                                endIndent: 10,
                              )
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
