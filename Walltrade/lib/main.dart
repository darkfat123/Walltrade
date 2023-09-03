import 'package:Walltrade/pages/MoreTechnicalOrder.dart';
import 'package:Walltrade/pages/TradePageOptions.dart';
import 'package:Walltrade/pages/login_page.dart';
import 'package:Walltrade/pages/HistoryAutoTrade.dart';
import 'package:Walltrade/pages/thStockView.dart';
import 'package:Walltrade/primary.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'pages/HomePage.dart';
import 'pages/PortfolioDetail.dart';
import 'pages/PredictPage.dart';

import 'package:Walltrade/pages/SearchPage.dart';
import 'pages/WalletPage.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walltrade',
      theme: ThemeData(
        primarySwatch: primary,
        fontFamily: "IBMPlexSansThai",
      ),
      home: Home(username: "foczz123",initialIndex:4),
    );
  }
}

class Home extends StatefulWidget {
  final String username;
  final int initialIndex;
  Home({required this.username, required this.initialIndex});

  @override
  HomeState createState() => HomeState(username: username, initialIndex: initialIndex);
}

class HomeState extends State<Home> {
  int index = 0;
  final String username;
  HomeState({required this.username, required int initialIndex}) {
    index = initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF212436),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        backgroundColor: Color(0xFF212436),
        type: BottomNavigationBarType.fixed, // Set the type to fixed
        items: [
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.home,
              size: 20,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.search,
              size: 20,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.autorenew,
              size: 25,
            ),
            label: 'Trade',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.query_stats_rounded,
              size: 25,
            ),
            label: 'Predict',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.wallet,
              size: 20,
            ),
            label: 'Wallet',
          ),
        ],
        selectedItemColor: Colors.white, // Color of the selected label
        unselectedItemColor: Colors.grey,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: getSelectedWidget(index: index),
      ),
    );
  }

  Widget getSelectedWidget({required int index}) {
    Widget widget;
    switch (index) {
      case 0:
        widget = HomePage(username: username);
        break;
      case 1:
        widget = SearchPage(username: username);
        break;
      case 2:
        widget = TradePageOptions(username: username);
        break;
      case 3:
        widget = PredictPage();
        break;
      case 4:
        widget = WalletPage(username: username);
        break;
      default:
        widget = HomePage(username: username);
        break;
    }
    return widget;
  }
}
