// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

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
import 'features/work_order/work_order_screen.dart';
import 'features/service/service_screen.dart';
import 'features/chat/general_chat_screen.dart';
import 'features/start/success_screen.dart';
import 'features/start/cancel_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Ignore missing .env in web/production; rely on runtime env or defaults.
  }
  final stripeKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
  if (stripeKey != null && stripeKey.isNotEmpty) {
    Stripe.publishableKey = stripeKey;
    Stripe.merchantIdentifier = 'sera.chat';
    await Stripe.instance.applySettings();
  }
  runApp(const ProviderScope(child: SeraApp()));
}

class SeraApp extends ConsumerWidget {
  const SeraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      title: 'SERA',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
        '/success': (_) => const SuccessScreen(),
        '/cancel': (_) => const CancelScreen(),
        '/work-order': (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments;
          String? prefill;
          bool autoGenerate = false;
          bool fromChat = false;
          if (args is Map) {
            final pf = args['prefill'];
            if (pf is String && pf.trim().isNotEmpty) {
              prefill = pf;
            }
            autoGenerate = args['autoGenerate'] == true;
            fromChat = args['fromChat'] == true;
          }
          return WorkOrderScreen(
            prefill: prefill,
            autoGenerate: autoGenerate,
            fromChat: fromChat,
          );
        },
        '/service': (_) => const ServiceScreen(),
        '/general-chat': (ctx) {
          final arg = ModalRoute.of(ctx)?.settings.arguments;
          final sid = (arg is String && arg.isNotEmpty) ? arg : 'general';
          return GeneralChatScreen(sessionId: sid);
        },
      },

      // NY: fångar /chat och ger ett stabilt sessionId (default om inget skickas)
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/chat') {
          final String sessionId = (settings.arguments is String &&
                  (settings.arguments as String).isNotEmpty)
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
