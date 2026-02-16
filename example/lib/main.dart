import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smart_graph_toolkit/smart_graph_toolkit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Graph Toolkit Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.light,
      home: const HomePage(),
    );
  }
}

// ─────────────────────────────────────────────
//  Home – picks between demos
// ─────────────────────────────────────────────
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final demos = <_DemoItem>[
      _DemoItem(
        title: 'Single Line Chart',
        subtitle: 'Scrollable revenue chart with gradient fill',
        icon: Icons.show_chart_rounded,
        color: Colors.deepPurple,
        page: const SingleLineDemo(),
      ),
      _DemoItem(
        title: 'Multi-Line Chart',
        subtitle: 'Compare two datasets on one chart',
        icon: Icons.stacked_line_chart_rounded,
        color: Colors.teal,
        page: const MultiLineDemo(),
      ),
      _DemoItem(
        title: 'Streaming Chart',
        subtitle: 'Real-time data streaming with auto-scroll',
        icon: Icons.stream_rounded,
        color: Colors.orange,
        page: const StreamingDemo(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Graph Toolkit'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: demos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final demo = demos[index];
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: demo.color.withValues(alpha: 0.25),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              leading: CircleAvatar(
                backgroundColor: demo.color.withValues(alpha: 0.15),
                child: Icon(demo.icon, color: demo.color),
              ),
              title: Text(
                demo.title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(demo.subtitle),
              trailing: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: demo.color,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => demo.page),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DemoItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget page;

  const _DemoItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.page,
  });
}

// ─────────────────────────────────────────────
//  Demo 1 – Single scrollable line chart
// ─────────────────────────────────────────────
class SingleLineDemo extends StatelessWidget {
  const SingleLineDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Single Line Chart')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SmartLineChart(
          showLeftTitles: false,
          scrollable: true,
          pointSpacing: 70,
          bottomFormatter: (v) => "Day ${v.toInt()}",
          leftFormatter: (v) => "\$${v.toStringAsFixed(0)}",
          lines: [
            SmartChartLine(
              
              label: "Revenue",
              lineColor: Colors.deepPurple,
              gradientColors: [
                Colors.deepPurple.withValues(alpha: 0.4),
                Colors.transparent,
              ],
              points: List.generate(
                30,
                (i) => SmartChartPoint(
                  x: i.toDouble(),
                  y: (i % 5 + 2) + i * 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Demo 2 – Multi-line comparison chart
// ─────────────────────────────────────────────
class MultiLineDemo extends StatelessWidget {
  const MultiLineDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final random = Random(42);

    return Scaffold(
      appBar: AppBar(title: const Text('Multi-Line Chart')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SmartLineChart(
          showLeftTitles: true,
          scrollable: true,
          pointSpacing: 60,
          showLegend: true,
          bottomFormatter: (v) => "W${v.toInt()}",
          leftFormatter: (v) => "${v.toStringAsFixed(0)}k",
          lines: [
            // Line 1 – Sales
            SmartChartLine(
              label: "Sales",
              lineColor: Colors.teal,
              gradientColors: [
                Colors.teal.withValues(alpha: 0.3),
                Colors.transparent,
              ],
              points: List.generate(
                20,
                (i) => SmartChartPoint(
                  x: i.toDouble(),
                  y: 10 + random.nextDouble() * 8 + i * 0.5,
                ),
              ),
            ),
            // Line 2 – Expenses
            SmartChartLine(
              label: "Expenses",
              lineColor: Colors.redAccent,
              gradientColors: [
                Colors.redAccent.withValues(alpha: 0.3),
                Colors.transparent,
              ],
              points: List.generate(
                20,
                (i) => SmartChartPoint(
                  x: i.toDouble(),
                  y: 6 + random.nextDouble() * 6 + i * 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Demo 3 – Multi-line streaming (real-time) chart
// ─────────────────────────────────────────────
class StreamingDemo extends StatefulWidget {
  const StreamingDemo({super.key});

  @override
  State<StreamingDemo> createState() => _StreamingDemoState();
}

class _StreamingDemoState extends State<StreamingDemo> {
  late final StreamingChartController _controller;
  Timer? _timer;
  double _x = 0;

  static const _lines = [
    SmartStreamingLine(
      label: 'CPU',
      lineColor: Colors.orange,
      lineWidth: 2.5,
    ),
    SmartStreamingLine(
      label: 'GPU',
      lineColor: Colors.cyan,
      lineWidth: 2.5,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = StreamingChartController(
      lineCount: _lines.length,
      maxVisiblePoints: 150,
    );

    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _tick(),
    );
  }

  void _tick() {
    final random = Random();
    // CPU: sine wave centred at 50
    final cpuY = 50 + sin(_x / 10) * 20 + random.nextDouble() * 5;
    // GPU: cosine wave centred at 40
    final gpuY = 40 + cos(_x / 8) * 15 + random.nextDouble() * 4;

    _controller.addPoints({
      0: StreamingPoint(_x, cpuY),
      1: StreamingPoint(_x, gpuY),
    });

    _x++;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multi-Line Streaming')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Data Stream',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Two lines streaming simultaneously at 100 ms intervals.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            // Legend
            Row(
              children: _lines
                  .where((l) => l.label != null)
                  .map(
                    (l) => Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: l.lineColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(l.label!),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SmartStreamingChart(
                controller: _controller,
                lines: _lines,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

