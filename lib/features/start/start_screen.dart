import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'widgets/floating_lines_background.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _enterApp() {
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWeb = kIsWeb;
    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeIn,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeIn.value,
            child: child,
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withOpacity(0.12),
                    cs.surface,
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: FloatingLinesBackground(
                enabledWaves: ['top', 'middle', 'bottom'],
                lineCount: isWeb ? [8, 12, 14] : [10, 15, 20],
                lineDistance: isWeb ? [9.0, 7.0, 5.0] : [8.0, 6.0, 4.0],
                animationSpeed: isWeb ? 0.12 : 0.1375,
                opacity: isWeb ? 0.72 : 0.85,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'SERA',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 6,
                              ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'BETA',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Service & Equipment Repair Assistant',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: cs.onSurface.withOpacity(0.75),
                          ),
                    ),
                    const SizedBox(height: 48),
                    FilledButton.icon(
                      onPressed: _enterApp,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Kom igång'),
                    ),
                    const Spacer(),
                    Text(
                      'Version 1.0 • För tekniker och supportteam',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
