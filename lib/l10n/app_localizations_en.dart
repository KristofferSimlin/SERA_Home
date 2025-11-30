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
  String get startCta => 'Get started';

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
  String get privacyFull =>
      'Privacy Policy – SERA\n\nLast updated: 2025-11-29\nApplies to: SERA (iOS, Android and Web)\n\n1. Who is the controller?\nCompany: SimlinGroup\nAddress: Ullevivägen 45, 746 51 Bålsta\nEmail: support@sera.chat\n\nWe are responsible for processing personal data when you use SERA.\n\n2. Summary\n• SERA helps you troubleshoot equipment via chat.\n• Your chat content and equipment data (brand, model, year) go through our proxy to a third-party AI to generate answers.\n• All traffic uses HTTPS. We do not sell your personal data.\n• You can request deletion of chat logs and exercise GDPR rights (see section 11).\n\n3. What data we collect\nA. User content: Chat text, equipment fields, optional attachments.\nB. Technical/log data: IP (in server logs), timestamps, device/browser info, crash/performance data if you consent.\nC. Account data (if accounts are added): Name, email, auth data, payment info via payment partner.\nD. Support: Messages you send to support.\nWe do not collect exact geolocation. Camera/mic/notifications used only if you enable a feature that requires it.\n\n4. Why we process data (legal basis)\n• Provide service (contract).\n• Security/abuse prevention (legitimate interest).\n• Improvement/diagnostics (legitimate interest or consent).\n• Legal obligations (e.g., bookkeeping, legal claims).\n• Marketing/communication (consent only).\n\n5. How AI answers are generated\nYour message and equipment info are sent to our proxy, then to an AI provider to generate the answer.\n• We configure the provider to not use data for general model training where controls exist.\n• Provider may keep limited logs briefly to prevent abuse/ensure operation.\n• Do not share sensitive data (e.g., IDs, health info).\n\n6. Sharing\nNo selling. We may share with AI provider, infra/hosting/CDN/email/logging, payment partner, authorities if required. All under proper agreements.\n\n7. Transfers outside EU/EEA\nSome recipients may be outside EU/EEA (e.g., US). We use SCCs or equivalent safeguards.\n\n8. Retention\n• Chat content: up to 12 months or until you delete/request deletion.\n• Server logs: up to 90 days for troubleshooting/security.\n• Account data: as long as account is active, then per legal requirements. Data may be anonymized/aggregated.\n\n9. Security\nHTTPS, access controls, logging; continuous improvements.\n\n10. Cookies/local storage (Web)\nWe may use necessary cookies/localStorage/IndexedDB for settings, sessions, cache. Analytics/marketing only with consent.\n\n11. Your rights (GDPR)\nAccess, rectification, deletion, restriction, objection (legitimate interest), portability in some cases, withdraw consent. Contact support@sera.chat. Complaints to local authority/IMY.\n\n12. Children\nNot intended for children. If under 16 shared data, contact us for deletion.\n\n13. Your choices\n• Turn off crash/diagnostics (if available).\n• Clear chat in app and ask us to delete related server logs.\n• Consent dialog for AI at first use; decline limits features.\n\n14. Third-party links/sources\nLinks may appear; we are not responsible for their policies.\n\n15. Changes\nWe may update this policy; new version will be published here and major changes notified in-app/email (if available).\n\n16. Contact\nsupport@sera.chat\nPost: Ullevivägen 45, 746 51 Bålsta';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String get privacyUpdated => 'Last updated: 2025-11-29';

  @override
  String get privacyApplies => 'Applies to: SERA (iOS, Android and Web)';

  @override
  String get privacyBody => 'For full details, see the policy text.';

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
