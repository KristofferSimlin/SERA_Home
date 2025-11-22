import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Lägg denna som först i en Stack: Positioned.fill(child: ChatBackdrop())
/// Den ger en mörk gradient + mycket subtila, långsamt rörliga orbs.
/// Allt är tonat lågt så bakgrunden inte blir "skrikig".
class ChatBackdrop extends StatefulWidget {
  const ChatBackdrop({
    super.key,
    this.speed = 1.0,
    this.intensity = 1.0,
  });

  final double speed;
  final double intensity;

  @override
  State<ChatBackdrop> createState() => _ChatBackdropState();
}

class _ChatBackdropState extends State<ChatBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    final clampedSpeed = widget.speed.clamp(0.2, 3.0);
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (32000 / clampedSpeed).round()),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant ChatBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speed != widget.speed) {
      final clampedSpeed = widget.speed.clamp(0.2, 3.0);
      _ctrl
        ..duration = Duration(milliseconds: (32000 / clampedSpeed).round())
        ..reset()
        ..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final baseIntensity = widget.intensity.clamp(0.2, 2.5);
    final clampedIntensity = kIsWeb ? (baseIntensity * 0.6) : baseIntensity;
    const baseTop = Color(0xFF0B0F14);
    const baseBottom = Color(0xFF0E1116);

    final blue = cs.primary.withOpacity(0.10 * clampedIntensity);
    final orange = cs.secondary.withOpacity(0.08 * clampedIntensity);
    final teal = cs.tertiary.withOpacity(0.06 * clampedIntensity);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            painter: _BackdropPainter(
              t: _ctrl.value,
              baseTop: baseTop,
              baseBottom: baseBottom,
              orbColors: [blue, orange, teal],
            ),
          );
        },
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter({
    required this.t,
    required this.baseTop,
    required this.baseBottom,
    required this.orbColors,
  });

  final double t;
  final Color baseTop;
  final Color baseBottom;
  final List<Color> orbColors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [baseTop, baseBottom],
      ).createShader(rect);
    canvas.drawRect(rect, base);

    final minSide = size.shortestSide;
    final r1 = minSide * 0.42;
    final r2 = minSide * 0.36;
    final r3 = minSide * 0.5;

    final w = size.width;
    final h = size.height;
    final t1 = t * 2 * math.pi;

    final offsets = [
      Offset(0.35 * w + math.sin(t1 * 0.8) * w * 0.1, 0.25 * h + math.cos(t1 * 0.6) * h * 0.08),
      Offset(0.65 * w + math.cos(t1 * 0.7) * w * 0.12, 0.55 * h + math.sin(t1 * 0.5) * h * 0.1),
      Offset(0.5 * w + math.sin(t1 * 0.4) * w * 0.15, 0.8 * h + math.cos(t1 * 0.3) * h * 0.12),
    ];
    final radii = [r1, r2, r3];

    for (var i = 0; i < offsets.length; i++) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [orbColors[i], Colors.transparent],
        ).createShader(Rect.fromCircle(center: offsets[i], radius: radii[i]));
      canvas.drawCircle(offsets[i], radii[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.orbColors != orbColors;
  }
}
