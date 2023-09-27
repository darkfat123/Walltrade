import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FAQ Page',
      home: FAQPage(),
    );
  }
}

class FAQPage extends StatefulWidget {
  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  // สร้างรายการคำถามและคำตอบเป็น List ของ Map
  List<Map<String, dynamic>> faqData = [
    {
      'question': 'ตลาดหุ้นไทยจะสั่งซื้อขายแบบ Limit และ Market ได้เวลาใด',
      'answer':
          'ตลาดหุ้นไทยจะสั่งซื้อขายแบบ Limt ได้ตลอดเวลา ส่วนตลาดหุ้นไทยจะสั่งซื้อขายแบบ Market ได้เมื่อสถานะของตลาดหุ้นไทยกำลังเปิดซื้อขายอยู่เท่านั้น',
    },
    {
      'question': 'ตลาดหุ้นอเมริกาจะสั่งซื้อขายแบบ Limit และ Market ได้เวลาใด',
      'answer':
          'ตลาดหุ้นอเมริกาสามารถใช้ทั้ง 2 คำสั่งได้ตลอดเวลา',
    },
    {
      'question': 'การสร้างเงื่อนไขเพื่อให้เทรดอัตโนมัติใช้คำสั่งแบบใด',
      'answer': 'Market Order',
    },
    {
      'question': 'ต้องการอัพเดท API Key และ Secret Key ต้องทำอย่างไร',
      'answer':
          'ไปที่ตั้งค่ามุมขวาบนของหน้า Home หรือหน้าใดก็ได้ที่มีรูปฟันเฟือง',
    },
    {
      'question': 'รู้ได้อย่างไรว่า เงื่อนไขเทรดอัตโนมัติได้สั่งซื้อหรือขายเรียบร้อยแล้ว',
      'answer':
          'ไปที่หน้า Trade หรือคำสั่งเทรดอัตโนมัติ และจะมีเมนูคำว่า "คำสั่งที่รอการดำเนินการ" กดที่เพิ่มเติม และไปทำแทบ "สำเร็จแล้ว"',
    },
    {
      'question': 'โมเดลการทำนายหุ้นใช้สำหรับทำนายอนาคตกี่วัน',
      'answer':
          'วันถัดไปจากที่ทำนายเท่านั้น',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('คำถามที่พบบ่อย'),
      ),
      body: ListView.builder(
        itemCount: faqData.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes the position of the shadow
                ),
              ],
            ),
            child: ExpansionTile(
              title: Text("ถาม: ${faqData[index]['question']}",style: TextStyle(fontSize: 18),),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("ตอบ: ${faqData[index]['answer']}",style: TextStyle(fontSize: 16),),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
