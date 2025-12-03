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
  /// **'Enter'**
  String get startCta;

  /// No description provided for @startLoginBusiness.
  ///
  /// In en, this message translates to:
  /// **'Log in - business'**
  String get startLoginBusiness;

  /// No description provided for @startLoginPersonal.
  ///
  /// In en, this message translates to:
  /// **'Log in - personal'**
  String get startLoginPersonal;

  /// No description provided for @businessLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Business login'**
  String get businessLoginTitle;

  /// No description provided for @businessLoginBody.
  ///
  /// In en, this message translates to:
  /// **'Licenses are purchased separately. Use your company login link or SSO. If you need help, contact your administrator.'**
  String get businessLoginBody;

  /// No description provided for @businessLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Continue to log in'**
  String get businessLoginButton;

  /// No description provided for @businessLoginUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get businessLoginUsername;

  /// No description provided for @businessLoginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get businessLoginPassword;

  /// No description provided for @businessLoginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get businessLoginSubmit;

  /// No description provided for @businessLoginFooter.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account? Contact your admin.'**
  String get businessLoginFooter;

  /// No description provided for @personalPricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal access'**
  String get personalPricingTitle;

  /// No description provided for @personalPricingBody.
  ///
  /// In en, this message translates to:
  /// **'Personal users subscribe via App Store or Google Play. If you have already logged in on this device, you\'ll go straight into the app.'**
  String get personalPricingBody;

  /// No description provided for @personalPricingTrial.
  ///
  /// In en, this message translates to:
  /// **'7-day free trial, then 29/month.'**
  String get personalPricingTrial;

  /// No description provided for @personalPricingSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Start 7 days free – 29/month'**
  String get personalPricingSubscribe;

  /// No description provided for @personalPricingOpenApp.
  ///
  /// In en, this message translates to:
  /// **'I’ve already purchased – open the app'**
  String get personalPricingOpenApp;

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

  /// No description provided for @homeCardTroubleshootingTitle.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting'**
  String get homeCardTroubleshootingTitle;

  /// No description provided for @homeCardTroubleshootingBadge.
  ///
  /// In en, this message translates to:
  /// **'TROUBLESHOOTING'**
  String get homeCardTroubleshootingBadge;

  /// No description provided for @homeCardTroubleshootingBody.
  ///
  /// In en, this message translates to:
  /// **'SERA helps you quickly identify faults in heavy equipment with AI-powered analysis.\nDescribe symptoms, get suggested causes and step-by-step fixes.\nPerfect for field techs and mechanics who need answers fast.\nAlways available and up to date.'**
  String get homeCardTroubleshootingBody;

  /// No description provided for @homeCardMaintenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get homeCardMaintenanceTitle;

  /// No description provided for @homeCardMaintenanceBadge.
  ///
  /// In en, this message translates to:
  /// **'MAINTENANCE'**
  String get homeCardMaintenanceBadge;

  /// No description provided for @homeCardMaintenanceBody.
  ///
  /// In en, this message translates to:
  /// **'Clear instructions for service, inspections and planned maintenance.\nSERA guides you through the right intervals, recommended actions and common issues.\nLess guesswork, more structure.\nHelps you keep machines reliable longer.'**
  String get homeCardMaintenanceBody;

  /// No description provided for @homeCardTrainingTitle.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get homeCardTrainingTitle;

  /// No description provided for @homeCardTrainingBadge.
  ///
  /// In en, this message translates to:
  /// **'TRAINING'**
  String get homeCardTrainingBadge;

  /// No description provided for @homeCardTrainingBody.
  ///
  /// In en, this message translates to:
  /// **'SERA Academy offers guides, training and easy-to-read material.\nLearn functions, systems, installations and safety procedures.\nPerfect for new technicians or anyone leveling up skills.\nEverything collected in one simple digital format.'**
  String get homeCardTrainingBody;

  /// No description provided for @homeCardCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get homeCardCommunityTitle;

  /// No description provided for @homeCardCommunityBadge.
  ///
  /// In en, this message translates to:
  /// **'COMMUNITY'**
  String get homeCardCommunityBadge;

  /// No description provided for @homeCardCommunityBody.
  ///
  /// In en, this message translates to:
  /// **'A forum where technicians, operators and enthusiasts share knowledge and experience.\nAsk questions, discuss fixes and help others in the industry.\nBuilds a strong community around SERA and heavy equipment.\nA place to learn, get inspired and grow together.'**
  String get homeCardCommunityBody;

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

  /// No description provided for @privacyFull.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy – SERA\n\nLast updated: 2025-11-29\nApplies to: SERA (iOS, Android and Web)\n\n1. Who is the controller?\n\nCompany: SimlinGroup\nAddress: Ullevivägen 45, 746 51 Bålsta\nEmail: support@sera.chat\n\nWe are responsible for processing personal data when you use SERA.\n\n2. Summary\n• SERA helps you troubleshoot equipment and provides chat functionality.\n• Your chat content and equipment data (e.g., brand, model, year) go via our server (\"proxy\") to a third-party AI provider that uses data from our own knowledge library to generate answers.\n• All traffic uses HTTPS. We do not sell your personal data.\n• You can request deletion of chat logs and exercise GDPR rights (see section 11).\n\n3. What data we collect\n\nDepending on how you use SERA, we may process these categories:\n\nA. User content\n• Text you enter in chat, selected equipment fields (brand, model, year), any attached images/notes.\n\nB. Technical data & logs\n• IP address (in server logs), timestamps, device/browser info (for troubleshooting and security).\n• Crash and performance data if you consent in the app.\n\nC. Account data (if accounts are introduced)\n• Name, email, authentication details, payment-related data (handled via payment partner).\n\nD. Support\n• Messages you send to support and related correspondence.\n\nWe do not collect exact geolocation. Camera access, microphone, notifications, etc. are used only if you explicitly enable such a feature.\n\n4. Why we process data (purpose and legal basis)\n• Deliver the service (contract): Generate answers and troubleshooting steps, store history for you, show sources.\n• Security & abuse prevention (legitimate interest): Detect spam/abuse, protect the system.\n• Improvement & diagnostics (legitimate interest or consent): Performance, crash logs, quality follow-up.\n• Legal obligations: e.g., bookkeeping, handling legal claims.\n• Marketing/communication (consent): Only if you actively agree.\n\n5. How AI answers are generated and how SERA’s knowledge library is used\n\nWhen you use chat, your message and any equipment info are sent to our server/proxy. The proxy forwards necessary content to a third-party AI provider to generate an answer. To improve quality and precision, SERA also uses its own curated knowledge library (\"SERA’s library\").\n\nHow it works (RAG):\n• 1) Your question: Your chat content and selected equipment fields (brand, model, year) are received by our server.\n• 2) Search SERA’s library: Our server searches for relevant excerpts in SERA’s library (e.g., manuals, service bulletins, safety notices, technical facts we are allowed to use).\n• 3) Minimal sharing: Only the necessary excerpts plus your question (and equipment fields) are sent to the AI provider to generate the answer. We do not send entire documents unless needed to fulfill your request.\n• 4) Answer + sources: The AI answer is returned to the app, often with citations to the library sources used.\n\nAbout SERA’s library:\n• Owned and maintained by SERA; contains content we are allowed to use (own, licensed, or legally permitted).\n• Does not contain your personal data. Individual chat content is not added to the library, except possibly in aggregated/anonymized form to improve coverage and quality.\n• The library can be stored and updated independently of your app installation (so you get improvements without updating the app).\n\nThird-party AI provider:\n• Configured so data is not used for general model training where such controls exist.\n• May retain limited logs for a short time to prevent abuse and ensure operation.\n• All communication uses HTTPS.\n\nYour control:\n• Do not share sensitive personal data (e.g., health data, national ID).\n• If you do not want your chat content shared with the AI provider, refrain from using the chat feature; other parts of the app may be limited.\n• You can request deletion of chat logs under GDPR (see §11).\n\n6. Sharing\n\nWe do not sell your personal data. We may share data with:\n• Third-party AI provider (only to generate the answer you request).\n• Infrastructure partners (hosting, CDN, email, log management).\n• Payment partner (if purchases are introduced).\n• Authorities if required by law or to protect rights/safety.\n\nAll parties process data under agreements (e.g., data processing agreements).\n\n7. Transfers outside EU/EEA\n\nSome recipients may be outside the EU/EEA (e.g., US). We use appropriate safeguards such as Standard Contractual Clauses (SCC). Contact us for more information.\n\n8. Retention\n• Chat content: By default up to 12 months, or until you delete it in the app or request deletion.\n• Server logs (IP, errors, performance): Up to 90 days for troubleshooting/security.\n• Account data (if applicable): As long as the account is active and thereafter as required by law. We may anonymize/aggregate data for statistics.\n\n9. Security\n\nWe use technical and organizational measures to protect data, including encryption in transit (HTTPS), access controls, and logging. No method is 100% secure, but we continuously improve.\n\n10. Cookies and local storage (Web)\n\nOn the web, we may use necessary cookies and/or localStorage/IndexedDB for settings, session management, and cache. Analytics or marketing cookies are used only if you consent.\n\n11. Your rights (GDPR)\n\nYou have the right to:\n• Access your personal data,\n• Request correction or deletion,\n• Request restriction of processing,\n• Object to processing based on legitimate interest,\n• Data portability in some cases,\n• Withdraw consent when processing is based on consent.\n\nContact us at support@sera.chat. You can also file a complaint with the relevant supervisory authority.\n\n12. Children\n\nSERA is not directed to children. If you believe a child under 16 has provided data, contact us and we will remove it.\n\n13. Your choices and controls\n• You can disable collection of crash/diagnostic data at any time (if available).\n• You can clear chat in the app and ask us to delete associated server logs.\n• AI consent: at first chat use, we show a clear dialog. You can opt out; some features may then be limited.\n\n14. Third-party links and sources\n\nSERA may show source links (e.g., to manuals, documentation). We are not responsible for third-party websites and their policies.\n\n15. Changes\n\nWe may update this policy. The new version will be published here with an updated date. For major changes, we will notify in-app or via email (if available).\n\n16. Contact\n\nQuestions about privacy? Contact: support@sera.chat\nMail: Ullevivägen 45, 746 51 Bålsta'**
  String get privacyFull;

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
