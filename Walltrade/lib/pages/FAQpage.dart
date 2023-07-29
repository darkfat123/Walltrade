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
      'question': 'คำถาม 1',
      'answer': 'คำตอบของคำถาม 1',
    },
    {
      'question': 'คำถาม 2',
      'answer': 'คำตอบของคำถาม 2',
    },
    {
      'question': 'คำถาม 3',
      'answer': 'คำตอบของคำถาม 3',
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
          return ExpansionTile(
            title: Text(faqData[index]['question']),
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(faqData[index]['answer']),
              ),
            ],
          );
        },
      ),
    );
  }
}
