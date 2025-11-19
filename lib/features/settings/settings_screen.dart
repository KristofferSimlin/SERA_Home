import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../chat/chat_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _proxyCtrl;
  late final TextEditingController _keyCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsProvider);
    _proxyCtrl = TextEditingController(text: s.proxyUrl ?? '');
    _keyCtrl = TextEditingController(text: s.directApiKey ?? '');
  }

  @override
  void dispose() {
    _proxyCtrl.dispose();
    _keyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inställningar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Anslutning (proxy/direkt)
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
                    subtitle: const Text('Döljer API-nyckel och kan lägga till webbsök /search'),
                    value: settings.proxyEnabled,
                    onChanged: (v) => ref.read(settingsProvider.notifier).setProxyEnabled(v),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _proxyCtrl,
                    onChanged: (v) => ref.read(settingsProvider.notifier).setProxyUrl(v.trim()),
                    decoration: const InputDecoration(
                      labelText: 'PROXY_URL',
                      hintText: 'http://127.0.0.1:8080/chat',
                      helperText: 'Ange ENDAST URL:en (inte "PROXY_URL=" framför).',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _keyCtrl,
                    onChanged: (v) => ref.read(settingsProvider.notifier).setDirectKey(v.trim()),
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'OPENAI_API_KEY (direktläge)',
                      hintText: 'sk-********',
                      helperText: 'Använd bara för lokal test. Lägg aldrig nyckeln i produktion.',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Tips: Kör proxy-läge i produktion. Direktläge exponerar nyckeln i klienten.',
                      style: TextStyle(fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Webbsök (beta)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Webbsök (beta)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Aktivera webbsök via proxy /search'),
                    subtitle: const Text('Kräver PROXY_SEARCH_URL i .env och route /search i proxyn'),
                    value: settings.webLookupEnabled,
                    onChanged: (v) => ref.read(settingsProvider.notifier).setWebLookup(v),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'När detta är på försöker SERA hämta relevanta källor (manualer, forum, tekniska sidor) '
                    'för ditt märke/modell/årsmodell och väver in fynden i svaret.',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ),

          // Info
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Säkerhet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text(
                    'Informationen är vägledande. Följ alltid tillverkarens instruktioner och lokala säkerhetsregler. Egen risk.',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
