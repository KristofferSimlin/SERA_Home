import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sv')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SERA'**
  String get appTitle;

  /// No description provided for @beta.
  ///
  /// In en, this message translates to:
  /// **'BETA'**
  String get beta;

  /// No description provided for @startTitle.
  ///
  /// In en, this message translates to:
  /// **'SERA'**
  String get startTitle;

  /// No description provided for @startSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Service & Equipment Repair Assistant'**
  String get startSubtitle;

  /// No description provided for @startCta.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get startCta;

  /// No description provided for @startVersion.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0 • For technicians and support teams'**
  String get startVersion;

  /// No description provided for @homeAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'SERA'**
  String get homeAppBarTitle;

  /// No description provided for @homeAcademy.
  ///
  /// In en, this message translates to:
  /// **'Academy'**
  String get homeAcademy;

  /// No description provided for @homeForum.
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get homeForum;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @homeNewChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get homeNewChat;

  /// No description provided for @homeSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettings;

  /// No description provided for @homeProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get homeProfile;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search chats…'**
  String get homeSearchHint;

  /// No description provided for @homeNoChats.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get homeNoChats;

  /// No description provided for @homeRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get homeRename;

  /// No description provided for @homeDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get homeDelete;

  /// No description provided for @homeRenameDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename chat'**
  String get homeRenameDialogTitle;

  /// No description provided for @homeRenameDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new name'**
  String get homeRenameDialogHint;

  /// No description provided for @homeRenameCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get homeRenameCancel;

  /// No description provided for @homeRenameSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get homeRenameSave;

  /// No description provided for @sidebarTipsTitle1.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting – engine will not start'**
  String get sidebarTipsTitle1;

  /// No description provided for @sidebarTipsTitle2.
  ///
  /// In en, this message translates to:
  /// **'Read fault code & next steps'**
  String get sidebarTipsTitle2;

  /// No description provided for @sidebarTipsTitle3.
  ///
  /// In en, this message translates to:
  /// **'Maintenance – checklist'**
  String get sidebarTipsTitle3;

  /// No description provided for @sidebarTipsTitle4.
  ///
  /// In en, this message translates to:
  /// **'Safety advice – hydraulics'**
  String get sidebarTipsTitle4;

  /// No description provided for @homeHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'SERA is your AI assistant for heavy equipment—from troubleshooting to installation. Soon complemented by SERA Academy and a community forum where you can learn, share experience, and get help from peers.'**
  String get homeHeroDescription;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get settingsConnection;

  /// No description provided for @settingsProxyToggle.
  ///
  /// In en, this message translates to:
  /// **'Proxy mode (recommended)'**
  String get settingsProxyToggle;

  /// No description provided for @settingsProxySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hides API key and can add web search /search'**
  String get settingsProxySubtitle;

  /// No description provided for @settingsProxyUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'PROXY_URL'**
  String get settingsProxyUrlLabel;

  /// No description provided for @settingsProxyUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://api.sera.chat/api/openai-proxy'**
  String get settingsProxyUrlHint;

  /// No description provided for @settingsProxyUrlHelper.
  ///
  /// In en, this message translates to:
  /// **'Enter only the URL (not \"PROXY_URL=\").'**
  String get settingsProxyUrlHelper;

  /// No description provided for @settingsDirectKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'OPENAI_API_KEY (direct mode)'**
  String get settingsDirectKeyLabel;

  /// No description provided for @settingsDirectKeyHint.
  ///
  /// In en, this message translates to:
  /// **'sk-********'**
  String get settingsDirectKeyHint;

  /// No description provided for @settingsDirectKeyHelper.
  ///
  /// In en, this message translates to:
  /// **'Use only for local testing. Never ship key in production.'**
  String get settingsDirectKeyHelper;

  /// No description provided for @settingsProxyTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: Use proxy mode in production. Direct mode exposes the key in the client.'**
  String get settingsProxyTip;

  /// No description provided for @settingsWebSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Web search (beta)'**
  String get settingsWebSearchTitle;

  /// No description provided for @settingsWebSearchToggle.
  ///
  /// In en, this message translates to:
  /// **'Enable web search via proxy /search'**
  String get settingsWebSearchToggle;

  /// No description provided for @settingsWebSearchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Requires PROXY_SEARCH_URL in .env and /search route in proxy'**
  String get settingsWebSearchSubtitle;

  /// No description provided for @settingsWebSearchInfo.
  ///
  /// In en, this message translates to:
  /// **'When enabled, SERA fetches relevant sources (manuals, forums, technical sites) for your make/model/year and weaves findings into the answer.'**
  String get settingsWebSearchInfo;

  /// No description provided for @settingsLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// No description provided for @settingsSafetyTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get settingsSafetyTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile & data'**
  String get profileDataTitle;

  /// No description provided for @profileDataInfo.
  ///
  /// In en, this message translates to:
  /// **'Erase locally stored data (sessions, messages, equipment). Required for App Store data deletion.'**
  String get profileDataInfo;

  /// No description provided for @profileDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete stored data'**
  String get profileDelete;

  /// No description provided for @profileDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all stored data?'**
  String get profileDeleteConfirmTitle;

  /// No description provided for @profileDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This deletes local sessions, messages and equipment selections. This cannot be undone.'**
  String get profileDeleteConfirmBody;

  /// No description provided for @profileDeleteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileDeleteCancel;

  /// No description provided for @profileDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get profileDeleteConfirm;

  /// No description provided for @profileDeleteDone.
  ///
  /// In en, this message translates to:
  /// **'All local data deleted'**
  String get profileDeleteDone;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @profileComingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get profileComingSoonTitle;

  /// No description provided for @profileComingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'Here we will add login, quick equipment presets and other profile settings.'**
  String get profileComingSoonBody;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profilePrivacy;

  /// No description provided for @privacyFull.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy – SERA\n\nLast updated: 2025-11-29\nApplies to: SERA (iOS, Android and Web)\n\n1. Who is the controller?\nCompany: SimlinGroup\nAddress: Ullevivägen 45, 746 51 Bålsta\nEmail: support@sera.chat\n\nWe are responsible for processing personal data when you use SERA.\n\n2. Summary\n• SERA helps you troubleshoot equipment via chat.\n• Your chat content and equipment data (brand, model, year) go through our proxy to a third-party AI to generate answers.\n• All traffic uses HTTPS. We do not sell your personal data.\n• You can request deletion of chat logs and exercise GDPR rights (see section 11).\n\n3. What data we collect\nA. User content: Chat text, equipment fields, optional attachments.\nB. Technical/log data: IP (in server logs), timestamps, device/browser info, crash/performance data if you consent.\nC. Account data (if accounts are added): Name, email, auth data, payment info via payment partner.\nD. Support: Messages you send to support.\nWe do not collect exact geolocation. Camera/mic/notifications used only if you enable a feature that requires it.\n\n4. Why we process data (legal basis)\n• Provide service (contract).\n• Security/abuse prevention (legitimate interest).\n• Improvement/diagnostics (legitimate interest or consent).\n• Legal obligations (e.g., bookkeeping, legal claims).\n• Marketing/communication (consent only).\n\n5. How AI answers are generated\nYour message and equipment info are sent to our proxy, then to an AI provider to generate the answer.\n• We configure the provider to not use data for general model training where controls exist.\n• Provider may keep limited logs briefly to prevent abuse/ensure operation.\n• Do not share sensitive data (e.g., IDs, health info).\n\n6. Sharing\nNo selling. We may share with AI provider, infra/hosting/CDN/email/logging, payment partner, authorities if required. All under proper agreements.\n\n7. Transfers outside EU/EEA\nSome recipients may be outside EU/EEA (e.g., US). We use SCCs or equivalent safeguards.\n\n8. Retention\n• Chat content: up to 12 months or until you delete/request deletion.\n• Server logs: up to 90 days for troubleshooting/security.\n• Account data: as long as account is active, then per legal requirements. Data may be anonymized/aggregated.\n\n9. Security\nHTTPS, access controls, logging; continuous improvements.\n\n10. Cookies/local storage (Web)\nWe may use necessary cookies/localStorage/IndexedDB for settings, sessions, cache. Analytics/marketing only with consent.\n\n11. Your rights (GDPR)\nAccess, rectification, deletion, restriction, objection (legitimate interest), portability in some cases, withdraw consent. Contact support@sera.chat. Complaints to local authority/IMY.\n\n12. Children\nNot intended for children. If under 16 shared data, contact us for deletion.\n\n13. Your choices\n• Turn off crash/diagnostics (if available).\n• Clear chat in app and ask us to delete related server logs.\n• Consent dialog for AI at first use; decline limits features.\n\n14. Third-party links/sources\nLinks may appear; we are not responsible for their policies.\n\n15. Changes\nWe may update this policy; new version will be published here and major changes notified in-app/email (if available).\n\n16. Contact\nsupport@sera.chat\nPost: Ullevivägen 45, 746 51 Bålsta'**
  String get privacyFull;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @privacyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: 2025-11-29'**
  String get privacyUpdated;

  /// No description provided for @privacyApplies.
  ///
  /// In en, this message translates to:
  /// **'Applies to: SERA (iOS, Android and Web)'**
  String get privacyApplies;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'For full details, see the policy text.'**
  String get privacyBody;

  /// No description provided for @chatAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'SERA – Chat'**
  String get chatAppBarTitle;

  /// No description provided for @chatBrandLabel.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get chatBrandLabel;

  /// No description provided for @chatBrandHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Volvo, CAT, Wacker Neuson'**
  String get chatBrandHint;

  /// No description provided for @chatModelLabel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get chatModelLabel;

  /// No description provided for @chatModelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. EC250E, 320 GC'**
  String get chatModelHint;

  /// No description provided for @chatYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get chatYearLabel;

  /// No description provided for @chatYearHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2019'**
  String get chatYearHint;

  /// No description provided for @chatExpertiseLabel.
  ///
  /// In en, this message translates to:
  /// **'Expertise'**
  String get chatExpertiseLabel;

  /// No description provided for @chatExpertise1.
  ///
  /// In en, this message translates to:
  /// **'1 – Beginner'**
  String get chatExpertise1;

  /// No description provided for @chatExpertise2.
  ///
  /// In en, this message translates to:
  /// **'2 – Intermediate'**
  String get chatExpertise2;

  /// No description provided for @chatExpertise3.
  ///
  /// In en, this message translates to:
  /// **'3 – Expert'**
  String get chatExpertise3;

  /// No description provided for @chatStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Selected: {equipment}'**
  String chatStatusTitle(Object equipment);

  /// No description provided for @chatStatusNone.
  ///
  /// In en, this message translates to:
  /// **'No equipment selected yet.'**
  String get chatStatusNone;

  /// No description provided for @chatStatusLocked.
  ///
  /// In en, this message translates to:
  /// **' • Locked'**
  String get chatStatusLocked;

  /// No description provided for @chatStatusLevel.
  ///
  /// In en, this message translates to:
  /// **' • Level: {level}'**
  String chatStatusLevel(Object level);

  /// No description provided for @chatClear.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get chatClear;

  /// No description provided for @chatLock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get chatLock;

  /// No description provided for @chatSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get chatSave;

  /// No description provided for @chatInfo.
  ///
  /// In en, this message translates to:
  /// **'Information is guidance only. Follow manufacturer instructions and local safety rules. Use at your own risk.'**
  String get chatInfo;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get chatInputHint;

  /// No description provided for @chatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get chatSend;

  /// No description provided for @chatSafetyBanner.
  ///
  /// In en, this message translates to:
  /// **'Safety filter: Disconnect power, relieve pressure, ventilate when handling fuel. Use PPE. Always follow manufacturer instructions.'**
  String get chatSafetyBanner;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sv':
      return AppLocalizationsSv();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
