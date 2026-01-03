// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

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
import 'features/start/activate_screen.dart';
import 'features/start/admin_login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'utils/auth_params.dart';

// Ta en ögonblicksbild av URL:en innan Flutter hinner skriva över fragmentet.
final Uri initialUriBeforeFlutter = Uri.base;
final Map<String, String> initialAuthParams =
    parseAuthParams(initialUriBeforeFlutter);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Använd path-baserad routing så /activate fungerar utan hash-krockar.
    setUrlStrategy(PathUrlStrategy());
  }
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Ignore missing .env in web/production; rely on runtime env or defaults.
  }
  final stripeKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
  if (!kIsWeb && stripeKey != null && stripeKey.isNotEmpty) {
    try {
      Stripe.publishableKey = stripeKey;
      Stripe.merchantIdentifier = 'sera.chat';
      await Stripe.instance.applySettings();
    } catch (e) {
      // På web kan Stripe saknas/inte laddas; svälj så appen startar ändå.
      debugPrint('Stripe init misslyckades: $e');
    }
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  if (supabaseUrl != null &&
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey != null &&
      supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase init misslyckades: $e');
    }
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
        '/admin-login': (_) => const AdminLoginScreen(),
        '/personal-pricing': (_) => const PersonalPricingScreen(),
        '/success': (_) => const SuccessScreen(),
        '/cancel': (_) => const CancelScreen(),
        '/activate': (ctx) {
          final arg = ModalRoute.of(ctx)?.settings.arguments;
          Uri? source;
          if (arg is Uri) {
            source = arg;
          } else if (arg is String) {
            source = Uri.tryParse(arg);
          }
          return ActivateScreen(sourceUri: source);
        },
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
      onGenerateInitialRoutes: (initialRouteName) {
        return _initialRoutesFromUri();
      },
    );
  }
}

List<Route<dynamic>> _initialRoutesFromUri() {
  final uri = initialUriBeforeFlutter;
  String? target;

  // Hash-strategi (Flutter web default)
  if (uri.fragment.isNotEmpty) {
    final fragPath = uri.fragment.split('?').first;
    if (fragPath.contains('/activate')) {
      target = '/activate';
    } else if (fragPath.startsWith('/')) {
      target = fragPath;
    }
  }

  // Path-strategi fallback
  if (target == null && uri.path.isNotEmpty && uri.path != '/') {
    target = uri.path.split('?').first;
  }

  // Om token/typ finns i URL:en, forcera activate även om fragmentet inte innehöll path.
  if (target == null) {
    final all = uri.toString();
    if (all.contains('token_hash=') ||
        all.contains('type=invite') ||
        all.contains('access_token=') ||
        all.contains('refresh_token=')) {
      target = '/activate';
    }
  }

  Route<dynamic> routeFor(String name) {
    return MaterialPageRoute(
      builder: (_) {
        switch (name) {
          case '/activate':
            return ActivateScreen(
              sourceUri: initialUriBeforeFlutter,
              initialParams: initialAuthParams,
            );
          case '/success':
            return const SuccessScreen();
          case '/cancel':
            return const CancelScreen();
          case '/admin-login':
            return const AdminLoginScreen();
          default:
            return const StartScreen();
        }
      },
      settings: RouteSettings(name: name, arguments: uri),
    );
  }

  switch (target) {
    case '/activate':
    case '/success':
    case '/cancel':
    case '/admin-login':
      return [routeFor(target!)];
    default:
      return [routeFor('/start')];
  }
}
