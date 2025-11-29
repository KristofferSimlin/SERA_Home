import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sera/l10n/app_localizations.dart';

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
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settingsTitle),
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
                  Text(l.settingsConnection, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.settingsProxyToggle),
                    subtitle: Text(l.settingsProxySubtitle),
                    value: settings.proxyEnabled,
                    onChanged: (v) => ref.read(settingsProvider.notifier).setProxyEnabled(v),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _proxyCtrl,
                    onChanged: (v) => ref.read(settingsProvider.notifier).setProxyUrl(v.trim()),
                    decoration: InputDecoration(
                      labelText: l.settingsProxyUrlLabel,
                      hintText: l.settingsProxyUrlHint,
                      helperText: l.settingsProxyUrlHelper,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _keyCtrl,
                    onChanged: (v) => ref.read(settingsProvider.notifier).setDirectKey(v.trim()),
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l.settingsDirectKeyLabel,
                      hintText: l.settingsDirectKeyHint,
                      helperText: l.settingsDirectKeyHelper,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l.settingsProxyTip,
                      style: const TextStyle(fontSize: 12.5),
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
                  Text(l.settingsWebSearchTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.settingsWebSearchToggle),
                    subtitle: Text(l.settingsWebSearchSubtitle),
                    value: settings.webLookupEnabled,
                    onChanged: (v) => ref.read(settingsProvider.notifier).setWebLookup(v),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.settingsWebSearchInfo,
                    style: const TextStyle(fontSize: 12.5),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.language),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: settings.localeCode,
                          decoration: InputDecoration(labelText: l.settingsLanguageLabel),
                          items: const [
                            DropdownMenuItem(value: 'sv', child: Text('Svenska')),
                            DropdownMenuItem(value: 'en', child: Text('English')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(settingsProvider.notifier).setLocale(val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.settingsSafetyTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    l.chatInfo,
                    style: const TextStyle(fontSize: 12.5),
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
