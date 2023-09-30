import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PredictLineChart extends StatefulWidget {
  final List<double> realPrices;
  final List<double> predictedPrices;

  const PredictLineChart({
    super.key,
    required this.realPrices,
    required this.predictedPrices,
  });

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
            mainData(widget.realPrices, widget.predictedPrices),
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

  LineChartData mainData(List<double> realPrices, List<double> predictPrices) {
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
            interval: 10,
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
      maxX: predictPrices.length.toDouble() - 1, // ปรับขอบเขต X
      minY: realPrices.reduce((a, b) => a > b ? a : b) <=
              predictPrices.reduce((a, b) => a < b ? a : b)
          ? realPrices.reduce((a, b) => a > b ? a : b)
          : predictPrices.reduce((a, b) => a < b ? a : b),
      maxY: realPrices.reduce((a, b) => a > b ? a : b) >=
              predictPrices.reduce((a, b) => a < b ? a : b)
          ? realPrices.reduce((a, b) => a > b ? a : b)
          : predictPrices.reduce((a, b) => a < b ? a : b),
      lineBarsData: [
        LineChartBarData(
          spots: realPrices.asMap().entries.map(
            (entry) {
              final int index = entry.key;
              final double price = entry.value;
              return FlSpot(index.toDouble(), price);
            },
          ).toList(),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
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
          spots: predictPrices.asMap().entries.map(
            (entry) {
              final int index = entry.key;
              final double price = entry.value;
              return FlSpot(index.toDouble(), price);
            },
          ).toList(),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors2,
          ),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
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
