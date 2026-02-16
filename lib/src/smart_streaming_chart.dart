import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  Models
// ─────────────────────────────────────────────

/// A single streaming data point.
class StreamingPoint {
  final double x;
  final double y;

  const StreamingPoint(this.x, this.y);

  FlSpot toSpot() => FlSpot(x, y);
}

/// Describes the visual style of one line in a [SmartStreamingChart].
class SmartStreamingLine {
  final String? label;
  final Color lineColor;
  final List<Color>? gradientColors;
  final double lineWidth;
  final bool curved;

  const SmartStreamingLine({
    this.label,
    this.lineColor = Colors.deepPurple,
    this.gradientColors,
    this.lineWidth = 2,
    this.curved = true,
  });
}

// ─────────────────────────────────────────────
//  Controller
// ─────────────────────────────────────────────

/// Manages data buffers for a [SmartStreamingChart].
///
/// Create one controller per chart. Push data into it via [addPoint] or
/// [addPoints]. The controller maintains per-line ring buffers and notifies
/// the chart widget to rebuild only the visible portion.
class StreamingChartController extends ChangeNotifier {
  final int lineCount;
  final int maxVisiblePoints;
  final int maxStoredPoints;

  late final List<List<StreamingPoint>> _buffers;

  StreamingChartController({
    required this.lineCount,
    this.maxVisiblePoints = 200,
    this.maxStoredPoints = 50000,
  }) : _buffers = List.generate(lineCount, (_) => <StreamingPoint>[]);

  /// Add a single point to line at [lineIndex].
  void addPoint(int lineIndex, StreamingPoint point) {
    assert(lineIndex >= 0 && lineIndex < lineCount);

    final buffer = _buffers[lineIndex];
    buffer.add(point);

    if (buffer.length > maxStoredPoints) {
      buffer.removeAt(0);
    }

    notifyListeners();
  }

  /// Add one point per line in a single tick.
  ///
  /// The map key is the line index and value is the point.
  void addPoints(Map<int, StreamingPoint> points) {
    for (final entry in points.entries) {
      assert(entry.key >= 0 && entry.key < lineCount);

      final buffer = _buffers[entry.key];
      buffer.add(entry.value);

      if (buffer.length > maxStoredPoints) {
        buffer.removeAt(0);
      }
    }
    notifyListeners();
  }

  /// Returns the visible slice of spots for the given [lineIndex].
  List<FlSpot> visibleSpots(int lineIndex) {
    final buffer = _buffers[lineIndex];
    final visible = buffer.length <= maxVisiblePoints
        ? buffer
        : buffer.sublist(buffer.length - maxVisiblePoints);
    return visible.map((e) => e.toSpot()).toList();
  }

  /// Returns true when every line has at least one point.
  bool get hasData => _buffers.every((b) => b.isNotEmpty);

  /// Clears all buffers.
  void reset() {
    for (final buffer in _buffers) {
      buffer.clear();
    }
    notifyListeners();
  }
}

// ─────────────────────────────────────────────
//  Widget
// ─────────────────────────────────────────────

/// A real-time streaming line chart that supports multiple lines.
///
/// Data is fed through a [StreamingChartController]. The widget rebuilds
/// efficiently using the controller's [ChangeNotifier].
///
/// ```dart
/// final controller = StreamingChartController(lineCount: 2);
///
/// SmartStreamingChart(
///   controller: controller,
///   lines: [
///     SmartStreamingLine(label: 'CPU', lineColor: Colors.blue),
///     SmartStreamingLine(label: 'GPU', lineColor: Colors.red),
///   ],
/// );
/// ```
class SmartStreamingChart extends StatelessWidget {
  final StreamingChartController controller;
  final List<SmartStreamingLine> lines;

  const SmartStreamingChart({
    super.key,
    required this.controller,
    required this.lines,
  }) : assert(lines.length > 0, 'At least one line is required');

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.hasData) {
          return const SizedBox();
        }

        // Collect all visible spots across all lines
        final allLineSpots = <List<FlSpot>>[];
        for (var i = 0; i < lines.length; i++) {
          allLineSpots.add(controller.visibleSpots(i));
        }

        // Compute global min / max across all lines
        final allSpots = allLineSpots.expand((s) => s);
        if (allSpots.isEmpty) return const SizedBox();

        final minX = allSpots.map((e) => e.x).reduce(min);
        final maxX = allSpots.map((e) => e.x).reduce(max);
        final minY = allSpots.map((e) => e.y).reduce(min);
        final maxY = allSpots.map((e) => e.y).reduce(max);

        return LineChart(
          LineChartData(
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY + 5,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: const FlTitlesData(show: false),
            lineTouchData: const LineTouchData(enabled: false),
            lineBarsData: List.generate(lines.length, (i) {
              final line = lines[i];
              final spots = allLineSpots[i];
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
                          colors: line.gradientColors!,
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      )
                    : BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            line.lineColor.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
              );
            }),
          ),
          duration: Duration.zero,
        );
      },
    );
  }
}
