import 'package:flutter/material.dart';

/// Eight visually distinct, tasteful default colors — one per pillar.
const List<Color> defaultPillarColors = [
  Color(0xFFE0645A), // warm red
  Color(0xFFE8974D), // orange
  Color(0xFFD8B84A), // gold
  Color(0xFF6FAE6E), // green
  Color(0xFF4AA3C4), // teal blue
  Color(0xFF5C7CC4), // indigo
  Color(0xFF9B6FC4), // purple
  Color(0xFFB98A6B), // warm brown
];

/// Mapping of grid positions (row, col) within a 3x3 block, in the
/// canonical reading order used to lay out the 8 pillars / 8 goals,
/// skipping the center cell (1,1).
const List<List<int>> order8 = [
  [0, 0], [0, 1], [0, 2],
  [1, 0], [1, 2],
  [2, 0], [2, 1], [2, 2],
];

Color lighten(Color c, [double amount = .3]) {
  final hsl = HSLColor.fromColor(c);
  final l = (hsl.lightness + amount).clamp(0.0, 1.0);
  return hsl.withLightness(l).toColor();
}

Color darken(Color c, [double amount = .2]) {
  final hsl = HSLColor.fromColor(c);
  final l = (hsl.lightness - amount).clamp(0.0, 1.0);
  return hsl.withLightness(l).toColor();
}
