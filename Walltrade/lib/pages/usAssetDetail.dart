import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../variables/serverURL.dart';

class AssetDetailsScreen extends StatefulWidget {
  final String name;
  final String symbol;
  final String username;

  AssetDetailsScreen({
    required this.name,
    required this.symbol,
    required this.username,
  });
  @override
  _AssetDetailsScreenState createState() => _AssetDetailsScreenState();
}

class _AssetDetailsScreenState extends State<AssetDetailsScreen> {
  TextEditingController symbolController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  TextEditingController sideController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController timeInForceController = TextEditingController();
  String result = '';
  String marketStatus = '';
  Future<void> updateWatchlist(String stockName) async {
    final url = '${Constants.serverUrl}/update_watchlist';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'name': stockName,
        'username': widget.username, // เปลี่ยนเป็นชื่อผู้ใช้ของคุณที่นี่
      },
    );
    if (response.statusCode == 200) {
      print('Watchlist updated successfully');
    } else {
      print('Failed to update watchlist');
    }
  }

  void checkMarketStatus() async {
    var url = '${Constants.serverUrl}/checkMarketStatus';
    var response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        marketStatus = data;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> placeOrder(String symbol, String side) async {
    final url = Uri.parse('${Constants.serverUrl}/place_order');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(
      {
        'username': widget.username,
        'symbol': symbol,
        'qty': double.parse(qtyController.text),
        'side': side,
        'type': typeController.text,
      },
    );

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      setState(() {
        print(body);
        result = response.body;
      });
    } else {
      setState(() {
        result = 'เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkMarketStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECF8F9),
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.symbol,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.symbol,
                            style: TextStyle(
                                fontSize: 24,
                                fontFamily: "IBMPlexSansThai",
                                fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              updateWatchlist(widget.symbol);
                            },
                            child: Row(
                              children: [
                                Icon(Icons.add),
                                SizedBox(
                                    width: 3), // ช่องว่างระหว่างไอคอนและข้อความ
                                Text('เพิ่มลงในรายการเฝ้าดู'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "price",
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                      SizedBox(height: 10,),
                      Chip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              color: marketStatus == 'closed' ? Colors.red : Colors.green,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              marketStatus == 'closed'
                                  ? "สถานะตลาด: ปิด"
                                  : "สถานะตลาด: เปิด",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.blue.shade200,
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          color: Colors.white,
                          height: 580,
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      'ประเภท',
                                      style: TextStyle(
                                          fontFamily: "IBMPlexSansThai",
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0)),
                                            ),
                                            content: SizedBox(
                                              height: 210,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'Market Order: คำสั่งซื้อหรือขายที่ดำเนินการในราคาปัจจุบันที่มีอยู่บนตลาด โดยไม่ระบุราคาซื้อหรือขายเฉพาะ สั่งซื้อหรือขายในราคาที่พร้อมใช้งานในขณะนั้น'),

                                                  SizedBox(
                                                      height:
                                                          10), // เพิ่มระยะห่างระหว่างบรรทัด
                                                  Text(
                                                      'Limit Order: คำสั่งซื้อหรือขายที่ระบุราคาซื้อหรือขายที่ต้องการ เช่น ในกรณีของคำสั่งซื้อราคาที่ระบุจะต่ำกว่าราคาปัจจุบันของตลาด ในกรณีของคำสั่งขายราคาที่ระบุจะสูงกว่าราคาปัจจุบันของตลาด'),

                                                  // เพิ่มระยะห่างระหว่างบรรทัด
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                child: Text('ตกลง'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Icon(
                                      Icons.info_outline,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              TextField(
                                controller: typeController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  hintText: 'Limit หรือ Market',
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      'จำนวน',
                                      style: TextStyle(
                                          fontFamily: "IBMPlexSansThai",
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0)),
                                            ),
                                            content: const Text(
                                                'ต้องการซื้อขายเป็นจำนวนหุ้นหรือจำนวนเงิน'),
                                            actions: [
                                              ElevatedButton(
                                                child: Text('ตกลง'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Icon(
                                      Icons.info_outline,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              TextField(
                                controller: qtyController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  hintText: 'จำนวนหุ้นหรือจำนวนเงิน',
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      'ราคาลิมิต',
                                      style: TextStyle(
                                          fontFamily: "IBMPlexSansThai",
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0)),
                                            ),
                                            content: SizedBox(
                                              height: 110,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'Limit Order: กำหนดราคาที่ต้องการซื้อขาย'),

                                                  SizedBox(
                                                      height:
                                                          10), // เพิ่มระยะห่างระหว่างบรรทัด
                                                  Text(
                                                      'Market Order: ไม่ต้องกำหนดราคาที่ต้องการซื้อขาย จะซื้อขายได้ทันที'),
                                                  SizedBox(
                                                      height:
                                                          10), // เพิ่มระยะห่างระหว่างบรรทัด
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                child: Text('ตกลง'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Icon(
                                      Icons.info_outline,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  hintText: 'ราคาลิมิต',
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      'ระยะเวลาของคำสั่ง',
                                      style: TextStyle(
                                          fontFamily: "IBMPlexSansThai",
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20.0)),
                                            ),
                                            content: SizedBox(
                                              height: 400,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      'Good Till Cancelled (GTC):'),
                                                  Text(
                                                      'ออเดอร์จะมีผลจนกว่าจะดำเนินการเสร็จสิ้นหรือผู้เทรดทำการยกเลิกด้วยตนเอง'),
                                                  SizedBox(
                                                      height:
                                                          10), // เพิ่มระยะห่างระหว่างบรรทัด
                                                  Text(
                                                      'Immediate or Cancel (IOC):'),
                                                  Text(
                                                      'ออเดอร์จะต้องดำเนินการสำเร็จบางส่วนทันทีที่ราคาลิมิตหรือราคาที่ดีกว่า และส่วนที่ยังไม่ได้ดำเนินการจะถูกยกเลิก หากไม่สามารถดำเนินการสำเร็จได้ในทันที ออเดอร์จะถูกยกเลิกเช่นกัน'),
                                                  SizedBox(
                                                      height:
                                                          10), // เพิ่มระยะห่างระหว่างบรรทัด
                                                  Text('Fill or Kill (FOK):'),
                                                  Text(
                                                      'ออเดอร์จะต้องดำเนินการสำเร็จทั้งหมดทันทีที่ราคาที่กำหนดไว้หรือดีกว่า มิฉะนั้นจะถูกยกเลิกทั้งหมด FOK แตกต่างจาก IOC เพราะ FOK สามารถดำเนินการให้สำเร็จทั้งหมดหรือยกเลิกทั้งหมดเท่านั้น และจะไม่มีการดำเนินการบางส่วน'),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 20,
                                                      horizontal: 24),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                ),
                                                child: Text('ตกลง'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Icon(
                                      Icons.info_outline,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              TextField(
                                controller: timeInForceController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  hintText: 'เช่น IOC,GTC',
                                ),
                              ),
                              SizedBox(height: 30),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                                "ยืนยันการซื้อ ${widget.symbol}"),
                                            content: SizedBox(
                                              height: 120,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "ประเภท: ${typeController.text}",
                                                  ),
                                                  Text(
                                                    "จำนวน: ${qtyController.text}",
                                                  ),
                                                  Text(
                                                    "ราคาลิมิต: market",
                                                  ),
                                                  Text(
                                                    "ระยะเวลาของคำสั่ง: ${timeInForceController.text}",
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: Text(
                                                  "ยกเลิก",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text(
                                                  "ยืนยัน",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                                onPressed: () {
                                                  placeOrder(
                                                      widget.symbol, "buy");
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Text('ซื้อ'),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.green),
                                      fixedSize:
                                          MaterialStateProperty.all<Size>(
                                        Size(180,
                                            40), // กำหนดขนาดความกว้างและความสูงของปุ่ม
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              20), // Adjust the border radius here
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text(
                                                "ยืนยันการขาย ${widget.symbol}"),
                                            content: SizedBox(
                                              height: 120,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "ประเภท: ${typeController.text}",
                                                  ),
                                                  Text(
                                                    "จำนวน: ${qtyController.text}",
                                                  ),
                                                  Text(
                                                    "ราคาลิมิต: market",
                                                  ),
                                                  Text(
                                                    "ระยะเวลาของคำสั่ง: ${timeInForceController.text}",
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                child: Text(
                                                  "ยกเลิก",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text(
                                                  "ยืนยัน",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                                onPressed: () {
                                                  placeOrder(
                                                      widget.symbol, "sell");
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Text('ขาย'),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(Colors
                                              .red), // Change the background color here
                                      fixedSize:
                                          MaterialStateProperty.all<Size>(
                                        Size(180,
                                            40), // กำหนดขนาดความกว้างและความสูงของปุ่ม
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              20), // Adjust the border radius here
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
