import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PredictLineChart extends StatefulWidget {
  const PredictLineChart({super.key});

  @override
  State<PredictLineChart> createState() => _PredictLineChartState();
}

class _PredictLineChartState extends State<PredictLineChart> {
  List<Color> gradientColors = [
    Color(0xFFE55807),
    Color(0xFF7E1717),
  ];

  List<Color> gradientColors2 = [
    Color(0xFF468B97),
    Color(0xFF1D5B79),
  ];

  double testChart = 312.5;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.6,
          child: LineChart(
            mainData(),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('วันก่อน', style: style);
        break;
      case 1:
        text = const Text('เมื่อวาน', style: style);
        break;
      case 2:
        text = const Text('วันนี้', style: style);
        break;
      case 3:
        text = const Text('พรุ่งนี้', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      fitInside: SideTitleFitInsideData(
          enabled: false,
          axisPosition: -1,
          parentAxisSize: 0,
          distanceFromEdge: 0),
      axisSide: meta.axisSide,
      child: text,
    );
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: const FlGridData(
        show: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 3,
      minY: testChart / 2,
      maxY: testChart * 1.5,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 298.5),
            FlSpot(1, 318.6),
            FlSpot(2, 429.42),
            FlSpot(3, 387.86),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.5))
                  .toList(),
            ),
          ),
        ),
        LineChartBarData(
          spots: const [
            FlSpot(0, 199.5),
            FlSpot(1, 300.6),
            FlSpot(2, 414.42),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors2,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors2
                  .map((color) => color.withOpacity(0.5))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
