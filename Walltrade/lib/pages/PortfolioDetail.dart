import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  bool hideBalance = false;
  void toggleBalanceVisibility() {
    setState(() {
      hideBalance = !hideBalance;
    });
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
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.all(8),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(14),
                  padding: EdgeInsets.all(20),
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Color(0xFF2A3547),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset:
                            Offset(0, 3), // changes the position of the shadow
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "ยอดเงินคงเหลือ",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
                          InkWell(
                            onTap: toggleBalanceVisibility,
                            child: Icon(
                              hideBalance
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "กำไร/ขาดทุนสุทธิวันนี้: ",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            hideBalance ? "**** USD (****)" : "10 USD (5%)",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
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
