import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_circle_chart/flutter_circle_chart.dart';

class DataItem {
  static List<CircleChartItemData> generateChartItems() {
    List<Color> colors = [
      Colors.red,
      Colors.blue,
      // เพิ่มสีอื่น ๆ ตามต้องการ
    ];

    return List.generate(
      2,
      (index) {
        Color color = colors[index];
        return CircleChartItemData(
          color: color,
          value: 100 + Random.secure().nextDouble() * 1000,
          name: 'Lorem Ipsum $index',
          description: 'Lorem Ipsum $index ไม่ใช่เพียงแค่ตอนรับสู่ตัวอย่างข้อความสุ่ม.',
          
        );
      },
    );
  }
}

