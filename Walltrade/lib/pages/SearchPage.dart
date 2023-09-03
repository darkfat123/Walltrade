import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Walltrade/pages/thStockView.dart';
import 'package:Walltrade/pages/usStockView.dart';
import 'package:Walltrade/primary.dart';
import 'package:flutter/material.dart';

import '../variables/serverURL.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, required this.username}) : super(key: key);
  final String username;
  @override
  _SearchPageState createState() => _SearchPageState(username: username);
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  final String username;
  _SearchPageState({required this.username});

  List<dynamic> symbolsWatchlist =[];

  Future<void> watchlist() async {
    var url = '${Constants.serverUrl}/displayWatchlist';
    var body = jsonEncode({'username': username});

    var response = await http.post(Uri.parse(url),
        body: body, headers: {'Content-Type': 'application/json'});
    var data = jsonDecode(response.body);
    symbolsWatchlist = data;
    
  }

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
    watchlist();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(left: 10, right: 10),
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                SizedBox(height: 10),
                Container(
                  // height: 50,
                  width: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      color: primary, borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: TabBar(
                          unselectedLabelColor: Colors.white,
                          labelColor: Colors.black,
                          indicatorColor: Colors.white,
                          indicatorWeight: 2,
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          controller: tabController,
                          tabs: [
                            Tab(
                              text: 'TH Stocks',
                            ),
                            Tab(
                              text: 'US Stocks',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      AssetTHListScreen(
                        username: username
                      ),
                      AssetListScreen(
                        username: username,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
