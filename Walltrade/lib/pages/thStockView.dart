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
  _AssetTHListScreenState({required this.username});
  Future<List<String>> fetchAssetList() async {
    final response =
        await http.get(Uri.parse('${Constants.serverUrl}/asset_list2'));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      final assetList = List<String>.from(jsonBody['assets']);
      return assetList;
    } else {
      throw Exception('Failed to fetch asset list');
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
  List<String> assetList = [];
  List<String> filteredList = [];

  void filterAssets(String searchQuery) {
    if (searchQuery.isNotEmpty) {
      setState(() {
        filteredList = assetList.where((asset) {
          final String symbol = asset.toLowerCase();
          return symbol.contains(searchQuery.toLowerCase());
        }).toList();
      });
    } else {
      setState(() {
        filteredList = List.from(assetList);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAssetList().then((list) {
      setState(() {
        assetList = list;
        filteredList = List.from(assetList);
      });
    });
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
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                labelText: 'พิมพ์อักษรย่อของหุ้น...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onChanged: (value) {
                filterAssets(value);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final asset = filteredList[index];
                return ListTile(
                  title: Text(asset),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AssetTHDetailsScreen(symbol: asset),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: FaIcon(
                      FontAwesomeIcons.plus,
                      size: 18,
                    ),
                    onPressed: () {
                      updateWatchlist(asset.toString());
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


