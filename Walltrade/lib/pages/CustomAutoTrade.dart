import 'package:flutter/material.dart';

class CustomAutoTrade extends StatefulWidget {
  @override
  _CustomAutoTradeState createState() => _CustomAutoTradeState();
}

class _CustomAutoTradeState extends State<CustomAutoTrade> {
  // สร้างรายการคำถามและคำตอบเป็น List ของ Map

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('สร้างคำสั่งเทรดแบบหลายรายการ'),
        ),
        body: Center(
          child: Text("หน้าสร้างคำสั่งเทรด"),
        ));
  }
}
