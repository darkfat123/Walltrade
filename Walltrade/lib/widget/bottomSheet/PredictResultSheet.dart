import 'package:Walltrade/model/pricePoints.dart';
import 'package:Walltrade/widget/chart/LineChart.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'makeDismissible.dart';

class PredictSheet extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  PredictSheet({required this.data});

  @override
  _PredictSheetState createState() => _PredictSheetState();
}

class _PredictSheetState extends State<PredictSheet> {
  var value = 0;

  @override
  Widget build(BuildContext context) {
    return makeDismissible(
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
                color: const Color(0xFF212436),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
            padding: EdgeInsets.all(20),
            child: ListView.builder(
              itemCount: widget.data.length, // จำนวนรายการข้อมูล
              itemBuilder: (BuildContext context, int index) {
                var item = widget.data[index];
                List<double> realPrices = [];
                List<double> predictedPrices = [];
                realPrices =
                    (item['real_prices_chart'] as List<dynamic>).cast<double>();

                predictedPrices =
                    (item['predict_prices_chart'] as List<dynamic>)
                        .cast<double>();

                double percentage =
                    ((item['prediction'] - item['close']) / item['close']) *
                        100;
                return Container(
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: ListTile(
                    title: Column(
                      children: [
                        Chip(
                          backgroundColor: const Color(0xFF212436),
                          label: Text(
                            '${item['symbol'].toString().toUpperCase()}',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          item['symbol'].endsWith('.BK')
                              ? 'ราคาที่ทำนายในวันถัดไป: ${NumberFormat('#,##0.00', 'en_US').format(item['prediction'])} บาท'
                              : 'ราคาที่ทำนายในวันถัดไป: ${NumberFormat('#,##0.00', 'en_US').format(item['prediction'])} USD',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        Text(
                          item['symbol'].endsWith('.BK')
                              ? 'ราคาปัจจุบัน: ${NumberFormat('#,##0.00', 'en_US').format(item['close'])} บาท'
                              : 'ราคาปัจจุบัน: ${NumberFormat('#,##0.00', 'en_US').format(item['close'])} USD',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        item['prediction'] > item['close']
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'แนวโน้มจากการทำนาย: ขึ้น',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .keyboard_double_arrow_up_rounded,
                                          color: Color(0xFF82CD47),
                                          size: 20,
                                        ),
                                        Text(
                                          '${percentage.toStringAsFixed(2)}%',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'แนวโน้มจากการทำนาย: ลง',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .keyboard_double_arrow_down_rounded,
                                          color: Color(0xFFBB2525),
                                          size: 20,
                                        ),
                                        Text(
                                          '${percentage.toStringAsFixed(2)}%',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                        SizedBox(
                          height: 16,
                        ),
                        AnimatedToggleSwitch<int>.rollingByHeight(
                          current: value,
                          indicatorIconScale: 1,
                          values: const [0, 1, 2],
                          style:
                              ToggleStyle(backgroundColor: Color(0xFF424554)),
                          onChanged: (i) {
                            setState(() {
                              value = i;
                            });
                            print(value);
                          },
                          iconList: [
                            Container(
                              margin: EdgeInsets.all(4),
                              child: Text(
                                "1M",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 12),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(4),
                              child: Text(
                                "3M",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 12),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(4),
                              child: Text(
                                "6M",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 12),
                              ),
                            ),
                          ],
                          height: 35,
                          spacing: 0.5,
                        ),
                        PredictLineChart(
                            realPrices: realPrices,
                            predictedPrices: predictedPrices,
                            value: value),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.linear_scale_rounded,
                                  size: 30,
                                  color: Color(0xFFE55807),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text('ราคาจริง')
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.linear_scale_rounded,
                                  size: 30,
                                  color: Color(0xFF468B97),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text('ราคาทำนาย')
                              ],
                            ),
                          ],
                        ),
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
}
