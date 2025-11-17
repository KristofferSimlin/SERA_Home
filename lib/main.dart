import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'features/home/home_shell.dart';
import 'features/settings/settings_screen.dart';

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
      routes: {
        '/': (_) => const HomeShell(),
        '/settings': (_) => const SettingsScreen(),
      },
      initialRoute: '/',
    );
  }
}

