import 'package:Walltrade/pages/usAssetDetail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../variables/serverURL.dart';

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
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Container(
              padding: EdgeInsets.all(16),
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'เพิ่มลงรายการเรียบร้อยแล้ว!',
                style: TextStyle(fontSize: 18),
              ),),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      );
    } else {
      print('Failed to update watchlist');
    }
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
    return Scaffold(
      backgroundColor: Color(0xFFECF8F9),
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
                    child: CircularProgressIndicator()
                  )
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final asset = filteredList[index];
                      return ListTile(
                        title: Text(
                          asset['Symbol'],
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(asset['Name']),
                        onTap: () {
                          navigateToAssetDetails(
                              asset['Name'], asset['Symbol'], username);
                        },
                        trailing: IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.plus,
                            size: 18,
                          ),
                          onPressed: () {
                            updateWatchlist(asset['Symbol'].toString());
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
