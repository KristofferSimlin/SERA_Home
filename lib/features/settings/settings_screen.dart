import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../chat/chat_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _proxyCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();

  @override
  void dispose() {
    _proxyCtrl.dispose();
    _keyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    _proxyCtrl.text = settings.proxyUrl ?? '';
    _keyCtrl.text = settings.directApiKey ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Inställningar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Anslutning', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Proxy-läge (rekommenderas)'),
                    subtitle: const Text('Döljer servernycklar. Använd i produktion.'),
                    value: settings.proxyEnabled,
                    onChanged: (v) => ref.read(settingsProvider.notifier).setProxyEnabled(v),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _proxyCtrl,
                    onChanged: (v) => ref.read(settingsProvider.notifier).setProxyUrl(v),
                    decoration: const InputDecoration(
                      labelText: 'PROXY_URL (ex. https://din-proxy.example/chat)',
                      hintText: 'https://…/chat',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Direktläge (endast lokal test)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text(
                    'Varning: Lägg aldrig API-nycklar i produktionsklient. Detta fält är endast för lokal utveckling.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _keyCtrl,
                    onChanged: (v) => ref.read(settingsProvider.notifier).setDirectKey(v),
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'OPENAI_API_KEY (lokal dev)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Inställningar uppdaterade')),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
            label: const Text('Spara'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tips: Du kan även fylla .env för defaultvärden. Runtime-inmatning här sparas endast i minnet för demo.',
            style: TextStyle(fontSize: 12.5, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
