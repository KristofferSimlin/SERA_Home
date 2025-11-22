import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Positions a wave by offsetting it horizontally (`x`), vertically (`y`) and
/// applying a subtle rotation factor (`rotate`). Values are intentionally
/// similar to the Three.js implementation so the same configuration can be reused.
@immutable
class WavePosition {
  const WavePosition({
    this.x = 0,
    this.y = 0,
    this.rotate = 0,
  });

  final double x;
  final double y;
  final double rotate;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WavePosition && other.x == x && other.y == y && other.rotate == rotate;
  }

  @override
  int get hashCode => Object.hash(x, y, rotate);
}

class FloatingLinesBackground extends StatefulWidget {
  const FloatingLinesBackground({
    super.key,
    this.enabledWaves = const ['top', 'middle', 'bottom'],
    this.lineCount = const [6],
    this.lineDistance = const [5],
    this.topWavePosition = const WavePosition(x: 10, y: 0.5, rotate: -0.4),
    this.middleWavePosition = const WavePosition(x: 5, y: 0, rotate: 0.2),
    this.bottomWavePosition = const WavePosition(x: 2, y: -0.7, rotate: 0.4),
    this.lineGradient = const [
      Color(0xFFE947F5),
      Color.fromARGB(255, 9, 16, 36),
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
  final List<Color> lineGradient;
  final double animationSpeed;
  final double opacity;

  @override
  State<FloatingLinesBackground> createState() => _FloatingLinesBackgroundState();
}

class _FloatingLinesBackgroundState extends State<FloatingLinesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Duration get _duration {
    final speed = widget.animationSpeed.clamp(0.05, 3.0);
    final rawMillis = (14000 / speed).clamp(4000, 60000);
    return Duration(milliseconds: rawMillis.round());
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant FloatingLinesBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationSpeed != widget.animationSpeed) {
      _controller
        ..duration = _duration
        ..reset()
        ..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final waves = _buildWaveParams();
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _FloatingLinesPainter(
            progress: _controller.value,
            opacity: widget.opacity,
            lineGradient: widget.lineGradient,
            waves: waves,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }

  List<_WaveParams> _buildWaveParams() {
    return <_WaveParams>[
      _WaveParams(
        type: _WaveType.top,
        lineCount: _resolveLineCount('top'),
        lineDistance: _resolveLineDistance('top'),
        position: widget.topWavePosition ?? const WavePosition(),
        amplitudeScale: 0.35,
        speed: 0.45,
        enabled: widget.enabledWaves.contains('top'),
      ),
      _WaveParams(
        type: _WaveType.middle,
        lineCount: _resolveLineCount('middle'),
        lineDistance: _resolveLineDistance('middle'),
        position: widget.middleWavePosition ?? const WavePosition(),
        amplitudeScale: 0.45,
        speed: 0.75,
        enabled: widget.enabledWaves.contains('middle'),
      ),
      _WaveParams(
        type: _WaveType.bottom,
        lineCount: _resolveLineCount('bottom'),
        lineDistance: _resolveLineDistance('bottom'),
        position: widget.bottomWavePosition ?? const WavePosition(),
        amplitudeScale: 0.55,
        speed: 0.95,
        enabled: widget.enabledWaves.contains('bottom'),
      ),
    ];
  }

  int _resolveLineCount(String waveType) {
    if (!widget.enabledWaves.contains(waveType)) return 0;
    if (widget.lineCount.isEmpty) return 6;
    if (widget.lineCount.length == 1) return widget.lineCount.first;
    final index = widget.enabledWaves.indexOf(waveType);
    if (index >= 0 && index < widget.lineCount.length) {
      return widget.lineCount[index];
    }
    return widget.lineCount.last;
  }

  double _resolveLineDistance(String waveType) {
    if (!widget.enabledWaves.contains(waveType)) return 0.1;
    if (widget.lineDistance.isEmpty) return 5;
    if (widget.lineDistance.length == 1) return widget.lineDistance.first.toDouble();
    final index = widget.enabledWaves.indexOf(waveType);
    if (index >= 0 && index < widget.lineDistance.length) {
      return widget.lineDistance[index];
    }
    return widget.lineDistance.last.toDouble();
  }
}

enum _WaveType { top, middle, bottom }

class _WaveParams {
  const _WaveParams({
    required this.type,
    required this.lineCount,
    required this.lineDistance,
    required this.position,
    required this.amplitudeScale,
    required this.speed,
    required this.enabled,
  });

  final _WaveType type;
  final int lineCount;
  final double lineDistance;
  final WavePosition position;
  final double amplitudeScale;
  final double speed;
  final bool enabled;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _WaveParams &&
        other.type == type &&
        other.lineCount == lineCount &&
        other.lineDistance == lineDistance &&
        other.position == position &&
        other.amplitudeScale == amplitudeScale &&
        other.speed == speed &&
        other.enabled == enabled;
  }

  @override
  int get hashCode => Object.hash(
        type,
        lineCount,
        lineDistance,
        position,
        amplitudeScale,
        speed,
        enabled,
      );
}

class _FloatingLinesPainter extends CustomPainter {
  _FloatingLinesPainter({
    required this.progress,
    required this.lineGradient,
    required this.waves,
    required this.opacity,
  });

  final double progress;
  final List<Color> lineGradient;
  final List<_WaveParams> waves;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final rect = Offset.zero & size;
    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    for (final wave in waves) {
      if (!wave.enabled || wave.lineCount <= 0) continue;

      final spacing = wave.lineDistance * 0.01 * size.height;
      final centerY = size.height * (0.5 - wave.position.y.clamp(-1.5, 1.5) * 0.5);
      for (int i = 0; i < wave.lineCount; i++) {
        final t = wave.lineCount == 1 ? 0.0 : i / (wave.lineCount - 1);
        final color =
            _colorAt(t).withOpacity(opacity * (0.7 + 0.3 * (1 - t)));
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1
          ..color = color;
        final path = _createPath(
          size: size,
          wave: wave,
          lineIndex: i,
          centerY: centerY,
          spacing: spacing,
        );

        glowPaint
          ..color = color.withOpacity(color.opacity * 0.6)
          ..strokeWidth = 1.8;
        canvas.drawPath(path, glowPaint);
        canvas.drawPath(path, paint);
      }
    }

    // Soft vignette for better blending with the background gradient.
    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withOpacity(0.28),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  Path _createPath({
    required Size size,
    required _WaveParams wave,
    required int lineIndex,
    required double centerY,
    required double spacing,
  }) {
    final path = Path();
    final normalizedIndex = wave.lineCount <= 1 ? 0.0 : lineIndex / (wave.lineCount - 1);
    final baseY = centerY + (lineIndex - (wave.lineCount - 1) / 2) * spacing;
    final amplitude = size.height * wave.amplitudeScale * (0.7 + normalizedIndex * 0.4);
    final steps = math.max(40, (size.width / 12).round());
    final double phase = progress * math.pi * 2 * (0.5 + wave.speed) + wave.position.rotate;
    for (int step = 0; step <= steps; step++) {
      final x = step / steps * size.width;
      final u = x / size.width;
      final wobble = math.sin(
        (u * (2.5 + wave.position.x * 0.05) + phase) +
            normalizedIndex * 0.6 +
            wave.position.rotate,
      );
      final bend = math.cos(u * 6 + phase * 0.25 + normalizedIndex);
      final y = baseY + wobble * amplitude + bend * amplitude * 0.15;
      if (step == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    return path;
  }

  Color _colorAt(double t) {
    if (lineGradient.isEmpty) {
      return Colors.white;
    }
    if (lineGradient.length == 1) {
      return lineGradient.first;
    }
    final clamped = t.clamp(0.0, 0.9999);
    final scaled = clamped * (lineGradient.length - 1);
    final index = scaled.floor();
    final nextIndex = math.min(index + 1, lineGradient.length - 1);
    final fraction = scaled - index;
    return Color.lerp(lineGradient[index], lineGradient[nextIndex], fraction) ??
        lineGradient[index];
  }

  @override
  bool shouldRepaint(covariant _FloatingLinesPainter oldDelegate) {
    final waveChanged = !_areWavesEqual(oldDelegate.waves, waves);
    final gradientChanged = !listEquals(oldDelegate.lineGradient, lineGradient);
    return oldDelegate.progress != progress ||
        waveChanged ||
        gradientChanged ||
        oldDelegate.opacity != opacity;
  }

  bool _areWavesEqual(List<_WaveParams> a, List<_WaveParams> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
