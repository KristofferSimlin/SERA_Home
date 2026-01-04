import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sera/l10n/app_localizations.dart';
import 'dart:html' as html;

import 'widgets/floating_lines_background.dart';
import '../../services/stripe_service.dart';
import '../../services/supabase_client.dart';

class BusinessLoginScreen extends StatefulWidget {
  const BusinessLoginScreen({super.key});

  @override
  State<BusinessLoginScreen> createState() => _BusinessLoginScreenState();
}

class _BusinessLoginScreenState extends State<BusinessLoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _isPaying = false;
  bool _loggingIn = false;
  String _role = 'admin';
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      final savedEmail = html.window.localStorage['sera_login_email'];
      if (savedEmail != null && savedEmail.isNotEmpty) {
        _userCtrl.text = savedEmail;
        _rememberMe = true;
      }
    }
  }

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
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
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
                                _RoleTabs(
                                  value: _role,
                                  onChanged: (v) => setState(() => _role = v),
                                ),
                                const SizedBox(height: 14),
                                _RoleContainer(
                                  role: _role,
                                  child: AutofillGroup(
                                    child: Column(
                                      children: [
                                        _AuthField(
                                          controller: _userCtrl,
                                          label: l.businessLoginUsername,
                                          icon: Icons.person_outline,
                                          autofillHints: const [
                                            AutofillHints.username,
                                            AutofillHints.email
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        _AuthField(
                                          controller: _passCtrl,
                                          label: l.businessLoginPassword,
                                          icon: Icons.lock_outline,
                                          obscure: true,
                                          autofillHints: const [
                                            AutofillHints.password
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Checkbox(
                                                value: _rememberMe,
                                                onChanged: (v) {
                                                  setState(() {
                                                    _rememberMe = v ?? false;
                                                  });
                                                  if (kIsWeb && !(v ?? false)) {
                                                    html.window.localStorage
                                                        .remove('sera_login_email');
                                                  }
                                                },
                                              ),
                                              const SizedBox(width: 4),
                                              const Text('Kom ihåg mig'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                _GradientButton(
                                  label: _role == 'admin'
                                      ? 'Logga in som admin'
                                      : 'Logga in som user',
                                  onPressed: _loggingIn ? null : _submitLogin,
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _resetPassword,
                                  child: const Text('Glömt lösenord?'),
                                ),
                                const SizedBox(height: 6),
                                _GradientButton(
                                  label: _isPaying
                                      ? 'Öppnar kassa...'
                                      : 'Skapa företagskonto',
                                  onPressed:
                                      _isPaying ? null : () => _openCheckout(),
                                ),
                                const SizedBox(height: 4),
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
      await StripeService.instance.startCheckoutSession(
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

  Future<void> _submitLogin() async {
    final email = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fyll i användarnamn och lösenord')),
      );
      return;
    }
    if (!isSupabaseReady()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inloggning är inte konfigurerad.')),
      );
      return;
    }
    setState(() => _loggingIn = true);
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: pass,
      );
      // Roll ska komma från app_metadata (systemstyrt), inte user_metadata.
      final appMeta = res.user?.appMetadata ?? {};
      final role = appMeta['role']?.toString();
      if (role == null || role.isEmpty) {
        throw 'Roll saknas på kontot';
      }
      if (role != _role) {
        await supabase.auth.signOut();
        throw 'Du har rollen "$role" men valde "${_role == 'admin' ? 'Admin' : 'User'}".';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inloggad som $role')),
      );
      if (kIsWeb && _rememberMe) {
        html.window.localStorage['sera_login_email'] = email;
      } else if (!kIsWeb && _rememberMe) {
        TextInput.finishAutofillContext(shouldSave: true);
      }
      Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loggingIn = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte logga in: $e')),
      );
    }
  }

  Future<void> _resetPassword() async {
    final email = _userCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ange e-post för återställning')),
      );
      return;
    }
    if (!isSupabaseReady()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Supabase ej konfigurerat')),
      );
      return;
    }
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://www.sera.chat/activate',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Återställningslänk skickad')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte skicka länk: $e')),
      );
    }
  }
}

class _RoleTabs extends StatelessWidget {
  const _RoleTabs({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        _pill(context, label: 'Admin', v: 'admin', selected: value == 'admin'),
        const SizedBox(width: 12),
        _pill(context, label: 'User', v: 'user', selected: value == 'user'),
      ],
    );
  }

  Widget _pill(BuildContext context,
      {required String label, required String v, required bool selected}) {
    final cs = Theme.of(context).colorScheme;
    final borderColor = selected
        ? cs.primary.withOpacity(0.7)
        : cs.onSurface.withOpacity(0.2);
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: const Color(0xFF0E121A).withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: selected ? 1.3 : 1),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(v),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleContainer extends StatelessWidget {
  const _RoleContainer({required this.role, required this.child});

  final String role;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor = cs.primary.withOpacity(0.6);
    final alignRight = role != 'admin';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          padding: const EdgeInsets.fromLTRB(12, 18, 12, 12),
          child: child,
        ),
        Positioned(
          top: -10,
          left: alignRight ? null : 16,
          right: alignRight ? 16 : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              role == 'admin' ? 'Admin' : 'User',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final List<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      obscureText: obscure,
      autofillHints: autofillHints,
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
