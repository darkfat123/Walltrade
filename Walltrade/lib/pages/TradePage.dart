import 'package:Walltrade/pages/SettingsPage.dart';
import 'package:flutter/material.dart';
import 'notify_and_activity.dart';

class TradePage extends StatefulWidget {
  final String username;
  TradePage({required this.username});
  @override
  _TradePageState createState() => _TradePageState(username: username);
}

class _TradePageState extends State<TradePage> {
  final String username;
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  _TradePageState({required this.username});
  void _handleSubmit() {
    setState(() {
      searchText = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    String username = widget.username;
    return SafeArea(
        child: Scaffold(
      backgroundColor: Color(0xFFECF8F9),
      body: ListView.builder(
        itemCount:
            30, // Replace '10' with the desired number of items in the list
        itemBuilder: (context, index) {
          return Container(
            child: ListTile(
              title: Text('test title $index'),
              subtitle: Text('test subtitle $index'),
            ),
          );
        },
      ),
    ));
  }
}
