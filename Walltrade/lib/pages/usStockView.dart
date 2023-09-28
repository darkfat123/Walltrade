import 'package:Walltrade/pages/usAssetDetail.dart';
import 'package:Walltrade/widget/snackBar/DeleteWatchlistSuccess.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../variables/serverURL.dart';
import '../widget/snackBar/UpdateWatchlistSuccess.dart';

class AssetListScreen extends StatefulWidget {
  final String username;
  AssetListScreen({required this.username});
  @override
  _AssetListScreenState createState() =>
      _AssetListScreenState(username: username);
}

class _AssetListScreenState extends State<AssetListScreen>
    with AutomaticKeepAliveClientMixin {
  List<dynamic> assetList = [];
  List<dynamic> filteredList = [];
  bool isLoading = false;
  final String username;
  List<dynamic> data = [];
  _AssetListScreenState({required this.username});

  final TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (assetList.isEmpty) {
      fetchData();
    }
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
        UpdateWatchlistSnackBar(symbol: stockName),
      );
    } else {
      print('Failed to update watchlist');
    }
  }

  @override
  void initState() {
    super.initState();
    watchlist();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    final response =
        await http.get(Uri.parse('${Constants.serverUrl}/asset_list'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        assetList = data['assets'];
        filteredList = assetList;
        isLoading = false;
      });
    } else {
      print('Request failed with status: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToAssetDetails(String name, String symbol, String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AssetDetailsScreen(name: name, symbol: symbol, username: username),
      ),
    );
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
      ScaffoldMessenger.of(context).showSnackBar(
        DeleteWatchlistSnackBar(symbol: symbol),
      );
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
        final String name = asset['Name'].toString().toLowerCase();
        return symbol.contains(searchQuery.toLowerCase()) ||
            name.contains(searchQuery.toLowerCase());
      }).toList();
    }
    setState(() {
      filteredList = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                fillColor: Colors.white, // Change the color here
                filled: true,
                labelText: 'พิมพ์ชื่อหุ้นหรืออักษรย่อ...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                filterAssets(value);
              },
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
                          final isSymbolInData = data.contains(asset['Symbol']);
                          return Column(
                            children: [
                              ListTile(
                                title: Text(
                                  asset['Symbol'],
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(asset['Name']),
                                onTap: () {
                                  navigateToAssetDetails(
                                      asset['Name'], asset['Symbol'], username);
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
                                        offset: Offset(0,
                                            3), // changes the position of the shadow
                                      ),
                                    ],
                                  ),
                                  child: isSymbolInData
                                      ? IconButton(
                                          icon: FaIcon(
                                              FontAwesomeIcons.solidHeart,
                                              size: 16,
                                              color: Colors.red),
                                          onPressed: () {
                                            deleteWatchlist(asset['Symbol']);
                                            setState(() {
                                              data.remove(asset[
                                                  'Symbol']); // ลบ symbol ออกจาก data
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
                                            updateWatchlist(asset['Symbol']);
                                            setState(() {
                                              data.add(asset[
                                                  'Symbol']); // เพิ่ม symbol เข้าไปใน data
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
