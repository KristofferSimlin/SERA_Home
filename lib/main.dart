// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'theme/app_theme.dart';
import 'features/home/home_shell.dart';
import 'features/settings/settings_screen.dart';
import 'features/chat/chat_screen.dart'; // ← lägg till

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: SeraApp()));
}

class SeraApp extends StatelessWidget {
  const SeraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SERA',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,

      // Befintliga named routes som du redan hade
      routes: {
        '/': (_) => const HomeShell(),
        '/settings': (_) => const SettingsScreen(),
      },

      // NY: fångar /chat och ger ett stabilt sessionId (default om inget skickas)
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/chat') {
          final String sessionId =
              (settings.arguments is String && (settings.arguments as String).isNotEmpty)
                  ? settings.arguments as String
                  : 'default'; // ← stabilt id om inget anges

          return MaterialPageRoute(
            builder: (_) => ChatScreen(sessionId: sessionId),
            settings: settings,
          );
        }
        return null; // låt övriga routes hanteras av 'routes' ovan
      },

      initialRoute: '/',
    );
  }
}
