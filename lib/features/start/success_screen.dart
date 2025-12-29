import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.base;
    final sessionId = uri.queryParameters['session_id'];

    return Scaffold(
      appBar: AppBar(title: const Text('Betalningen lyckades')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline,
                    size: 72, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'Tack för ditt köp!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  sessionId != null
                      ? 'Din Stripe-session: $sessionId'
                      : 'Vi har registrerat din betalning.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    );
  }
}
