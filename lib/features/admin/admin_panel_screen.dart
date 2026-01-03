import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../services/supabase_client.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  bool _loading = true;
  String? _error;
  int _seatsTotal = 0;
  int _seatsClaimed = 0;
  final _inviteEmailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _inviteEmailCtrl.dispose();
    super.dispose();
  }

  String get _apiBase =>
      dotenv.env['INVITE_API_BASE_URL'] ??
      dotenv.env['STRIPE_BACKEND_URL'] ??
      'https://api.sera.chat/api';

  Future<void> _load() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
        _error = 'Ingen inloggad användare.';
      });
      return;
    }
    final role = user.appMetadata['role']?.toString();
    if (role != 'admin') {
      setState(() {
        _loading = false;
        _error = 'Endast admin har åtkomst till denna sida.';
      });
      return;
    }
    final total = user.appMetadata['seats_total'];
    final claimed = user.appMetadata['seats_claimed'];
    setState(() {
      _seatsTotal = total is int ? total : int.tryParse('$total') ?? 0;
      _seatsClaimed = claimed is int ? claimed : int.tryParse('$claimed') ?? 0;
      _loading = false;
      _error = null;
    });
  }

  Future<void> _inviteUser() async {
    final email = _inviteEmailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ange e-post att bjuda in')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final session = supabase.auth.currentSession;
      final adminEmail = session?.user.email ?? '';
      final accessToken = session?.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        throw 'Ingen giltig session; logga in igen.';
      }
      final url = Uri.parse('$_apiBase/invite-user');
      final resp = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'adminEmail': adminEmail,
          'email': email,
          'role': 'user',
        }),
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        setState(() {
          _seatsClaimed = (_seatsClaimed + 1).clamp(0, _seatsTotal);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inbjudan skickad')),
        );
      } else {
        throw 'Misslyckades (${resp.statusCode}): ${resp.body}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte bjuda in: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final remaining = (_seatsTotal - _seatsClaimed).clamp(0, _seatsTotal);
    return Scaffold(
      appBar: AppBar(title: const Text('Adminpanel')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!,
                                  style: TextStyle(color: cs.error)),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _load,
                                child: const Text('Försök igen'),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Licenser',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              Text('Totalt: $_seatsTotal'),
                              Text('Använda: $_seatsClaimed'),
                              Text('Kvar: $remaining'),
                              const SizedBox(height: 20),
                              Text(
                                'Invite user',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _inviteEmailCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'E-postadress',
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _inviteUser,
                                child: const Text('Skicka inbjudan'),
                              ),
                            ],
                          ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
