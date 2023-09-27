import 'dart:convert';
import 'dart:ui';
import 'package:Walltrade/primary.dart';
import 'package:Walltrade/variables/serverURL.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AssetTHDetailsScreen extends StatefulWidget {
  final String symbol;
  final String fullname;
  final String username;

  const AssetTHDetailsScreen(
      {required this.symbol, required this.fullname, required this.username});

  @override
  _AssetTHDetailsScreenState createState() => _AssetTHDetailsScreenState();
}

class _AssetTHDetailsScreenState extends State<AssetTHDetailsScreen> {
  dynamic price = 0;
  dynamic percentage = 0;
  String selectedValidate = "Day";
  List<String> validateItems = ['Day', 'IOC', 'GTC', 'FOK'];
  List<String> typeItems = ['Limit', 'Market'];
  String selectedType = "Limit";
  bool isEnabledLimitPrice = true;

  TextEditingController qtyController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController limitPriceController = TextEditingController();
  TextEditingController validateController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchSymbolPrice(widget.symbol);
  }

  Future<void> fetchSymbolPrice(String symbol) async {
    final url = Uri.parse('${Constants.serverUrl}/getOneSymbolPrice');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'symbol': symbol}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        setState(() {
          final firstItem = data[0]; // รับรายการแรกในลิสต์
          price = firstItem['price'];
          percentage = firstItem['percentage'];
          print(percentage);
        });
      } else {
        print('ไม่พบข้อมูลราคา');
      }
    } else {
      throw Exception('การส่งคำขอไม่สำเร็จ: ${response.statusCode}');
    }
  }

  Future<void> placeOrder_th(String side) async {
    final url = Uri.parse(
        '${Constants.serverUrl}/place_order_th'); // แทนค่า YOUR_FLASK_SERVER_URL ด้วย URL ของ Flask Server ของคุณ

    final Map<String, dynamic> orderData = {
      'username': widget.username,
      'symbol': widget.symbol, // แทนค่า symbol ตามที่คุณต้องการ
      'qty': double.parse(qtyController.text), // แทนค่า qty ตามที่คุณต้องการ
      'side': side, // แทนค่า side ตามที่คุณต้องการ (BUY หรือ SELL)
      'limitPrice': double.parse(limitPriceController.text),
      'validate': selectedValidate,
      'type': typeController.text // แทนค่า limitPrice ตามที่คุณต้องการ
    };

    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(orderData);

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
      } else {
        print('เกิดข้อผิดพลาดในการส่งคำสั่งซื้อ: ${response.statusCode}');
        print('ข้อความผิดพลาด: ${response.body}');
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการเชื่อมต่อเซิร์ฟเวอร์: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
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
                    widget.fullname,
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
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                color: primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.symbol,
                      style: TextStyle(
                          fontSize: 24,
                          fontFamily: "IBMPlexSansThai",
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Text(
                      widget.fullname,
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: "IBMPlexSansThai",
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ราคาปัจจุบัน:",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        Row(
                          children: [
                            Text(
                              "${price.toString()} บาท",
                              style:
                                  TextStyle(fontSize: 24, color: Colors.white),
                            ),
                            SizedBox(
                              width: 12,
                            ),
                            Text(
                              "${percentage > 0 ? '+${percentage.toString()}%' : '${percentage.toString()}%'}",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: percentage > 0
                                      ? Color(0xFF00FFA3)
                                      : Color(0xFFFF002E)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30)),
                    color: Colors.white),
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                  content: IntrinsicHeight(
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
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      onChanged: (newValue) {
                        setState(() {
                          selectedType = newValue!;
                          isEnabledLimitPrice =
                              selectedType == "Market" ? false : true;
                          if (selectedType == "Market") {
                            limitPriceController.text = '0';
                          }
                        });
                      },
                      items: typeItems.map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'เลือกประเภท (Limit หรือ Market)',
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
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
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'จำนวนหุ้น',
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                  content: IntrinsicHeight(
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
                      enabled: isEnabledLimitPrice,
                      controller: limitPriceController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
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
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                  ),
                                  content: IntrinsicHeight(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'หากเลือกเป็น Market จะสามารถใช้ได้เพียง FOK และ IOC เท่านั้น',
                                          style: TextStyle(
                                              fontFamily: "IBMPlexSansThai",
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.red),
                                        ),
                                        SizedBox(height: 10),
                                        Text('Good Till Cancelled (GTC):'),
                                        Text(
                                          'ออเดอร์จะมีผลจนกว่าจะดำเนินการเสร็จสิ้นหรือผู้เทรดทำการยกเลิกด้วยตนเอง',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        SizedBox(
                                            height:
                                                10), // เพิ่มระยะห่างระหว่างบรรทัด
                                        Text('Immediate or Cancel (IOC):'),
                                        Text(
                                          'ออเดอร์จะต้องดำเนินการสำเร็จบางส่วนทันทีที่ราคาลิมิตหรือราคาที่ดีกว่า และส่วนที่ยังไม่ได้ดำเนินการจะถูกยกเลิก หากไม่สามารถดำเนินการสำเร็จได้ในทันที ออเดอร์จะถูกยกเลิกเช่นกัน',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        SizedBox(
                                            height:
                                                10), // เพิ่มระยะห่างระหว่างบรรทัด
                                        Text('Fill or Kill (FOK):'),
                                        Text(
                                          'ออเดอร์จะต้องดำเนินการสำเร็จทั้งหมดทันทีที่ราคาที่กำหนดไว้หรือดีกว่า มิฉะนั้นจะถูกยกเลิกทั้งหมด FOK แตกต่างจาก IOC เพราะ FOK สามารถดำเนินการให้สำเร็จทั้งหมดหรือยกเลิกทั้งหมดเท่านั้น และจะไม่มีการดำเนินการบางส่วน',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        SizedBox(height: 10),
                                        Text('Day Order (DAY):'),
                                        Text(
                                          'ออเดอร์จะถูกส่งเข้าไปในระบบ และยังไม่ได้รับการจับคู่ รอจับคู่จนกระทั่งถึง สิ้นวันทําการนั้นๆ หลังจากนั้น คําสั่งจะถูกล้างออกจากระบบโดยอัตโนมัติ',
                                          style: TextStyle(fontSize: 14),
                                        )
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 24),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                          child: Row(
                            children: [
                              Text("โปรดอ่านก่อน"),
                              SizedBox(width: 8,),
                              Icon(
                                Icons.info_outline,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: selectedValidate, // ค่าที่ถูกเลือก
                      onChanged: (newValue) {
                        setState(() {
                          selectedValidate = newValue!; // เมื่อเลือกค่าใหม่
                        });
                      },
                      items: validateItems.map((item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'เลือกค่า IOC หรือ GTC',
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("ยืนยันการซื้อ ${widget.symbol}"),
                              content: IntrinsicHeight(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "ประเภท: ",
                                    ),
                                    Text(
                                      "จำนวน: ",
                                    ),
                                    Text(
                                      "ราคาลิมิต: market",
                                    ),
                                    Text(
                                      "ระยะเวลาของคำสั่ง:",
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: Text(
                                    "ยกเลิก",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    "ยืนยัน",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  onPressed: () {
                                    placeOrder_th("Buy");
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('ซื้อ'),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF82CD47),
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("ยืนยันการขาย ${widget.symbol}"),
                              content: IntrinsicHeight(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "ประเภท: ",
                                    ),
                                    Text(
                                      "จำนวน: ",
                                    ),
                                    Text(
                                      "ราคาลิมิต: market",
                                    ),
                                    Text(
                                      "ระยะเวลาของคำสั่ง:",
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: Text(
                                    "ยกเลิก",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text(
                                    "ยืนยัน",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  onPressed: () {
                                    placeOrder_th("Sell");
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('ขาย'),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFBB2525),
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
    );
  }
}
