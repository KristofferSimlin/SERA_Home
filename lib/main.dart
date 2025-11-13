import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart'; // <-- lägg till

import 'theme/app_theme.dart';
import 'features/chat/chat_screen.dart';
import 'features/settings/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Viktigt: förhindra nätverkshämtning av fonter
  GoogleFonts.config.allowRuntimeFetching = false;

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
        '/': (_) => const ChatScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
      initialRoute: '/',
    );
  }
}
