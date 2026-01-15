import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sera/l10n/app_localizations.dart';

import 'widgets/floating_lines_background.dart';
import 'widgets/floating_lines_light_background.dart';

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
    enabledWaves: ['top', 'middle'],
    lineCount: [5, 8],
    lineDistance: [10.0, 8.0],
    animationSpeed: 0.08,
    opacity: 0.6,
    maxContentWidth: 880,
    fullWidthButton: false,
  ),
  _StartVariant.webMobile: _StartViewConfig(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    titleSpacing: 18,
    callToActionSpacing: 32,
    enabledWaves: ['middle'],
    lineCount: [4],
    lineDistance: [9.0],
    animationSpeed: 0.08,
    opacity: 0.55,
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
  final isHandheldPlatform = defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;

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

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
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

  Future<void> _handlePersonalAccess() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasAccess = prefs.getBool('personal_access') ?? false;
      if (!mounted) return;
      if (hasAccess) {
        _enterApp();
      } else {
        Navigator.of(context).pushNamed('/personal-pricing');
      }
    } catch (e) {
      if (!mounted) return;
      // Handle error gracefully, e.g., show a snackbar or fallback to default behavior
      _enterApp();
    }
  }

  void _handleBusinessLogin() {
    Navigator.of(context).pushNamed('/business-login');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _resolveConfig(context);
    final l = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallPhone = screenWidth < 380;
    final logoSize = isSmallPhone ? 90.0 : 100.0;
    final logoSpacing = isSmallPhone ? 6.0 : 12.0;
    final betaPadH = isSmallPhone ? 10.0 : 12.0;
    final betaPadV = isSmallPhone ? 4.0 : 6.0;
    final betaLetterSpacing = isSmallPhone ? 1.5 : 2.0;
    final titleLetterSpacing = isSmallPhone ? 4.0 : 6.0;
    final titleStyle = (isSmallPhone
            ? Theme.of(context).textTheme.displayMedium
            : Theme.of(context).textTheme.displayLarge)
        ?.copyWith(
            fontWeight: FontWeight.bold, letterSpacing: titleLetterSpacing);
    final titleHeight =
        (titleStyle?.fontSize ?? 32) * (titleStyle?.height ?? 1.0);
    final loginBoxMaxWidth =
        isSmallPhone ? config.maxContentWidth : config.maxContentWidth * 0.55;
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    return Scaffold(
      body: TickerMode(
        enabled: isCurrentRoute,
        child: AnimatedBuilder(
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
              if (isDark) ...[
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
              ] else ...[
                FloatingLinesLightBackground(
                  enabledWaves: config.enabledWaves,
                  lineCount: config.lineCount,
                  lineDistance: config.lineDistance,
                  animationSpeed: config.animationSpeed,
                  opacity: config.opacity,
                ),
              ],
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: config.padding,
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: config.maxContentWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          if (isSmallPhone)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'sera_logo/SERA6_original.png',
                                  height: logoSize,
                                  semanticLabel: 'SERA logo',
                                ),
                                const SizedBox(height: 90),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'sera_logo/SERA-Text-blank.png',
                                      height: titleHeight,
                                      semanticLabel: 'SERA wordmark',
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: betaPadH,
                                          vertical: betaPadV),
                                      decoration: BoxDecoration(
                                        color: cs.primary.withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        l.beta,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              letterSpacing: betaLetterSpacing,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'sera_logo/SERA5.png',
                                  height: logoSize,
                                  semanticLabel: 'SERA logo',
                                ),
                                SizedBox(width: logoSpacing),
                                Image.asset(
                                  'sera_logo/SERA-Text-blank.png',
                                  height: titleHeight,
                                  semanticLabel: 'SERA wordmark',
                                ),
                                SizedBox(width: logoSpacing),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: betaPadH, vertical: betaPadV),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    l.beta,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(
                                          letterSpacing: betaLetterSpacing,
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
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: cs.onSurface.withOpacity(0.75),
                                ),
                          ),
                          SizedBox(height: config.callToActionSpacing),
                          Align(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: loginBoxMaxWidth,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      cs.primary.withOpacity(0.75),
                                      cs.secondary.withOpacity(0.75),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.all(1.5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                        0xFF0E121A), // solid inner background so gradient only on frame
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: FilledButton.icon(
                                          style: FilledButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: _handleBusinessLogin,
                                          icon:
                                              const Icon(Icons.business_center),
                                          label: Text(l.startLoginBusiness),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        width: double.infinity,
                                        child: FilledButton.icon(
                                          style: FilledButton.styleFrom(
                                            backgroundColor:
                                                cs.primary.withOpacity(0.85),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: _handlePersonalAccess,
                                          icon: const Icon(Icons.person),
                                          label: Text(l.startLoginPersonal),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: _enterApp,
                                          icon: const Icon(
                                              Icons.play_arrow_rounded),
                                          label: Text(l.startCta),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            l.startVersion,
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
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
      ),
    );
  }
}
