// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'theme/app_theme.dart';
import 'features/home/home_shell.dart';
import 'features/settings/settings_screen.dart';
import 'features/settings/profile_screen.dart';
import 'features/settings/privacy_policy_screen.dart';
import 'features/chat/chat_screen.dart'; // ← lägg till
import 'features/start/start_screen.dart';
import 'features/start/business_login_screen.dart';
import 'features/start/personal_pricing_screen.dart';
import 'features/settings/terms_screen.dart';
import 'features/settings/subscription_terms_screen.dart';
import 'features/chat/chat_controller.dart';
import 'package:sera/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: SeraApp()));
}

class SeraApp extends ConsumerWidget {
  const SeraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'SERA',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      locale: Locale(settings.localeCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Befintliga named routes som du redan hade
      routes: {
        '/start': (_) => const StartScreen(),
        '/': (_) => const HomeShell(),
        '/settings': (_) => const SettingsScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/privacy': (_) => const PrivacyPolicyScreen(),
        '/terms': (_) => const TermsScreen(),
        '/subscription-terms': (_) => const SubscriptionTermsScreen(),
        '/business-login': (_) => const BusinessLoginScreen(),
        '/personal-pricing': (_) => const PersonalPricingScreen(),
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

      initialRoute: '/start',
    );
  }
}
