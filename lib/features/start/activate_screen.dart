import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html;

import '../../services/supabase_client.dart';
import '../../utils/auth_params.dart';
import 'widgets/floating_lines_background.dart';

class ActivateScreen extends StatefulWidget {
  const ActivateScreen({super.key, this.sourceUri, this.initialParams});

  final Uri? sourceUri;
  final Map<String, String>? initialParams;

  @override
  State<ActivateScreen> createState() => _ActivateScreenState();
}

class _ActivateScreenState extends State<ActivateScreen> {
  bool _loading = true;
  bool _needsPassword = false;
  String? _email;
  String? _error;
  Map<String, String> _lastParams = {};
  String? _storedRefresh;
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _handleInvite();
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  void _persistRefreshFromSession() {
    if (!kIsWeb) return;
    final token = supabase.auth.currentSession?.refreshToken;
    if (token != null && token.isNotEmpty) {
      html.window.localStorage['sera_refresh_token'] = token;
      _storedRefresh = token;
    }
  }

  Future<void> _handleInvite() async {
    if (kIsWeb) {
      _storedRefresh = html.window.localStorage['sera_refresh_token'];
    }
    if (_storedRefresh != null && _storedRefresh!.isNotEmpty) {
      try {
        final resp = await supabase.auth.setSession(_storedRefresh!);
        if (resp.session != null) {
          _persistRefreshFromSession();
          setState(() {
            _email = resp.session!.user.email;
            _loading = false;
            _needsPassword = true;
          });
          return;
        }
      } catch (_) {
        // fortsätt; kanske ogiltig
      }
    }

    final uri = widget.sourceUri ?? Uri.base;
    final fallbackParams = widget.initialParams ?? const {};
    debugPrint('activate uri: $uri');
    if (kIsWeb) {
      debugPrint('activate href: ${html.window.location.href}');
      debugPrint('activate hash: ${html.window.location.hash}');
    }
    if (!isSupabaseReady()) {
      setState(() {
        _loading = false;
        _error =
            'Aktiveringssidan är inte konfigurerad (SUPABASE_URL/ANON_KEY saknas).';
      });
      return;
    }

    // Försök direkt med Supabase-helper om hela redirect-URL:en innehåller tokens.
    try {
      final fallbackUri = uri.fragment.contains('access_token=')
          ? Uri.parse(
            '${uri.scheme}://${uri.host}${uri.path}?${uri.fragment}',
          )
          : uri;
      final res = await supabase.auth.getSessionFromUrl(fallbackUri);
      if (res.session != null) {
        _persistRefreshFromSession();
        setState(() {
          _email = res.session!.user.email;
          _loading = false;
          _needsPassword = true;
        });
        return;
      }
    } catch (_) {
      // fortsätt till manuell parsning nedan
    }
    var qp = parseAuthParams(uri);
    if (qp.isEmpty && kIsWeb) {
      final storedHref = html.window.sessionStorage['sera_auth_href'];
      final storedFrag = html.window.sessionStorage['sera_auth_fragment'];
      if ((storedHref != null && storedHref.isNotEmpty) ||
          (storedFrag != null && storedFrag.isNotEmpty)) {
        final storedUri = storedHref != null && storedHref.isNotEmpty
            ? Uri.parse(storedHref)
            : Uri.parse('${uri.toString()}$storedFrag');
        qp = parseAuthParams(storedUri);
        debugPrint('activate using sessionStorage params: $qp');
      }
    }
    if (qp.isEmpty && fallbackParams.isNotEmpty) {
      qp = Map<String, String>.from(fallbackParams);
      debugPrint('activate using initial params snapshot');
    }
    debugPrint('activate parsed params: $qp');
    _lastParams = qp;
    final refreshFromParams = qp['refresh_token'];
    if (kIsWeb && refreshFromParams != null && refreshFromParams.isNotEmpty) {
      html.window.localStorage['sera_refresh_token'] = refreshFromParams;
      _storedRefresh = refreshFromParams;
    }
    final error = qp['error'];
    if (error != null && error.isNotEmpty) {
      setState(() {
        _loading = false;
        _error = 'Länken är ogiltig eller utgången: $error';
      });
      return;
    }
    // Access/refresh tokens direkt i fragment (vanligt efter verifiering)
    final refresh = qp['refresh_token'];
    if (refresh != null) {
      try {
        final resp = await supabase.auth.setSession(refresh);
        if (resp.session == null) {
          throw 'Session saknas';
        }
        _persistRefreshFromSession();
        final user = resp.session!.user;
        setState(() {
          _email = user.email;
          _loading = false;
          _needsPassword = true;
        });
        return;
      } catch (e) {
        // Rensa ev. trasig refresh_token och fortsätt till token_hash-flödet.
        if (kIsWeb) {
          html.window.localStorage.remove('sera_refresh_token');
        }
        _storedRefresh = null;
      }
    }

    // Magic link / invite token
    final token = qp['token_hash'] ?? qp['token'];
    final type = qp['type'] ?? 'invite';
    if (token == null || token.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Ogiltig eller saknad token.';
      });
      return;
    }
    try {
      await supabase.auth.exchangeCodeForSession(token);
      _persistRefreshFromSession();
      final user = supabase.auth.currentUser;
      setState(() {
        _email = user?.email;
        _loading = false;
        _needsPassword = true;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Kunde inte aktivera länken: $e';
      });
    }
  }

  Future<void> _setPassword() async {
    Future<bool> _ensureSession() async {
      if (supabase.auth.currentSession != null) {
        _persistRefreshFromSession();
        return true;
      }
      final refresh = _lastParams['refresh_token'] ?? _storedRefresh;
      if (refresh != null && refresh.isNotEmpty) {
        try {
          final resp = await supabase.auth.setSession(refresh);
          if (resp.session != null) {
            _persistRefreshFromSession();
            return true;
          }
        } catch (_) {
          if (kIsWeb) {
            html.window.localStorage.remove('sera_refresh_token');
          }
          _storedRefresh = null;
        }
      }
      final token = _lastParams['token_hash'] ?? _lastParams['token'];
      if (token != null && token.isNotEmpty) {
        try {
          await supabase.auth.exchangeCodeForSession(token);
          if (supabase.auth.currentSession != null) {
            _persistRefreshFromSession();
            return true;
          }
        } catch (_) {}
      }
      return false;
    }

    final p1 = _passCtrl.text.trim();
    final p2 = _pass2Ctrl.text.trim();
    setState(() {
      _error = null;
    });
    if (p1.isEmpty || p1.length < 8) {
      setState(() {
        _error = 'Lösenordet måste vara minst 8 tecken.';
        _loading = false;
      });
      _passCtrl.clear();
      _pass2Ctrl.clear();
      return;
    }
    if (p1 != p2) {
      setState(() {
        _error = 'Lösenorden matchar inte.';
        _loading = false;
      });
      _passCtrl.clear();
      _pass2Ctrl.clear();
      return;
    }
    final hasSession = await _ensureSession();
    if (!hasSession) {
      setState(() {
        _error =
            'Session saknas eller har löpt ut. Öppna aktiveringslänken igen för att fortsätta.';
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    try {
      await supabase.auth.updateUser(UserAttributes(password: p1));
      if (!mounted) return;
      if (kIsWeb) {
        html.window.localStorage.remove('sera_refresh_token');
      }
      _goDashboard();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Kunde inte sätta lösenord: $e';
      });
      _passCtrl.clear();
      _pass2Ctrl.clear();
    }
  }

  void _goDashboard() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
                constraints: const BoxConstraints(maxWidth: 540),
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
                                  Color(0xFF6EE7FF),
                                  Color(0xFF8A6DFF),
                                  Color(0xFF55F273),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(Icons.lock_outline,
                                size: 38, color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Aktivera konto',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ställ in ditt lösenord för att komma igång.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: cs.onSurface.withOpacity(0.75)),
                          ),
                          const SizedBox(height: 16),
                          _buildBody(cs),
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

  Widget _buildBody(ColorScheme cs) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, color: cs.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aktivering misslyckades',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: cs.error),
                      ),
                      const SizedBox(height: 4),
                      Text(_error!,
                          style: TextStyle(color: cs.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children: [
                          TextButton(
                            onPressed: () => _handleInvite(),
                            child: const Text('Försök igen'),
                          ),
                          TextButton(
                            onPressed: () =>
                                launchUrl(Uri.parse('mailto:support@sera.chat')),
                            child: const Text('Kontakta support'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (_needsPassword) ...[
          _buildPasswordForm(cs),
        ] else ...[
          const Icon(Icons.check_circle_outline,
              size: 48, color: Colors.green),
          const SizedBox(height: 10),
          const Text('Kontot är aktiverat!'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _goDashboard,
            child: const Text('Fortsätt'),
          ),
        ]
      ],
    );
  }

  Widget _buildPasswordForm(ColorScheme cs) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        Text(
          'Välj lösenord',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          _email ?? '',
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passCtrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Lösenord'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _pass2Ctrl,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Bekräfta lösenord'),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: _setPassword,
          child: const Text('Aktivera konto'),
        ),
      ],
    );
  }
}
