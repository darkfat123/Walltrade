import 'package:Walltrade/model/pricePoints.dart';
import 'package:Walltrade/widget/chart/LineChart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'makeDismissible.dart';

var testPrice = 210;
Widget buildPredictSheet({
  required List<Map<String, dynamic>> data,
  required BuildContext
      context, // เพิ่มพารามิเตอร์ context ที่รับค่า BuildContext
}) {
  return makeDismissible(
    child: DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          padding: EdgeInsets.all(20),
          child: ListView.builder(
            itemCount: data.length, // จำนวนรายการข้อมูล
            itemBuilder: (BuildContext context, int index) {
              var item = data[index];
              return Container(
                margin: EdgeInsets.all(8),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
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
                child: ListTile(
                  title: Column(
                    children: [
                      Text(
                        '${item['symbol'].toString().toUpperCase()}',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18),
                      ),
                      Text(
                        item['symbol'].endsWith('.BK')
                            ? 'ราคาที่ทำนายในวันถัดไป: ${item['prediction']} บาท'
                            : 'ราคาที่ทำนายในวันถัดไป: ${item['prediction']} USD',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                      Text(
                        'ราคาปัจจุบัน: 112.29',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                      Text(
                        'แนวโน้มจากการทำนาย: ขึ้น',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                      ),
                      PredictLineChart()
                    ],
                  ),
                ),
              );
            },
          )),
    ),
    context: context,
  );
}
