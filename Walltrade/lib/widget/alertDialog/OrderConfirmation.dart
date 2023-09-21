import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

void quickAlert(
  BuildContext context,
  String symbol,
  String qty,
  String technicalText,
  String interval,
  String side,
  Function(String, String, String, String, String) onPlaceOrder,
) {
  symbol == '' || qty == '' || technicalText == ''
      ? QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'มีบางอย่างผิดพลาด',
          text: 'โปรดกรอกข้อมูลให้ครบถ้วน',
          width: 0,
          confirmBtnColor: Color(0xFF212436),
          confirmBtnText: 'ตกลง',
          confirmBtnTextStyle: TextStyle(fontSize: 14, color: Colors.white))
      : QuickAlert.show(
          context: context,
          type: QuickAlertType.info,
          title: 'ยืนยันคำสั่งซื้อ',
          width: 350,
          widget: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Symbol: ',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    symbol,
                    style: TextStyle(fontSize: 14),
                  )
                ],
              ),
              SizedBox(
                height: 2,
              ),
              Row(
                children: [
                  Text(
                    "ประเภทคำสั่ง: ",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  side == 'buy'
                      ? Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                          decoration: BoxDecoration(
                              color: Color(0xFF82CD47),
                              borderRadius: BorderRadius.circular(15)),
                          child: Text(
                            "ซื้อ",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                fontSize: 14),
                          ),
                        )
                      : Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                          decoration: BoxDecoration(
                              color: Color(0xFFBB2525),
                              borderRadius: BorderRadius.circular(15)),
                          child: Text(
                            "ขาย",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                fontSize: 14),
                          ),
                        )
                ],
              ),
              SizedBox(
                height: 2,
              ),
              Row(
                children: [
                  Text(
                    'Timeframe: ',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
              SizedBox(
                height: 2,
              ),
              Row(
                children: [
                  Text(
                    'จำนวน: ',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    '$qty หน่วย',
                    style: TextStyle(fontSize: 14),
                  )
                ],
              ),
              SizedBox(
                height: 2,
              ),
              Row(
                children: [
                  Text(
                    'เทคนิค: ',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    technicalText,
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.clip,
                  )
                ],
              ),
            ],
          ),
          onConfirmBtnTap: () {
            onPlaceOrder(qty, side, symbol, interval, side);
            Navigator.of(context).pop();
          },
          onCancelBtnTap: () {
            Navigator.of(context).pop();
          },
          showCancelBtn: true,
          cancelBtnText: 'ยกเลิก',
          cancelBtnTextStyle: TextStyle(
            fontSize: 14,
          ),
          confirmBtnText: 'ยืนยัน',
          confirmBtnColor:
              side == 'buy' ? Color(0xFF82CD47) : Color(0xFFBB2525),
          confirmBtnTextStyle: TextStyle(fontSize: 14, color: Colors.white),
        );
}
