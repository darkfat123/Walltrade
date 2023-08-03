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

class _AssetTHListScreenState extends State<AssetTHListScreen> {
  final String username;
  List<dynamic> assetList = [];
  List<dynamic> filteredList = [];
  bool isLoading = false;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECF8F9),
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
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final asset = filteredList[index];
                      final symbol = asset['Symbol'];
                      return ListTile(
                        title: Text(
                          symbol,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AssetTHDetailsScreen(symbol: symbol),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.plus,
                            size: 18,
                          ),
                          onPressed: () {
                            updateWatchlist(symbol);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
