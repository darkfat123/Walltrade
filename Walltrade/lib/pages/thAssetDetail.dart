import 'dart:ui';
import 'package:flutter/material.dart';

class AssetTHDetailsScreen extends StatelessWidget {
  final String symbol;

  const AssetTHDetailsScreen({required this.symbol});

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
                    symbol,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    symbol,
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
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: TextStyle(
                        fontSize: 24,
                        fontFamily: "IBMPlexSansThai",
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "price",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    "market status",
                    style: TextStyle(
                      fontSize: 14,
                    ),
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
                                                  vertical: 20, horizontal: 24),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
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
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              hintText: 'เช่น IOC,GTC',
                            ),
                          ),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // ตรวจสอบการคลิกปุ่มและดำเนินการต่อไป
                                },
                                child: Text('ซื้อ'),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.green),
                                  fixedSize: MaterialStateProperty.all<Size>(
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
                                  // ตรวจสอบการคลิกปุ่มและดำเนินการต่อไป
                                },
                                child: Text('ขาย'),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(Colors
                                          .red), // Change the background color here
                                  fixedSize: MaterialStateProperty.all<Size>(
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
    );
  }
}
