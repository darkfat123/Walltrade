import 'package:flutter/material.dart';

class OrderConfirmationSellDialog extends StatelessWidget {
  final String symbol;
  final String qty;
  final String technicalText;
  final String interval;
  final Function(String, String, String, String) onPlaceOrder;

  OrderConfirmationSellDialog({
    required this.symbol,
    required this.qty,
    required this.technicalText,
    required this.interval,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return symbol == '' || qty == '' || technicalText == ''
        ? AlertDialog(
            title: Text(
              'ข้อมูลผิดพลาด',
              style: TextStyle(fontSize: 16),
            ),
            content: Text(
              'โปรดใส่ข้อมูลให้ครบถ้วน',
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                child: Text(
                  'ตกลง',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          )
        : AlertDialog(
            title: Text(
              'ยืนยันคำสั่งซื้อ',
              style: TextStyle(fontSize: 16),
            ),
            content: IntrinsicHeight(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Symbol: ',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        symbol,
                        style: TextStyle(fontSize: 14),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "ประเภทคำสั่ง: ",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Chip(
                        backgroundColor: Color(0xFFBB2525),
                        label: Text(
                          "ขาย",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Timeframe: ',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        interval == '1h'
                            ? '1 ชั่วโมง'
                            : interval == '4h'
                                ? '4 ชั่วโมง'
                                : interval == '1D'
                                    ? '1 วัน'
                                    : '1 สัปดาห์',
                        style: TextStyle(fontSize: 14),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'จำนวน: ',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        '$qty หน่วย',
                        style: TextStyle(fontSize: 14),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'เทคนิคที่ใช้: ',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        technicalText,
                        style: TextStyle(fontSize: 14),
                      )
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('ยกเลิก',
                    style: TextStyle(color: Colors.black87, fontSize: 14)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                  'ตกลง',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                onPressed: () {
                  onPlaceOrder(qty, 'sell', symbol, interval);
                  Navigator.of(context).pop();

                  // แสดง Snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'สร้างคำสั่งเพื่อซื้อเรียบร้อยแล้ว!'), // ข้อความที่ต้องการแสดงใน Snackbar
                      duration:
                          Duration(seconds: 2), // ระยะเวลาในการแสดง Snackbar
                    ),
                  );
                },
              ),
            ],
          );
  }
}