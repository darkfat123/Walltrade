import 'package:Walltrade/pages/guidePage/alpacaRegisterGuide.dart';
import 'package:Walltrade/pages/FirebaseAuth/auth.dart';
import 'package:Walltrade/pages/FirebaseAuth/login_page.dart';


import 'package:Walltrade/pages/FirebaseAuth/register_page.dart';
import 'package:Walltrade/pages/MoreTechnicalOrder.dart';
import 'package:Walltrade/pages/TradePageOptions.dart';
import 'package:Walltrade/pages/HistoryAutoTrade.dart';


import 'package:Walltrade/pages/thStockView.dart';
import 'package:Walltrade/primary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'pages/guidePage/settradeRegisterGuide.dart';
import 'pages/HomePage.dart';
import 'pages/PortfolioDetail.dart';
import 'pages/PredictPage.dart';

import 'package:Walltrade/pages/SearchPage.dart';
import 'pages/WalletPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
    apiKey: 'AIzaSyD5Ntd5aan0rYJTrkM0STIMgLPZzXgCJmw',
    appId: '1:207848542192:android:68540f26183154fbb99735',
    messagingSenderId: '207848542192',
    projectId: 'walltrade-b174e',
  ));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final User? user;

  MyApp({Key? key})
      : user = Auth().currentUser,
        super(key: key) {
    // Initialize username in the constructor
    username = user?.displayName ?? "Guest";
  }

  String username = "Guest";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Walltrade',
      theme: ThemeData(
        primarySwatch: primary,
        fontFamily: "IBMPlexSansThai",
      ),
      home: FutureBuilder(
        future: Auth().authStateChanges.first, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // หรือเฉลยอื่นๆ ที่คุณต้องการในระหว่างรอ
          } else {
            if (snapshot.hasData) {
              return Home(username: username, initialIndex: 1);
            } else {
              return LoginPage();
            }
          }
        },
      ),
    );
  }
}

class Home extends StatefulWidget {
  final String username;
  final int initialIndex;
  const Home({super.key, required this.username, required this.initialIndex});

  @override
  HomeState createState() =>
      HomeState(username: username, initialIndex: initialIndex);
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
      backgroundColor: const Color(0xFF212436),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        backgroundColor: const Color(0xFF212436),
        type: BottomNavigationBarType.fixed, // Set the type to fixed
        items: const [
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
        widget = PredictPage(
          username: username,
        );
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
