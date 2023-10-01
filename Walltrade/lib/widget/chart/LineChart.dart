import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PredictLineChart extends StatefulWidget {
  final List<double> realPrices;
  final List<double> predictedPrices;

  final int value;

  const PredictLineChart({
    super.key,
    required this.realPrices,
    required this.predictedPrices,
    required this.value,
  });

  @override
  State<PredictLineChart> createState() => _PredictLineChartState();
}

class _PredictLineChartState extends State<PredictLineChart> {
  List<Color> gradientColors = [
    const Color(0xFFE55807),
    const Color(0xFF7E1717),
  ];

  List<Color> gradientColors2 = [
    const Color(0xFF468B97),
    const Color(0xFF1D5B79),
  ];

  double getLowestRealPrices() {
    double lowestRealPrices = 0;
    if (widget.value == 0) {
      lowestRealPrices = widget.realPrices
          .sublist(widget.realPrices.length - 30)
          .reduce((a, b) => a < b ? a : b);
      return lowestRealPrices;
    } else if (widget.value == 1) {
      lowestRealPrices = widget.realPrices
          .sublist(widget.realPrices.length - 90)
          .reduce((a, b) => a < b ? a : b);
      return lowestRealPrices;
    } else {
      return widget.realPrices.reduce((a, b) => a < b ? a : b);
    }
  }

  double getLowestPredictPrices() {
    double lowestPredictPrices = 0;
    if (widget.value == 0) {
      lowestPredictPrices = widget.predictedPrices
          .sublist(widget.predictedPrices.length - 31)
          .reduce((a, b) => a < b ? a : b);
      return lowestPredictPrices;
    } else if (widget.value == 1) {
      lowestPredictPrices = widget.predictedPrices
          .sublist(widget.predictedPrices.length - 91)
          .reduce((a, b) => a < b ? a : b);
      return lowestPredictPrices;
    } else {
      return widget.predictedPrices.reduce((a, b) => a < b ? a : b);
    }
  }

  double getHighestRealPrices() {
    double highestRealPrices = 0;
    if (widget.value == 0) {
      highestRealPrices = widget.realPrices
          .sublist(widget.realPrices.length - 30)
          .reduce((a, b) => a > b ? a : b);
      return highestRealPrices;
    } else if (widget.value == 1) {
      highestRealPrices = widget.realPrices
          .sublist(widget.realPrices.length - 90)
          .reduce((a, b) => a > b ? a : b);
      return highestRealPrices;
    } else {
      return widget.realPrices.reduce((a, b) => a > b ? a : b);
    }
  }

  double getHighestPredictPrices() {
    double highestPredictPrices = 0;
    if (widget.value == 0) {
      highestPredictPrices = widget.predictedPrices
          .sublist(widget.predictedPrices.length - 31)
          .reduce((a, b) => a > b ? a : b);
      return highestPredictPrices;
    } else if (widget.value == 1) {
      highestPredictPrices = widget.predictedPrices
          .sublist(widget.predictedPrices.length - 91)
          .reduce((a, b) => a > b ? a : b);
      return highestPredictPrices;
    } else {
      return widget.predictedPrices.reduce((a, b) => a > b ? a : b);
    }
  }

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

  LineChartData mainData(List<double> realPrices, List<double> predictPrices) {
    return LineChartData(
      gridData: const FlGridData(
        show: false,
      ),
      titlesData: const FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 30,
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
      minX: widget.value == 0
          ? 150
          : widget.value == 1
              ? 90
              : 0,
      maxX: 180, // ปรับขอบเขต X
      minY: getLowestRealPrices() < getLowestPredictPrices()
          ? getLowestRealPrices()*0.95
          : getLowestPredictPrices()*0.95,

      maxY: getHighestRealPrices() < getHighestPredictPrices()
          ? getHighestPredictPrices()*1.05
          : getHighestRealPrices()*1.05,
      lineBarsData: [
        LineChartBarData(
          spots: widget.value == 0
              ? realPrices
                  .asMap()
                  .entries
                  .map(
                    (entry) {
                      final int index = entry.key;
                      final double price = entry.value;
                      return FlSpot(index.toDouble(), price);
                    },
                  )
                  .toList()
                  .sublist(realPrices.length - 30)
              : widget.value == 1
                  ? realPrices
                      .asMap()
                      .entries
                      .map(
                        (entry) {
                          final int index = entry.key;
                          final double price = entry.value;
                          return FlSpot(index.toDouble(), price);
                        },
                      )
                      .toList()
                      .sublist(realPrices.length - 90)
                  : realPrices.asMap().entries.map(
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
          spots: widget.value == 0
              ? predictPrices
                  .asMap()
                  .entries
                  .map(
                    (entry) {
                      final int index = entry.key;
                      final double price = entry.value;
                      return FlSpot(index.toDouble(), price);
                    },
                  )
                  .toList()
                  .sublist(predictPrices.length - 31)
              : widget.value == 1
                  ? predictPrices
                      .asMap()
                      .entries
                      .map(
                        (entry) {
                          final int index = entry.key;
                          final double price = entry.value;
                          return FlSpot(index.toDouble(), price);
                        },
                      )
                      .toList()
                      .sublist(predictPrices.length - 91)
                  : predictPrices.asMap().entries.map(
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
