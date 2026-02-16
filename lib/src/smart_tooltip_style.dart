import 'package:flutter/material.dart';

class SmartTooltipStyle {
  final TextStyle textStyle;
  final Color backgroundColor;
  final EdgeInsets padding;

  const SmartTooltipStyle({
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    this.backgroundColor = Colors.black87,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
  });
}
