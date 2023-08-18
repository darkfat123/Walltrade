import 'package:flutter/material.dart';

class PortfolioDetailPage extends StatefulWidget {
  final String username;
  PortfolioDetailPage({required this.username});
  @override
  _PortfolioDetailPageState createState() =>
      _PortfolioDetailPageState(username: username);
}

class _PortfolioDetailPageState extends State<PortfolioDetailPage>
    with SingleTickerProviderStateMixin {
  final String username;
  late TabController tabController;
  late PageController pageController; // เพิ่มตัวแปร PageController

  _PortfolioDetailPageState({required this.username});

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    pageController = PageController(); // สร้าง PageController
  }

  @override
  void dispose() {
    tabController.dispose();
    pageController.dispose(); // ปิด PageController เมื่อหน้าถูกทำลาย
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("พอร์ตการลงทุน"),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(16),
            height: 200,
            child: Column(
              children: [
                
                Expanded(
                  child: PageView(
                    controller: pageController, // ใช้ PageController
                    children: [
                      Container(
                        color: Colors.blue, // สีหน้า TH Wallet
                        child: Center(
                          child: Text(
                            'TH Wallet', // ข้อความหน้า TH Wallet
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.red, // สีหน้า US Wallet
                        child: Center(
                          child: Text(
                            'US Wallet', // ข้อความหน้า US Wallet
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

