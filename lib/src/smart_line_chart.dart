import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smart_graph_toolkit/smart_graph_toolkit.dart';


class SmartChartLine {
  final List<SmartChartPoint> points;
  final Color lineColor;
  final List<Color>? gradientColors;
  final double lineWidth;
  final bool curved;
  final String? label;

  const SmartChartLine({
    required this.points,
    required this.lineColor,
    this.gradientColors,
    this.lineWidth = 3,
    this.curved = true,
    this.label,
  });
}

class SmartLineChart extends StatelessWidget {
  final List<SmartChartLine> lines;
  final String Function(double value)? bottomFormatter;
  final String Function(double value)? leftFormatter;
  final TextStyle? bottomLabelStyle;
  final TextStyle? leftLabelStyle;
  final bool showLegend;
   final bool showLeftTitles;

  /// Enable horizontal scrolling
  final bool scrollable;

  /// Width per data point (controls zoom level)
  final double pointSpacing;

  const SmartLineChart({
    super.key,
    required this.lines,
    this.bottomFormatter,
    this.leftFormatter,
    this.bottomLabelStyle,
    this.leftLabelStyle,
    this.showLegend = true,
    this.scrollable = true,
    this.pointSpacing = 60,
    this.showLeftTitles = false,
  });

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return const Center(child: Text("No Data"));
    }

    final allSpots = lines
        .expand((line) => line.points.map((e) => e.toFlSpot()))
        .toList();

    final minY =
        allSpots.map((e) => e.y).reduce((a, b) => a < b ? a : b);

    final maxY =
        allSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    final paddedMaxY = maxY + (maxY * 0.1);

    final xValues = allSpots.map((e) => e.x).toList();
    final yValues = allSpots.map((e) => e.y).toList();

    final xInterval = _calculateInterval(xValues);
    final yInterval = _calculateInterval(yValues);

    final maxPoints = lines
        .map((line) => line.points.length)
        .reduce((a, b) => a > b ? a : b);

    // ── Non-scrollable: render everything in one chart ──
    if (!scrollable) {
      final chart = SizedBox(
        width: double.infinity,
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: paddedMaxY,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: _buildTitles(xInterval, yInterval),
            lineTouchData: _buildTouchData(),
            lineBarsData: lines.map(_buildLineBar).toList(),
          ),
        ),
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showLegend) _buildLegend(),
          Expanded(child: chart),
        ],
      );
    }

    // ── Scrollable: pin the left axis, scroll the chart body ──
    const double leftReservedSize = 42;
    const double bottomReservedSize = 32;
    const double bottomPaddingTop = 8;

    final chartWidth = maxPoints * pointSpacing;

    // When showLeftTitles is true (pinned), hide fl_chart's left titles.
    // When false, let fl_chart render them so they scroll with the chart.
    final scrollableChart = SizedBox(
      width: chartWidth,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: paddedMaxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: _buildTitles(xInterval, yInterval, showLeftTitles ? false : true),
          lineTouchData: _buildTouchData(),
          lineBarsData: lines.map(_buildLineBar).toList(),
        ),
      ),
    );

    // Fixed left axis rendered manually
    final leftAxis = SizedBox(
      width: leftReservedSize,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The available height for the chart area (excluding bottom labels)
          final chartHeight = constraints.maxHeight -
              bottomReservedSize -
              bottomPaddingTop;

          if (chartHeight <= 0) return const SizedBox();

          final range = paddedMaxY - minY;
          if (range <= 0) return const SizedBox();

          // Generate tick values
          final ticks = <double>[];
          var tick = (minY / yInterval).ceilToDouble() * yInterval;
          while (tick <= paddedMaxY) {
            ticks.add(tick);
            tick += yInterval;
          }

          return Stack(
            children: [
              for (final t in ticks)
                Positioned(
                  left: 0,
                  right: 0,
                  // Map value → pixel offset from top
                  top: chartHeight -
                      ((t - minY) / range) * chartHeight -
                      6, // centre the text (~12px height / 2)
                  child: Center(
                    child: Text(
                      leftFormatter?.call(t) ?? t.toStringAsFixed(0),
                      style: leftLabelStyle ??
                          const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLegend) _buildLegend(),
        Expanded(
          child: Row(
            children: [
              if (showLeftTitles) leftAxis,
              if (showLeftTitles) const SizedBox(width: 4),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: scrollableChart,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  LineChartBarData _buildLineBar(SmartChartLine line) {
    final spots = line.points.map((e) => e.toFlSpot()).toList();

    return LineChartBarData(
      spots: spots,
      isCurved: line.curved,
      color: line.lineColor,
      barWidth: line.lineWidth,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: line.gradientColors != null
          ? BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: line.gradientColors!,
              ),
            )
          : BarAreaData(show: false),
    );
  }

  FlTitlesData _buildTitles(double xInterval, double yInterval,
      [bool? overrideShowLeftTitles]) {
    final bool effectiveShowLeftTitles = overrideShowLeftTitles ?? showLeftTitles;
    return FlTitlesData(
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: xInterval,
          reservedSize: 32,
          getTitlesWidget: (value, meta) {
            if (value % xInterval != 0) {
              return const SizedBox.shrink();
            }

            final text = bottomFormatter?.call(value) ??
                value.toInt().toString();

            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                text,
                style:
                    bottomLabelStyle ?? const TextStyle(fontSize: 12),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: effectiveShowLeftTitles,
          interval: yInterval,
          reservedSize: 42,
          getTitlesWidget: (value, meta) {
            if (value % yInterval != 0) {
              return const SizedBox.shrink();
            }

            final text =
                leftFormatter?.call(value) ?? value.toStringAsFixed(0);

            return Text(
              text,
              style:
                  leftLabelStyle ?? const TextStyle(fontSize: 12),
            );
          },
        ),
      ),
    );
  }

  LineTouchData _buildTouchData() {
    return LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (touchedSpot) =>  Colors.black87,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            return LineTooltipItem(
              spot.y.toStringAsFixed(2),
              TextStyle(
                color: spot.bar.color ?? Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList();
        },
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 16,
        children: lines
            .where((line) => line.label != null)
            .map(
              (line) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: line.lineColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(line.label!),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  double _calculateInterval(List<double> values) {
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = max - min;

    if (range == 0) return 1;

    return (range / 4).ceilToDouble();
  }
}
