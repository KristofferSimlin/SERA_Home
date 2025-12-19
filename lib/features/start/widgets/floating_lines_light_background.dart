import 'package:flutter/material.dart';

import 'floating_lines_background.dart';

/// Light variant of the floating lines with a soft grey backdrop and dark lines.
class FloatingLinesLightBackground extends StatelessWidget {
  const FloatingLinesLightBackground({
    super.key,
    this.enabledWaves = const ['top', 'middle', 'bottom'],
    this.lineCount = const [6],
    this.lineDistance = const [5],
    this.topWavePosition = const WavePosition(x: 10, y: 0.5, rotate: -0.4),
    this.middleWavePosition = const WavePosition(x: 5, y: 0, rotate: 0.2),
    this.bottomWavePosition = const WavePosition(x: 2, y: -0.7, rotate: 0.4),
    this.backgroundGradient = const [
      Color(0xFFF2F3F5),
      Color(0xFFE7E9EC),
    ],
    this.lineGradient = const [
      Color.fromARGB(255, 78, 73, 73),
      Color.fromARGB(255, 126, 120, 120),
    ],
    this.animationSpeed = 1,
    this.opacity = 0.9,
  });

  final List<String> enabledWaves;
  final List<int> lineCount;
  final List<double> lineDistance;
  final WavePosition? topWavePosition;
  final WavePosition? middleWavePosition;
  final WavePosition? bottomWavePosition;
  final List<Color> backgroundGradient;
  final List<Color> lineGradient;
  final double animationSpeed;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: backgroundGradient,
            ),
          ),
        ),
        FloatingLinesBackground(
          enabledWaves: enabledWaves,
          lineCount: lineCount,
          lineDistance: lineDistance,
          topWavePosition: topWavePosition,
          middleWavePosition: middleWavePosition,
          bottomWavePosition: bottomWavePosition,
          lineGradient: lineGradient,
          animationSpeed: animationSpeed,
          opacity: opacity,
        ),
      ],
    );
  }
}
