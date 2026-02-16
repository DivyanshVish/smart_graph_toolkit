# Smart Graph Toolkit

[![Pub Version](https://img.shields.io/pub/v/smart_graph_toolkit.svg)](https://pub.dev/packages/smart_graph_toolkit)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.3.0-02569B?logo=flutter)](https://flutter.dev)

A powerful, lightweight Flutter charting library for building **beautiful line charts** and **real-time streaming charts** with minimal setup. Built on top of [`fl_chart`](https://pub.dev/packages/fl_chart).

---

## ✨ Features

- 📈 **Single & Multi-Line Charts** — Plot one or more datasets with gradient fills, legends, and custom formatters
- 🔄 **Real-Time Streaming Charts** — Push live data via `StreamingChartController` with configurable buffer sizes
- 📌 **Pinned Y-Axis** — Sticky left axis that stays visible while scrolling horizontally
- 🖱️ **Horizontal Scrolling** — Smoothly scroll through large datasets with bouncing physics
- 🎨 **Fully Customisable** — Custom colours, gradients, tooltips, label styles, and axis formatters
- ⚡ **High Performance** — Ring-buffer architecture for efficient streaming with up to 50,000 stored points

---

## 📸 Screenshots

<p align="center">
  <img src="https://raw.githubusercontent.com/DivyanshVish/smart_graph_toolkit/main/asset/single_line_chart.png" width="250" alt="Single Line Chart" />
  &nbsp;&nbsp;
  <img src="https://raw.githubusercontent.com/DivyanshVish/smart_graph_toolkit/main/asset/multi_line_chart.png" width="250" alt="Multi-Line Chart" />
  &nbsp;&nbsp;
  <img src="https://raw.githubusercontent.com/DivyanshVish/smart_graph_toolkit/main/asset/streaming_chart_1.png" width="250" alt="Streaming Chart" />
</p>

---

## 🚀 Getting Started

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  smart_graph_toolkit: ^1.0.0
```

Then run:

```bash
flutter pub get
```

### Import

```dart
import 'package:smart_graph_toolkit/smart_graph_toolkit.dart';
```

---

## 📖 Usage

### Single Line Chart

```dart
SmartLineChart(
  scrollable: true,
  showLeftTitles: true,       // Pin Y-axis to the left
  pointSpacing: 70,
  bottomFormatter: (v) => "Day ${v.toInt()}",
  leftFormatter: (v) => "\$${v.toStringAsFixed(0)}",
  lines: [
    SmartChartLine(
      label: "Revenue",
      lineColor: Colors.deepPurple,
      gradientColors: [
        Colors.deepPurple.withOpacity(0.4),
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
)
```

### Multi-Line Chart

```dart
SmartLineChart(
  scrollable: true,
  showLeftTitles: true,
  showLegend: true,
  pointSpacing: 60,
  bottomFormatter: (v) => "W${v.toInt()}",
  leftFormatter: (v) => "${v.toStringAsFixed(0)}k",
  lines: [
    SmartChartLine(
      label: "Sales",
      lineColor: Colors.teal,
      gradientColors: [
        Colors.teal.withOpacity(0.3),
        Colors.transparent,
      ],
      points: salesData,
    ),
    SmartChartLine(
      label: "Expenses",
      lineColor: Colors.redAccent,
      gradientColors: [
        Colors.redAccent.withOpacity(0.3),
        Colors.transparent,
      ],
      points: expensesData,
    ),
  ],
)
```

### Real-Time Streaming Chart

```dart
// 1. Create a controller
final controller = StreamingChartController(
  lineCount: 2,
  maxVisiblePoints: 150,
);

// 2. Push data (e.g., from a timer or WebSocket)
controller.addPoints({
  0: StreamingPoint(x, cpuValue),
  1: StreamingPoint(x, gpuValue),
});

// 3. Build the widget
SmartStreamingChart(
  controller: controller,
  lines: const [
    SmartStreamingLine(label: 'CPU', lineColor: Colors.orange),
    SmartStreamingLine(label: 'GPU', lineColor: Colors.cyan),
  ],
)
```

---

## 📚 API Reference

### SmartLineChart

| Property | Type | Default | Description |
|---|---|---|---|
| `lines` | `List<SmartChartLine>` | *required* | The data lines to plot |
| `scrollable` | `bool` | `true` | Enable horizontal scrolling |
| `showLeftTitles` | `bool` | `false` | Pin the Y-axis to the left edge |
| `showLegend` | `bool` | `true` | Show the colour-coded legend |
| `pointSpacing` | `double` | `60` | Pixel width per data point (zoom level) |
| `bottomFormatter` | `String Function(double)?` | `null` | Custom X-axis label formatter |
| `leftFormatter` | `String Function(double)?` | `null` | Custom Y-axis label formatter |
| `bottomLabelStyle` | `TextStyle?` | `null` | Style for X-axis labels |
| `leftLabelStyle` | `TextStyle?` | `null` | Style for Y-axis labels |

### SmartChartLine

| Property | Type | Default | Description |
|---|---|---|---|
| `points` | `List<SmartChartPoint>` | *required* | Data points for this line |
| `lineColor` | `Color` | *required* | Colour of the line |
| `gradientColors` | `List<Color>?` | `null` | Fill gradient below the line |
| `lineWidth` | `double` | `3` | Thickness of the line |
| `curved` | `bool` | `true` | Use curved (spline) interpolation |
| `label` | `String?` | `null` | Legend label |

### StreamingChartController

| Property / Method | Description |
|---|---|
| `lineCount` | Number of lines in the chart |
| `maxVisiblePoints` | Max points visible at once (default: `200`) |
| `maxStoredPoints` | Ring-buffer capacity (default: `50000`) |
| `addPoint(lineIndex, point)` | Push a single point to one line |
| `addPoints(Map<int, StreamingPoint>)` | Push one point per line in a single tick |
| `reset()` | Clear all data buffers |
| `dispose()` | Release resources |

---

## 🤝 Contributing

Contributions are welcome! Please open an issue or submit a pull request on [GitHub](https://github.com/DivyanshVish/smart_graph_toolkit).

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
