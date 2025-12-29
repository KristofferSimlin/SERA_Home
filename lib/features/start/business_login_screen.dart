import 'package:flutter/material.dart';
import 'package:sera/l10n/app_localizations.dart';

import 'widgets/floating_lines_background.dart';
import '../../services/stripe_service.dart';

class BusinessLoginScreen extends StatefulWidget {
  const BusinessLoginScreen({super.key});

  @override
  State<BusinessLoginScreen> createState() => _BusinessLoginScreenState();
}

class _BusinessLoginScreenState extends State<BusinessLoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isPaying = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
    return Scaffold(
      appBar: AppBar(title: Text(l.startLoginBusiness)),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0B0D12), Color(0xFF0E141C)],
              ),
            ),
          ),
          if (isCurrentRoute)
            const Positioned.fill(
              child: FloatingLinesBackground(
                enabledWaves: ['middle'],
                lineCount: [6, 8],
                lineDistance: [10.0, 8.0],
                animationSpeed: 0.08,
                opacity: 0.6,
              ),
            ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                cs.primary.withOpacity(0.5),
                                cs.secondary.withOpacity(0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.all(2.2),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E121A).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 84,
                                  height: 84,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF6EE7FF),
                                        Color(0xFF8A6DFF),
                                        Color(0xFF55F273),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: const Icon(Icons.person,
                                      size: 42, color: Colors.white),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l.businessLoginTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l.businessLoginBody,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: cs.onSurface.withOpacity(0.8),
                                        height: 1.4,
                                      ),
                                ),
                                const SizedBox(height: 18),
                                _AuthField(
                                  controller: _userCtrl,
                                  label: l.businessLoginUsername,
                                  icon: Icons.person_outline,
                                ),
                                const SizedBox(height: 12),
                                _AuthField(
                                  controller: _passCtrl,
                                  label: l.businessLoginPassword,
                                  icon: Icons.lock_outline,
                                  obscure: true,
                                ),
                                const SizedBox(height: 18),
                                _GradientButton(
                                  label: l.businessLoginSubmit,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(l.businessLoginButton)),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                _GradientButton(
                                  label: _isPaying
                                      ? 'Öppnar kassa...'
                                      : 'Öppna kassa',
                                  onPressed:
                                      _isPaying ? null : () => _openCheckout(),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  l.businessLoginFooter,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: cs.onSurface.withOpacity(0.65),
                                      ),
                                ),
                              ],
                            ),
                          ),
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
    );
  }

  Future<void> _openCheckout() async {
    setState(() => _isPaying = true);
    try {
      await StripeService.instance.presentPaymentSheet(
        context: context,
        email: _userCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Betalning klar')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte öppna kassa: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPaying = false);
      }
    }
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: cs.onSurface),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        prefixIcon: Icon(icon, color: cs.onSurface.withOpacity(0.8)),
        hintText: label,
        hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.7)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: cs.primary.withOpacity(0.6), width: 1.2),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6EE7FF),
            Color(0xFF8A6DFF),
            Color(0xFF55F273),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
