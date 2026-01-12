import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_client.dart';
import '../start/widgets/floating_lines_background.dart';
import '../../utils/auth_params.dart';
import '../../utils/web_storage.dart' as storage;

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _loading = true;
  String? _email;
  String? _error;
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final uri = Uri.base;
    try {
      final fallbackUri = uri.fragment.contains('access_token=')
          ? Uri.parse('${uri.scheme}://${uri.host}${uri.path}?${uri.fragment}')
          : uri;
      final res = await supabase.auth.getSessionFromUrl(fallbackUri);
      if (res.session != null) {
        setState(() {
          _email = res.session!.user.email;
          _loading = false;
        });
        return;
      }
    } catch (_) {}

    var qp = parseAuthParams(uri);
    if (qp.isEmpty) {
      final storedHref = await storage.readSession('sera_auth_href');
      if (storedHref != null && storedHref.isNotEmpty) {
        qp = parseAuthParams(Uri.parse(storedHref));
      }
    }
    final refresh = qp['refresh_token'];
    if (refresh != null) {
      try {
        final resp = await supabase.auth.setSession(refresh);
        if (resp.session != null) {
          setState(() {
            _email = resp.session!.user.email;
            _loading = false;
          });
          return;
        }
      } catch (_) {}
    }
    final token = qp['token_hash'] ?? qp['token'];
    if (token != null && token.isNotEmpty) {
      try {
        await supabase.auth.exchangeCodeForSession(token);
        final user = supabase.auth.currentUser;
        setState(() {
          _email = user?.email;
          _loading = false;
        });
        return;
      } catch (e) {
        setState(() {
          _error = 'Kunde inte sätta session: $e';
          _loading = false;
        });
        return;
      }
    }
    setState(() {
      _error = 'Token saknas. Öppna länken från mejlet igen.';
      _loading = false;
    });
  }

  Future<void> _setPassword() async {
    final p1 = _passCtrl.text.trim();
    final p2 = _pass2Ctrl.text.trim();
    setState(() {
      _error = null;
    });
    if (p1.isEmpty || p1.length < 8) {
      setState(() {
        _error = 'Lösenordet måste vara minst 8 tecken.';
      });
      return;
    }
    if (p1 != p2) {
      setState(() {
        _error = 'Lösenorden matchar inte.';
      });
      return;
    }
    setState(() => _loading = true);
    try {
      await supabase.auth.updateUser(UserAttributes(password: p1));
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Kunde inte sätta lösenord: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const FloatingLinesBackground(
            enabledWaves: ['middle'],
            lineCount: [7, 9],
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
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF6EE7FF),
                                        Color(0xFF8A6DFF),
                                        Color(0xFF55F273),
                                      ],
                                    ),
                                  ),
                                  child: const Icon(Icons.lock_reset,
                                      size: 38, color: Colors.white),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Återställ lösenord',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _email ?? '',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color:
                                          cs.onSurface.withOpacity(0.75)),
                                ),
                                const SizedBox(height: 16),
                                if (_error != null) ...[
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: cs.error.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.error_outline,
                                            color: cs.error),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            _error!,
                                            style: TextStyle(
                                                color: cs.onSurfaceVariant),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                TextField(
                                  controller: _passCtrl,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      labelText: 'Nytt lösenord'),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _pass2Ctrl,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      labelText: 'Bekräfta lösenord'),
                                ),
                                const SizedBox(height: 16),
                                FilledButton(
                                  onPressed: _setPassword,
                                  child: const Text('Spara lösenord'),
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
