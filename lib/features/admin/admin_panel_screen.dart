import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../services/supabase_client.dart';
import '../start/widgets/floating_lines_background.dart';

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
  List<Map<String, dynamic>> _users = [];
  bool _busyDanger = false;
  final _inviteEmailCtrl = TextEditingController();
  final Map<int, TextEditingController> _slotCtrls = {};
  final _seatsCtrl = TextEditingController();
  String _proration = 'create_prorations';
  String? _selectedUserIdForRemoval;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _inviteEmailCtrl.dispose();
    for (final c in _slotCtrls.values) {
      c.dispose();
    }
    _seatsCtrl.dispose();
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
    // Hämta aktuella seats + users från backend
    try {
      final access = supabase.auth.currentSession?.accessToken;
      final resp = await http.get(
        Uri.parse('$_apiBase/admin-users'),
        headers: {
          'Authorization': 'Bearer $access',
        },
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        setState(() {
          _seatsTotal =
              int.tryParse('${data['seats_total']}') ?? (total is int ? total : 0);
          _seatsClaimed =
              int.tryParse('${data['seats_claimed']}') ?? (claimed is int ? claimed : 0);
          _users =
              (data['users'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
          _seatsCtrl.text = _seatsTotal.toString();
          final remaining = (_seatsTotal - _seatsClaimed).clamp(0, _seatsTotal);
          // Se till att vi har controllers för tomma slots
          for (int i = 0; i < remaining; i++) {
            _slotCtrls.putIfAbsent(i, () => TextEditingController());
          }
          _selectedUserIdForRemoval =
              _users.isNotEmpty ? _users.first['id']?.toString() : null;
          _loading = false;
          _error = null;
        });
      } else {
        throw 'Misslyckades att hämta admin users (${resp.statusCode})';
      }
    } catch (e) {
      setState(() {
        _seatsTotal = total is int ? total : int.tryParse('$total') ?? 0;
        _seatsClaimed =
            claimed is int ? claimed : int.tryParse('$claimed') ?? 0;
        _error = 'Kunde inte hämta användare: $e';
        _loading = false;
      });
    }
  }

  Future<bool> _inviteUserEmail(String email, {String role = 'user'}) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ange e-post att bjuda in')),
      );
      return false;
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
          'role': role,
        }),
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inbjudan skickad')),
        );
        await _load();
        // Töm eventuella tomma fält som användes
        for (final c in _slotCtrls.values) {
          c.clear();
        }
        return true;
      } else {
        throw 'Misslyckades (${resp.statusCode}): ${resp.body}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte bjuda in: $e')),
      );
      return false;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _inviteUser() async {
    await _inviteUserEmail(_inviteEmailCtrl.text.trim());
  }

  Future<void> _promptUpdateEmail(Map<String, dynamic> user) async {
    final ctrl = TextEditingController(text: user['email']?.toString() ?? '');
    final newEmail = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Byt e-post'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: 'Ny e-post'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Avbryt')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Spara'),
            ),
          ],
        );
      },
    );
    if (newEmail == null || newEmail.isEmpty) return;
    setState(() => _loading = true);
    try {
      final access = supabase.auth.currentSession?.accessToken;
      final resp = await http.post(
        Uri.parse('$_apiBase/admin-users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $access',
        },
        body: jsonEncode({
          'action': 'updateEmail',
          'userId': user['id'],
          'email': newEmail,
          'sendInvite': true,
        }),
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-post uppdaterad')),
        );
        await _load();
      } else {
        throw 'Misslyckades (${resp.statusCode}): ${resp.body}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte uppdatera e-post: $e')),
      );
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ta bort användare'),
        content: Text(
            'Vill du ta bort ${user['email'] ?? 'användaren'}? Detta kan inte ångras.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Avbryt')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ta bort'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _loading = true);
    try {
      final access = supabase.auth.currentSession?.accessToken;
      final resp = await http.post(
        Uri.parse('$_apiBase/admin-users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $access',
        },
        body: jsonEncode({
          'action': 'deleteUser',
          'userId': user['id'],
        }),
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Användare borttagen')),
        );
        await _load();
      } else {
        throw 'Misslyckades (${resp.statusCode}): ${resp.body}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte ta bort: $e')),
      );
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteAdmin() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ta bort organisation'),
        content: const Text(
            'Detta tar bort alla seats, användare och försöker avsluta Stripe-prenumerationen. Är du säker?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Avbryt')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ta bort allt'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _busyDanger = true);
    try {
      final access = supabase.auth.currentSession?.accessToken;
      final resp = await http.post(
        Uri.parse('$_apiBase/admin-users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $access',
        },
        body: jsonEncode({
          'action': 'deleteAdmin',
          'confirm': true,
        }),
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        await supabase.auth.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Organisation raderad')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/start', (r) => false);
      } else {
        throw 'Misslyckades (${resp.statusCode}): ${resp.body}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte radera: $e')),
      );
      setState(() => _busyDanger = false);
    }
  }

  Future<void> _updateSeats() async {
    final desired = int.tryParse(_seatsCtrl.text.trim());
    if (desired == null || desired <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ange ett giltigt antal seats')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final access = supabase.auth.currentSession?.accessToken;
      final resp = await http.post(
        Uri.parse('$_apiBase/subscription-seats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $access',
        },
        body: jsonEncode({
          'desiredSeats': desired,
          'prorationBehavior': _proration,
        }),
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seats uppdaterade')),
        );
        await _load();
      } else {
        throw 'Misslyckades (${resp.statusCode}): ${resp.body}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte uppdatera seats: $e')),
      );
      setState(() => _loading = false);
    }
  }

  Future<void> _sendResetLink(Map<String, dynamic> user) async {
    final email = user['email']?.toString() ?? '';
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-post saknas för denna användare')),
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
        SnackBar(content: Text('Återställningslänk skickad till $email')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kunde inte skicka länk: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final remaining = (_seatsTotal - _seatsClaimed).clamp(0, _seatsTotal);
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
                constraints: const BoxConstraints(maxWidth: 700),
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                              : SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 64,
                                            height: 64,
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
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: const [
                                                Icon(Icons.person_outline,
                                                    size: 32, color: Colors.white),
                                                Positioned(
                                                  right: 8,
                                                  bottom: 8,
                                                  child: CircleAvatar(
                                                    radius: 10,
                                                    backgroundColor: Colors.white,
                                                    child: Icon(
                                                      Icons.add,
                                                      size: 14,
                                                      color: Color(0xFF0E121A),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Adminpanel',
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 16),
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
                                      const SizedBox(height: 12),
                                      Text(
                                        'Ändra seats',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _seatsCtrl,
                                              keyboardType: TextInputType.number,
                                              decoration: const InputDecoration(
                                                labelText: 'Önskat antal seats',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          DropdownButton<String>(
                                            value: _proration,
                                            items: const [
                                              DropdownMenuItem(
                                                value: 'create_prorations',
                                                child: Text('Proratera'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'none',
                                                child: Text('Ingen proration'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'always_invoice',
                                                child: Text('Fakturera nu'),
                                              ),
                                            ],
                                            onChanged: (v) {
                                              if (v != null) {
                                                setState(() => _proration = v);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: _updateSeats,
                                        child: const Text('Uppdatera seats'),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'Användare',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 8),
                                      if (_users.isEmpty)
                                        const Text('Inga användare')
                                      else
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: _users.length,
                                          separatorBuilder: (_, __) =>
                                              const Divider(height: 1),
                                          itemBuilder: (_, i) {
                                            final u = _users[i] as Map<String, dynamic>;
                                            return ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: const Icon(Icons.person_outline),
                                              title: Text(u['email']?.toString() ?? ''),
                                              subtitle: Text(
                                                  'Roll: ${u['role'] ?? ''}  •  Id: ${u['id'] ?? ''}'),
                                              trailing: Wrap(
                                                spacing: 8,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit),
                                                    tooltip: 'Byt e-post',
                                                    onPressed: () => _promptUpdateEmail(u),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.lock_reset),
                                                    tooltip: 'Skicka återställningslänk',
                                                    onPressed: () => _sendResetLink(u),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete_outline),
                                                    tooltip: 'Ta bort användare',
                                                    onPressed: () => _deleteUser(u),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      const SizedBox(height: 12),
                                      if ((_seatsTotal - _seatsClaimed) > 0) ...[
                                        Text(
                                          'Tomma licenser',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 8),
                                        Column(
                                          children: List.generate(
                                            (_seatsTotal - _seatsClaimed)
                                                .clamp(0, _seatsTotal),
                                            (i) {
                                              final ctrl = _slotCtrls[i]!;
                                              return Padding(
                                                padding: const EdgeInsets.only(bottom: 8),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextField(
                                                        controller: ctrl,
                                                        decoration:
                                                            InputDecoration(labelText: 'E-post (plats ${i + 1})'),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          _inviteUserEmail(ctrl.text.trim()),
                                                      child: const Text('Bjud in'),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 24),
                                      Divider(color: cs.onSurfaceVariant.withOpacity(0.3)),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Farliga åtgärder',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: cs.error),
                                      ),
                                      const SizedBox(height: 8),
                                      if (_users.isNotEmpty) ...[
                                        DropdownButton<String>(
                                          value: _selectedUserIdForRemoval,
                                          hint: const Text('Välj användare att ta bort'),
                                          items: _users
                                              .map((u) => DropdownMenuItem<String>(
                                                    value: u['id']?.toString(),
                                                    child: Text(u['email']?.toString() ?? u['id']?.toString() ?? ''),
                                                  ))
                                              .toList(),
                                          onChanged: (v) {
                                            setState(() => _selectedUserIdForRemoval = v);
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: cs.error.withOpacity(0.15),
                                          ),
                                          onPressed: () {
                                            final u = _users.firstWhere(
                                                (u) => u['id']?.toString() == _selectedUserIdForRemoval,
                                                orElse: () => <String, dynamic>{});
                                            if (u.isNotEmpty) {
                                              _deleteUser(u);
                                            }
                                          },
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                          label: const Text('Ta bort vald användare'),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: cs.error,
                                          foregroundColor: cs.onError,
                                        ),
                                        onPressed: _busyDanger ? null : _deleteAdmin,
                                        icon: const Icon(Icons.warning_amber_outlined),
                                        label: const Text('Ta bort organisation'),
                                      ),
                                    ],
                                  ),
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
