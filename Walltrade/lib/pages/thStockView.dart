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
  List<String> assetList = [];
  List<dynamic> filteredList = [];
  bool isLoading = false;
  _AssetTHListScreenState({required this.username});

  Future<void> fetchAssetList() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response =
          await http.get(Uri.parse('${Constants.serverUrl}/asset_list2'));
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        List<String> fetchedAssetList = List<String>.from(jsonBody);
        setState(() {
          assetList = fetchedAssetList;
          isLoading = false;
        });
      } else {
        isLoading = false;
        throw Exception('Failed to fetch asset list');
      }
    } catch (e) {
      isLoading = false;
      print("Error fetching asset list: $e");
    }
  }

  void searchAssets(String query) {
    setState(() {
      filteredList = assetList
          .where((asset) => asset.toLowerCase().contains(query.toLowerCase()))
          .toList();
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
              onChanged:
                  searchAssets, // Call the searchAssets method on text change
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
                    itemCount: filteredList.isNotEmpty
                        ? filteredList.length // Use filteredList if not empty
                        : assetList.length, // Otherwise, use assetList
                    itemBuilder: (context, index) {
                      final asset = filteredList.isNotEmpty
                          ? filteredList[index] // Use filteredList if not empty
                          : assetList[index]; // Otherwise, use assetList
                      return ListTile(
                        title: Text(
                          asset,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
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
