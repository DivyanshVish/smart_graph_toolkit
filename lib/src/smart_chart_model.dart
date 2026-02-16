import 'package:fl_chart/fl_chart.dart';


class SmartChartPoint {
  final double x;
  final double y;

  const SmartChartPoint({
    required this.x,
    required this.y,
  });

  FlSpot toFlSpot() => FlSpot(x, y);
}
