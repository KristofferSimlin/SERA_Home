import 'package:flutter/material.dart';
import 'widgets/floating_lines_background.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.base;
    final sessionId = uri.queryParameters['session_id'];

    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const FloatingLinesBackground(
            enabledWaves: ['middle'],
            lineCount: [6, 8],
            lineDistance: [12.0, 9.0],
            animationSpeed: 0.08,
            opacity: 0.55,
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0B0D12), Color(0xFF0E141C)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cs.primary.withOpacity(0.5),
                          cs.secondary.withOpacity(0.4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.all(2.2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E121A).withOpacity(0.92),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF55F273),
                                  Color(0xFF6EE7FF),
                                  Color(0xFF8A6DFF),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(Icons.check, size: 38, color: Colors.white),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Tack för ditt köp!',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            sessionId != null
                                ? 'Stripe-session: $sessionId'
                                : 'Vi har registrerat din betalning.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/start',
                              (route) => false,
                            ),
                            icon: const Icon(Icons.home_outlined),
                            label: const Text('Till start'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
