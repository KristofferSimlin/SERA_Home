// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SERA';

  @override
  String get beta => 'BETA';

  @override
  String get startTitle => 'SERA';

  @override
  String get startSubtitle => 'Service & Equipment Repair Assistant';

  @override
  String get startCta => 'Enter';

  @override
  String get startLoginBusiness => 'Log in - business';

  @override
  String get startLoginPersonal => 'Log in - personal';

  @override
  String get businessLoginTitle => 'Business login';

  @override
  String get businessLoginBody =>
      'Licenses are purchased separately. Use your company login link or SSO. If you need help, contact your administrator.';

  @override
  String get businessLoginButton => 'Continue to login';

  @override
  String get personalPricingTitle => 'Personal access';

  @override
  String get personalPricingBody =>
      'Personal users subscribe via App Store or Google Play. If you already logged in on this device, you’ll go straight into the app.';

  @override
  String get personalPricingStoreIos => 'Buy via App Store';

  @override
  String get personalPricingStoreAndroid => 'Buy via Google Play';

  @override
  String get personalPricingOpenApp => 'I’ve already purchased – open the app';

  @override
  String get startVersion => 'Version 1.0 • For technicians and support teams';

  @override
  String get homeAppBarTitle => 'SERA';

  @override
  String get homeAcademy => 'Academy';

  @override
  String get homeForum => 'Forum';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get homeNewChat => 'New chat';

  @override
  String get homeSettings => 'Settings';

  @override
  String get homeProfile => 'Profile';

  @override
  String get homeSearchHint => 'Search chats…';

  @override
  String get homeNoChats => 'No chats yet';

  @override
  String get homeRename => 'Rename';

  @override
  String get homeDelete => 'Delete';

  @override
  String get homeRenameDialogTitle => 'Rename chat';

  @override
  String get homeRenameDialogHint => 'Enter new name';

  @override
  String get homeRenameCancel => 'Cancel';

  @override
  String get homeRenameSave => 'Save';

  @override
  String get homeCardTroubleshootingTitle => 'Troubleshooting';

  @override
  String get homeCardTroubleshootingBadge => 'TROUBLESHOOTING';

  @override
  String get homeCardTroubleshootingBody =>
      'SERA helps you quickly identify faults in heavy equipment with AI-powered analysis.\nDescribe symptoms, get suggested causes and step-by-step fixes.\nPerfect for field techs and mechanics who need answers fast.\nAlways available and up to date.';

  @override
  String get homeCardMaintenanceTitle => 'Maintenance';

  @override
  String get homeCardMaintenanceBadge => 'MAINTENANCE';

  @override
  String get homeCardMaintenanceBody =>
      'Clear instructions for service, inspections and planned maintenance.\nSERA guides you through the right intervals, recommended actions and common issues.\nLess guesswork, more structure.\nHelps you keep machines reliable longer.';

  @override
  String get homeCardTrainingTitle => 'Training';

  @override
  String get homeCardTrainingBadge => 'TRAINING';

  @override
  String get homeCardTrainingBody =>
      'SERA Academy offers guides, training and easy-to-read material.\nLearn functions, systems, installations and safety procedures.\nPerfect for new technicians or anyone leveling up skills.\nEverything collected in one simple digital format.';

  @override
  String get homeCardCommunityTitle => 'Community';

  @override
  String get homeCardCommunityBadge => 'COMMUNITY';

  @override
  String get homeCardCommunityBody =>
      'A forum where technicians, operators and enthusiasts share knowledge and experience.\nAsk questions, discuss fixes and help others in the industry.\nBuilds a strong community around SERA and heavy equipment.\nA place to learn, get inspired and grow together.';

  @override
  String get sidebarTipsTitle1 => 'Troubleshooting – engine will not start';

  @override
  String get sidebarTipsTitle2 => 'Read fault code & next steps';

  @override
  String get sidebarTipsTitle3 => 'Maintenance – checklist';

  @override
  String get sidebarTipsTitle4 => 'Safety advice – hydraulics';

  @override
  String get homeHeroDescription =>
      'SERA is your AI assistant for heavy equipment—from troubleshooting to installation. Soon complemented by SERA Academy and a community forum where you can learn, share experience, and get help from peers.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsConnection => 'Connection';

  @override
  String get settingsProxyToggle => 'Proxy mode (recommended)';

  @override
  String get settingsProxySubtitle =>
      'Hides API key and can add web search /search';

  @override
  String get settingsProxyUrlLabel => 'PROXY_URL';

  @override
  String get settingsProxyUrlHint => 'https://api.sera.chat/api/openai-proxy';

  @override
  String get settingsProxyUrlHelper =>
      'Enter only the URL (not \"PROXY_URL=\").';

  @override
  String get settingsDirectKeyLabel => 'OPENAI_API_KEY (direct mode)';

  @override
  String get settingsDirectKeyHint => 'sk-********';

  @override
  String get settingsDirectKeyHelper =>
      'Use only for local testing. Never ship key in production.';

  @override
  String get settingsProxyTip =>
      'Tip: Use proxy mode in production. Direct mode exposes the key in the client.';

  @override
  String get settingsWebSearchTitle => 'Web search (beta)';

  @override
  String get settingsWebSearchToggle => 'Enable web search via proxy /search';

  @override
  String get settingsWebSearchSubtitle =>
      'Requires PROXY_SEARCH_URL in .env and /search route in proxy';

  @override
  String get settingsWebSearchInfo =>
      'When enabled, SERA fetches relevant sources (manuals, forums, technical sites) for your make/model/year and weaves findings into the answer.';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsSafetyTitle => 'Safety';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileDataTitle => 'Profile & data';

  @override
  String get profileDataInfo =>
      'Erase locally stored data (sessions, messages, equipment). Required for App Store data deletion.';

  @override
  String get profileDelete => 'Delete stored data';

  @override
  String get profileDeleteConfirmTitle => 'Delete all stored data?';

  @override
  String get profileDeleteConfirmBody =>
      'This deletes local sessions, messages and equipment selections. This cannot be undone.';

  @override
  String get profileDeleteCancel => 'Cancel';

  @override
  String get profileDeleteConfirm => 'Delete';

  @override
  String get profileDeleteDone => 'All local data deleted';

  @override
  String get error => 'Error';

  @override
  String get profileComingSoonTitle => 'Coming soon';

  @override
  String get profileComingSoonBody =>
      'Here we will add login, quick equipment presets and other profile settings.';

  @override
  String get profilePrivacy => 'Privacy Policy';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get privacyUpdated => 'Last updated: 2025-11-29';

  @override
  String get privacyApplies => 'Applies to: SERA (iOS, Android and Web)';

  @override
  String get privacyBody => 'For full details, see the policy text.';

  @override
  String get privacyFull =>
      'Privacy Policy – SERA\n\nLast updated: 2025-11-29\nApplies to: SERA (iOS, Android and Web)\n\n1. Who is the controller?\n\nCompany: SimlinGroup\nAddress: Ullevivägen 45, 746 51 Bålsta\nEmail: support@sera.chat\n\nWe are responsible for processing personal data when you use SERA.\n\n2. Summary\n• SERA helps you troubleshoot equipment and provides chat functionality.\n• Your chat content and equipment data (e.g., brand, model, year) go via our server (\"proxy\") to a third-party AI provider that uses data from our own knowledge library to generate answers.\n• All traffic uses HTTPS. We do not sell your personal data.\n• You can request deletion of chat logs and exercise GDPR rights (see section 11).\n\n3. What data we collect\n\nDepending on how you use SERA, we may process these categories:\n\nA. User content\n• Text you enter in chat, selected equipment fields (brand, model, year), any attached images/notes.\n\nB. Technical data & logs\n• IP address (in server logs), timestamps, device/browser info (for troubleshooting and security).\n• Crash and performance data if you consent in the app.\n\nC. Account data (if accounts are introduced)\n• Name, email, authentication details, payment-related data (handled via payment partner).\n\nD. Support\n• Messages you send to support and related correspondence.\n\nWe do not collect exact geolocation. Camera access, microphone, notifications, etc. are used only if you explicitly enable such a feature.\n\n4. Why we process data (purpose and legal basis)\n• Deliver the service (contract): Generate answers and troubleshooting steps, store history for you, show sources.\n• Security & abuse prevention (legitimate interest): Detect spam/abuse, protect the system.\n• Improvement & diagnostics (legitimate interest or consent): Performance, crash logs, quality follow-up.\n• Legal obligations: e.g., bookkeeping, handling legal claims.\n• Marketing/communication (consent): Only if you actively agree.\n\n5. How AI answers are generated and how SERA’s knowledge library is used\n\nWhen you use chat, your message and any equipment info are sent to our server/proxy. The proxy forwards necessary content to a third-party AI provider to generate an answer. To improve quality and precision, SERA also uses its own curated knowledge library (\"SERA’s library\").\n\nHow it works (RAG):\n• 1) Your question: Your chat content and selected equipment fields (brand, model, year) are received by our server.\n• 2) Search SERA’s library: Our server searches for relevant excerpts in SERA’s library (e.g., manuals, service bulletins, safety notices, technical facts we are allowed to use).\n• 3) Minimal sharing: Only the necessary excerpts plus your question (and equipment fields) are sent to the AI provider to generate the answer. We do not send entire documents unless needed to fulfill your request.\n• 4) Answer + sources: The AI answer is returned to the app, often with citations to the library sources used.\n\nAbout SERA’s library:\n• Owned and maintained by SERA; contains content we are allowed to use (own, licensed, or legally permitted).\n• Does not contain your personal data. Individual chat content is not added to the library, except possibly in aggregated/anonymized form to improve coverage and quality.\n• The library can be stored and updated independently of your app installation (so you get improvements without updating the app).\n\nThird-party AI provider:\n• Configured so data is not used for general model training where such controls exist.\n• May retain limited logs for a short time to prevent abuse and ensure operation.\n• All communication uses HTTPS.\n\nYour control:\n• Do not share sensitive personal data (e.g., health data, national ID).\n• If you do not want your chat content shared with the AI provider, refrain from using the chat feature; other parts of the app may be limited.\n• You can request deletion of chat logs under GDPR (see §11).\n\n6. Sharing\n\nWe do not sell your personal data. We may share data with:\n• Third-party AI provider (only to generate the answer you request).\n• Infrastructure partners (hosting, CDN, email, log management).\n• Payment partner (if purchases are introduced).\n• Authorities if required by law or to protect rights/safety.\n\nAll parties process data under agreements (e.g., data processing agreements).\n\n7. Transfers outside EU/EEA\n\nSome recipients may be outside the EU/EEA (e.g., US). We use appropriate safeguards such as Standard Contractual Clauses (SCC). Contact us for more information.\n\n8. Retention\n• Chat content: By default up to 12 months, or until you delete it in the app or request deletion.\n• Server logs (IP, errors, performance): Up to 90 days for troubleshooting/security.\n• Account data (if applicable): As long as the account is active and thereafter as required by law. We may anonymize/aggregate data for statistics.\n\n9. Security\n\nWe use technical and organizational measures to protect data, including encryption in transit (HTTPS), access controls, and logging. No method is 100% secure, but we continuously improve.\n\n10. Cookies and local storage (Web)\n\nOn the web, we may use necessary cookies and/or localStorage/IndexedDB for settings, session management, and cache. Analytics or marketing cookies are used only if you consent.\n\n11. Your rights (GDPR)\n\nYou have the right to:\n• Access your personal data,\n• Request correction or deletion,\n• Request restriction of processing,\n• Object to processing based on legitimate interest,\n• Data portability in some cases,\n• Withdraw consent when processing is based on consent.\n\nContact us at support@sera.chat. You can also file a complaint with the relevant supervisory authority.\n\n12. Children\n\nSERA is not directed to children. If you believe a child under 16 has provided data, contact us and we will remove it.\n\n13. Your choices and controls\n• You can disable collection of crash/diagnostic data at any time (if available).\n• You can clear chat in the app and ask us to delete associated server logs.\n• AI consent: at first chat use, we show a clear dialog. You can opt out; some features may then be limited.\n\n14. Third-party links and sources\n\nSERA may show source links (e.g., to manuals, documentation). We are not responsible for third-party websites and their policies.\n\n15. Changes\n\nWe may update this policy. The new version will be published here with an updated date. For major changes, we will notify in-app or via email (if available).\n\n16. Contact\n\nQuestions about privacy? Contact: support@sera.chat\nMail: Ullevivägen 45, 746 51 Bålsta';

  @override
  String get chatAppBarTitle => 'SERA – Chat';

  @override
  String get chatBrandLabel => 'Brand';

  @override
  String get chatBrandHint => 'e.g. Volvo, CAT, Wacker Neuson';

  @override
  String get chatModelLabel => 'Model';

  @override
  String get chatModelHint => 'e.g. EC250E, 320 GC';

  @override
  String get chatYearLabel => 'Year';

  @override
  String get chatYearHint => 'e.g. 2019';

  @override
  String get chatExpertiseLabel => 'Expertise';

  @override
  String get chatExpertise1 => '1 – Beginner';

  @override
  String get chatExpertise2 => '2 – Intermediate';

  @override
  String get chatExpertise3 => '3 – Expert';

  @override
  String chatStatusTitle(Object equipment) {
    return 'Selected: $equipment';
  }

  @override
  String get chatStatusNone => 'No equipment selected yet.';

  @override
  String get chatStatusLocked => ' • Locked';

  @override
  String chatStatusLevel(Object level) {
    return ' • Level: $level';
  }

  @override
  String get chatClear => 'Reset';

  @override
  String get chatLock => 'Lock';

  @override
  String get chatSave => 'Save';

  @override
  String get chatInfo =>
      'Information is guidance only. Follow manufacturer instructions and local safety rules. Use at your own risk.';

  @override
  String get chatInputHint => 'Type a message…';

  @override
  String get chatSend => 'Send';

  @override
  String get chatSafetyBanner =>
      'Safety filter: Disconnect power, relieve pressure, ventilate when handling fuel. Use PPE. Always follow manufacturer instructions.';
}
