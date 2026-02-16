# Changelog
## 1.0.1
- **Bug Fix**: Remove the video

## 1.0.0

🎉 **Initial Release**

### Features

- **SmartLineChart** — Single and multi-line chart widget
  - Horizontal scrolling with configurable point spacing
  - Pinned (sticky) Y-axis via `showLeftTitles`
  - Gradient fills below lines
  - Colour-coded legend
  - Custom axis label formatters
  - Touch tooltips with value display

- **SmartStreamingChart** — Real-time streaming chart widget
  - Push data via `StreamingChartController`
  - Multi-line support
  - Ring-buffer architecture (up to 50,000 stored points)
  - Configurable visible window size
  - Auto-gradient fills

- **Models & Styling**
  - `SmartChartPoint` — Data point model
  - `SmartChartLine` — Line style configuration
  - `SmartStreamingLine` — Streaming line style
  - `StreamingPoint` — Streaming data point
  - `SmartAxisStyle` — Axis label customisation
  - `SmartTooltipStyle` — Tooltip appearance customisation
