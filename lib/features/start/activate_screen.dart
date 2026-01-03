import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/supabase_client.dart';

class ActivateScreen extends StatefulWidget {
  const ActivateScreen({super.key, this.sourceUri});

  final Uri? sourceUri;

  @override
  State<ActivateScreen> createState() => _ActivateScreenState();
}

class _ActivateScreenState extends State<ActivateScreen> {
  bool _loading = true;
  bool _needsPassword = false;
  String? _email;
  String? _error;
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

  Future<void> _handleInvite() async {
    final uri = widget.sourceUri ?? Uri.base;
    if (!isSupabaseReady()) {
      setState(() {
        _loading = false;
        _error =
            'Aktiveringssidan är inte konfigurerad (SUPABASE_URL/ANON_KEY saknas).';
      });
      return;
    }
    final qp = Map<String, String>.from(uri.queryParameters);
    if (qp.isEmpty && uri.fragment.isNotEmpty) {
      try {
        // Hantera både "/activate?..." och "/activate#access_token=..."
        String frag = uri.fragment.startsWith('/')
            ? uri.fragment.substring(1)
            : uri.fragment;
        // Om det finns en extra hash (#) efter path, plocka ut den sista delen
        if (frag.contains('#')) {
          frag = frag.split('#').last;
        }
        final fragPathAndQuery = frag.split('?');
        if (fragPathAndQuery.length > 1) {
          qp.addAll(Uri.splitQueryString(fragPathAndQuery.sublist(1).join('?')));
        } else if (frag.contains('=')) {
          qp.addAll(Uri.splitQueryString(frag));
        }
      } catch (_) {}
    }
    final error = qp['error'];
    if (error != null && error.isNotEmpty) {
      setState(() {
        _loading = false;
        _error = 'Länken är ogiltig eller utgången: $error';
      });
      return;
    }
    // Access/refresh tokens direkt i URL (vanligt efter verifiering)
    final access = qp['access_token'];
    final refresh = qp['refresh_token'];
    if (access != null && refresh != null) {
      try {
        await supabase.auth.getSessionFromUrl(uri);
        final user = supabase.auth.currentUser;
        setState(() {
          _email = user?.email;
          _loading = false;
          _needsPassword = true;
        });
        return;
      } catch (e) {
        setState(() {
          _loading = false;
          _error = 'Kunde inte sätta session: $e';
        });
        return;
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
    final p1 = _passCtrl.text.trim();
    final p2 = _pass2Ctrl.text.trim();
    if (p1.isEmpty || p1.length < 8) {
      setState(() => _error = 'Lösenordet måste vara minst 8 tecken.');
      return;
    }
    if (p1 != p2) {
      setState(() => _error = 'Lösenorden matchar inte.');
      return;
    }
    setState(() => _loading = true);
    try {
      await supabase.auth.updateUser(UserAttributes(password: p1));
      if (!mounted) return;
      _goDashboard();
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Kunde inte sätta lösenord: $e';
      });
    }
  }

  void _goDashboard() {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Aktivera konto')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: _buildBody(cs),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme cs) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Aktivering misslyckades',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => launchUrl(Uri.parse('mailto:support@sera.chat')),
            child: const Text('Kontakta support'),
          )
        ],
      );
    }

    if (_needsPassword) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _error!,
                style: TextStyle(color: cs.error),
              ),
            ),
          FilledButton(
            onPressed: _setPassword,
            child: const Text('Aktivera konto'),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
        const SizedBox(height: 10),
        const Text('Kontot är aktiverat!'),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _goDashboard,
          child: const Text('Fortsätt'),
        ),
      ],
    );
  }
}
