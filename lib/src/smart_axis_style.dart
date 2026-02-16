import 'package:flutter/material.dart';

class SmartAxisStyle {
  final TextStyle labelStyle;
  final double reservedSize;
  final String Function(double value)? formatter;

  const SmartAxisStyle({
    this.labelStyle = const TextStyle(fontSize: 12),
    this.reservedSize = 30,
    this.formatter,
  });
}

