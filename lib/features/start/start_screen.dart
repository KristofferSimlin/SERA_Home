import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sera/l10n/app_localizations.dart';

import 'widgets/floating_lines_background.dart';

enum _StartVariant { webDesktop, webMobile, app }

class _StartViewConfig {
  const _StartViewConfig({
    required this.padding,
    required this.titleSpacing,
    required this.callToActionSpacing,
    required this.enabledWaves,
    required this.lineCount,
    required this.lineDistance,
    required this.animationSpeed,
    required this.opacity,
    required this.maxContentWidth,
    required this.fullWidthButton,
  });

  final EdgeInsets padding;
  final double titleSpacing;
  final double callToActionSpacing;
  final List<String> enabledWaves;
  final List<int> lineCount;
  final List<double> lineDistance;
  final double animationSpeed;
  final double opacity;
  final double maxContentWidth;
  final bool fullWidthButton;
}

const _startConfigs = <_StartVariant, _StartViewConfig>{
  _StartVariant.webDesktop: _StartViewConfig(
    padding: EdgeInsets.all(32),
    titleSpacing: 24,
    callToActionSpacing: 48,
    enabledWaves: ['top', 'middle', 'bottom'],
    lineCount: [8, 12, 14],
    lineDistance: [9.0, 7.0, 5.0],
    animationSpeed: 0.12,
    opacity: 0.72,
    maxContentWidth: 880,
    fullWidthButton: false,
  ),
  _StartVariant.webMobile: _StartViewConfig(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    titleSpacing: 18,
    callToActionSpacing: 32,
    enabledWaves: ['middle', 'bottom'],
    lineCount: [6, 9],
    lineDistance: [7.5, 5.5],
    animationSpeed: 0.16,
    opacity: 0.65,
    maxContentWidth: 520,
    fullWidthButton: true,
  ),
  _StartVariant.app: _StartViewConfig(
    padding: EdgeInsets.all(32),
    titleSpacing: 24,
    callToActionSpacing: 48,
    enabledWaves: ['top', 'middle', 'bottom'],
    lineCount: [10, 15, 20],
    lineDistance: [8.0, 6.0, 4.0],
    animationSpeed: 0.1375,
    opacity: 0.85,
    maxContentWidth: 720,
    fullWidthButton: true,
  ),
};

const _mobileBreakpoint = 720.0;

_StartViewConfig _resolveConfig(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  final isCompactWidth = size.width < _mobileBreakpoint;
  final isHandheldPlatform =
      defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android;

  if (kIsWeb && isCompactWidth) {
    return _startConfigs[_StartVariant.webMobile]!;
  }
  if (kIsWeb) {
    return _startConfigs[_StartVariant.webDesktop]!;
  }
  if (isHandheldPlatform || isCompactWidth) {
    return _startConfigs[_StartVariant.app]!;
  }
  return _startConfigs[_StartVariant.webDesktop]!;
}

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
    final config = _resolveConfig(context);
    final l = AppLocalizations.of(context)!;
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0B0D12),
                    Color(0xFF0E141C),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: FloatingLinesBackground(
                enabledWaves: config.enabledWaves,
                lineCount: config.lineCount,
                lineDistance: config.lineDistance,
                animationSpeed: config.animationSpeed,
                opacity: config.opacity,
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: config.padding,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: config.maxContentWidth),
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
                        l.beta,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: config.titleSpacing),
                Text(
                  l.startSubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: cs.onSurface.withOpacity(0.75),
                      ),
                ),
                SizedBox(height: config.callToActionSpacing),
                SizedBox(
                  width: config.fullWidthButton ? double.infinity : null,
                  child: FilledButton.icon(
                    onPressed: _enterApp,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(l.startCta),
                  ),
                ),
                const Spacer(),
                Text(
                  l.startVersion,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
