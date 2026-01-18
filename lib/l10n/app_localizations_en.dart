// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SERA Home';

  @override
  String get beta => 'SERA Home';

  @override
  String get startTitle => 'SERA Home';

  @override
  String get startBadge => 'HOME';

  @override
  String get startSubtitle =>
      'Home improvement\nOptimized purchasing\nMinimized waste\nExpert guidance';

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
  String get businessLoginButton => 'Continue to log in';

  @override
  String get businessLoginUsername => 'Username';

  @override
  String get businessLoginPassword => 'Password';

  @override
  String get businessLoginSubmit => 'Sign in';

  @override
  String get businessLoginFooter =>
      'Don’t have an account? Contact your admin.';

  @override
  String get personalPricingTitle => 'Personal access';

  @override
  String get personalPricingBody =>
      'Personal users subscribe via App Store or Google Play. If you have already logged in on this device, you\'ll go straight into the app.';

  @override
  String get personalPricingTrial => '7-day free trial, then 29/month.';

  @override
  String get personalPricingSubscribe => 'Start 7 days free – 29/month';

  @override
  String get personalPricingOpenApp => 'I’ve already purchased – open the app';

  @override
  String get termsTitle => 'Terms of Use';

  @override
  String get termsBody =>
      'TERMS OF USE — SERA\n\nVersion: 2025-11-03\nApplies to: The SERA app and related services (“Service”)\nProvider: SimlingGroup SERA\nAddress: Ullevivägen 45, 746 51 Bålsta\nContact: support@sera.chat\n\n1. About the Service\n\nSERA is a troubleshooting and service assistant for equipment. The app offers chat-based guidance with a focus on safety and can show sources/disclaimers. The Service may integrate third-party AI providers and our curated knowledge library (“SERA’s library”) to improve answer quality.\n\nImportant safety notice: SERA does not replace OEM manuals, training, or certified expertise. Always follow local safety rules, lockout/tagout (LOTO), and manufacturer instructions. Use the Service at your own risk.\n\n2. Eligibility\n\nYou must be:\n• At least 16 years old (or higher as required by local law); and\n• authorized to enter into agreements.\nBusiness users confirm they use the Service within their employer/organization and follow internal policies.\n\n3. Account and access\n• Individuals: May purchase a subscription in-app via App Store/Google Play.\n• Business: Access via enterprise license (agreement) and login (e.g., SSO/email).\nYou are responsible for accurate, up-to-date info and for protecting login credentials.\n\n4. Acceptable use (prohibited behavior)\n\nYou may not:\n• bypass security features or overload the Service (e.g., scraping, rate-limit bypass),\n• use the Service for unlawful purposes, share harmful content, or infringe others’ rights,\n• attempt to recreate, decompile, or reverse engineer the Service, models, or library.\n\n5. AI answers and SERA’s library\n\nWhen you ask a question, relevant content (incl. selected brand/model/year) is sent to our server/proxy. The server can:\n1. Search SERA’s library (manuals, service bulletins we’re allowed to use),\n2. forward the minimum necessary excerpts + your question to a third-party AI provider,\n3. compile the answer for you, often with source references.\n\nWe configure the provider so data is not used for general model training where such controls exist. Logs may be retained briefly for security/abuse detection. All communication uses HTTPS. See the Privacy Policy for more details.\n\n6. Privacy and data\n\nAll personal data processing is described in our Privacy Policy. It is part of these terms.\n\n7. Intellectual property\n\nThe SERA app, graphics (including logos), and SERA’s library are owned by SimlingGroup or our licensors. You get a limited, non-exclusive, non-transferable license to use the Service under these terms. Any other use requires our written consent.\n\n8. User content\n\nIf you upload text/images/logs, you grant us a global, non-exclusive license to process them only to deliver the Service (including troubleshooting, support, security). You are responsible for having the rights to share the material and ensuring it doesn’t violate law or third-party rights.\n\n9. Beta features\n\nFeatures marked “Beta” may be unfinished and can change or be removed without notice. Use Beta at your own risk.\n\n10. Interruptions and changes\n\nWe may perform scheduled maintenance, update features, or change the Service. For major changes, we aim to inform in advance.\n\n11. Liability and disclaimer\n\nThe Service is provided “as is.” To the extent permitted by law, we disclaim indirect damages (e.g., production loss, consequential damages, data loss). Our aggregate liability is limited to what you paid in the last 12 months for the Service (except where mandatory consumer law gives you greater protection).\n\n12. Consumer rights (individuals)\n\nNothing in these terms limits your mandatory rights under applicable consumer law. Subscriptions purchased via App Store/Google Play are governed by each store’s terms and refund processes.\n\n13. Termination and suspension\n\nYou may stop using the Service at any time. We may suspend or terminate access for violations, security/abuse risk, or non-payment. For consumer subscriptions, see Subscription Terms.\n\n14. Changes to terms\n\nWe may update these terms. For significant changes, we will inform you in the app or by email. Continued use after effective date means you accept the changes.\n\n15. Governing law and dispute resolution\n\nSwedish law applies. Disputes are resolved by Swedish courts (e.g., Stockholm District Court) unless mandatory consumer law states otherwise.\n\n16. Contact\n\nQuestions about the Service or terms: support@sera.chat';

  @override
  String get subscriptionTitle => 'Subscription Terms';

  @override
  String get subscriptionBody =>
      'SUBSCRIPTION TERMS — SERA\n\nVersion: 2025-11-03\nApplies to individual in-app purchases via App Store/Google Play and enterprise licenses via agreement.\n\n1. Scope\n\nThese terms govern payment, renewal, cancellation, and refunds for:\n• Individual subscription (IAP): bought in-app via App Store or Google Play.\n• Enterprise license: purchased outside the app via agreement/invoice (per organization and/or per user).\n\n2. Plans and pricing\n• Individual: monthly subscription, preliminarily 29/month (incl. VAT). The exact price is shown in App Store/Google Play for your region.\n• Enterprise: plan/pricing per quote or price list (e.g., per seat or tier). Minimum fees and volume discounts may apply.\n\nWe may change prices/plans going forward. For individual subscriptions, we follow App Store/Google Play rules for price increases (notice + option to decline).\n\n3. Payment\n• Individual (IAP): Payment handled by App Store/Google Play with your store account. We do not accept direct payment in-app for the consumer path.\n• Enterprise: Invoice/Stripe per agreement (e.g., net 30). Late payment may incur interest and/or suspension.\n\n4. Term and renewal\n• Subscription runs monthly from purchase and auto-renews until canceled.\n• Enterprise licenses run per agreement (monthly/annual) and renew per contract terms.\n\n5. Manage/cancel subscription\n• iOS (App Store): Settings → your name → Subscriptions → SERA → Cancel.\n• Android (Google Play): Google Play → profile → Payments & subscriptions → Subscriptions → SERA → Cancel.\nCancellation applies from next period. Access remains until the current paid period ends.\n\n6. Right of withdrawal and refunds (consumer)\n• Withdrawal: In EU/SE, digital subscriptions may have a 14-day withdrawal right. App Store/Google Play handle this in their systems.\n• If you consent to immediate delivery of digital content, withdrawal may be affected per law/store terms.\n• Refunds: Request via App Store/Google Play. We normally do not issue direct refunds for IAP purchases.\n\n7. Enterprise: seats/users\n• License applies to the organization. Admin may assign seats to users.\n• You must ensure only authorized users access the license and that credentials are shared per agreement (not between individuals unless allowed).\n• We may apply fair use and technical limits (API quotas, concurrency).\n\n8. Access and suspension\n• For unpaid invoices/unauthorized use, access may be limited or suspended.\n• If your store account lacks an active subscription (individual) or your org license lapses (enterprise), the Service may stop working until payment/agreement is reactivated.\n\n9. Changes to subscription terms\n\nWe may update these terms. For significant changes, we will inform in the app/email and/or via store notices. Continued use after effective date means you accept the changes.\n\n10. Support and contact\n• Technical support & billing (SimlingGroup): support@sera.chat\n• IAP purchases (individual): Primarily handled via App Store/Google Play.\n• Address: Ullevivägen 45, 746 51 Bålsta';

  @override
  String get startVersion => 'Version 1.0 • For technicians and support teams';

  @override
  String get homeAppBarTitle => 'SERA Home';

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
  String get homeCardTroubleshootingTitle => 'Projects';

  @override
  String get homeCardTroubleshootingBadge => 'PROJECTS';

  @override
  String get homeCardTroubleshootingBody =>
      'Here you will find guides for planned jobs and renovations—from idea to finished result.\nStep-by-step instructions, material choices, tool lists, time and cost estimates, plus smart pro tips to avoid mistakes and rework.';

  @override
  String get homeCardMaintenanceTitle => 'Maintenance';

  @override
  String get homeCardMaintenanceBadge => 'MAINTENANCE';

  @override
  String get homeCardMaintenanceBody =>
      'Everything you need to keep the home in great shape year-round.\nSeasonal checklists, quick fixes, troubleshooting common problems (drafts, moisture, squeaks, clogs, cracks), plus guidance on when DIY is enough and when it is time to call a professional.';

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
  String get serviceCta => 'Service';

  @override
  String get serviceTitle => 'Service plan';

  @override
  String get serviceHeadline => 'Generate a service plan with specifications';

  @override
  String get serviceBrandLabel => 'Brand';

  @override
  String get serviceBrandHint => 'e.g. Volvo, CAT, Komatsu';

  @override
  String get serviceModelLabel => 'Model';

  @override
  String get serviceModelHint => 'e.g. EC250E, 320 GC';

  @override
  String get serviceYearLabel => 'Year';

  @override
  String get serviceYearHint => 'e.g. 2019';

  @override
  String get serviceTypeLabel => 'Service interval';

  @override
  String get serviceTypeYearly => 'Annual service';

  @override
  String get serviceTypeAfterRepair => 'Post-repair';

  @override
  String get serviceTypeCustom => 'Custom…';

  @override
  String get serviceTypeCustomLabel => 'Custom interval';

  @override
  String get serviceTypeCustomHint => 'e.g. 750 h, A-service';

  @override
  String get serviceGenerate => 'Generate';

  @override
  String get serviceClear => 'Clear';

  @override
  String get servicePreviewTitle => 'Preview';

  @override
  String get servicePreviewEmpty =>
      'Your service plan will appear here. Fill in the fields and tap Generate.';

  @override
  String get serviceCopy => 'Copy';

  @override
  String get serviceExportPdf => 'Export PDF';

  @override
  String get serviceCopied => 'Copied';

  @override
  String get serviceGeneratedAt => 'Generated';

  @override
  String get servicePdfFileName => 'service-plan.pdf';

  @override
  String get serviceErrorUnauthorized =>
      'Unauthorized (401) – check proxy or API key.';

  @override
  String get serviceErrorGeneric =>
      'Network error – could not build the service plan.';

  @override
  String get generalChatTitle => 'General chat';

  @override
  String get generalChatNotice =>
      'This is the general chat. For machine-specific troubleshooting, use Projects. For reports: Work order. For service plan: Service.';

  @override
  String get generalChatInfo =>
      'Information is guidance only. For targeted troubleshooting, switch to Projects.';

  @override
  String get workOrderCta => 'Work order';

  @override
  String get workOrderTitle => 'Work order';

  @override
  String get workOrderHeadline => 'Create work order';

  @override
  String get workOrderSubhead =>
      'Briefly describe what type of work you want to carry out and SERA will generate a clear, professional work order.';

  @override
  String get workOrderDescriptionLabel => 'Description';

  @override
  String get workOrderDescriptionHint =>
      'Describe the job: what to do, where (room/outdoor), measurements/quantity, substrate (wood/drywall/concrete), current condition, and desired result. Also note if it is a wet area, load-bearing, or electrical.';

  @override
  String get workOrderGenerate => 'Generate';

  @override
  String get workOrderClear => 'Clear';

  @override
  String get workOrderPreviewTitle => 'Preview';

  @override
  String get workOrderPreviewEmpty =>
      'Your generated work order will show here. Add a short description and tap Generate.';

  @override
  String get workOrderCopy => 'Copy';

  @override
  String get workOrderExportPdf => 'Export PDF';

  @override
  String get workOrderCopied => 'Copied';

  @override
  String get workOrderPdfTitle => 'Work order';

  @override
  String get workOrderGeneratedAt => 'Generated';

  @override
  String get workOrderPdfFileName => 'work-order.pdf';

  @override
  String get workOrderErrorUnauthorized =>
      'Unauthorized (401) – check proxy or API key.';

  @override
  String get workOrderErrorGeneric =>
      'Network error – could not build the work order.';

  @override
  String get sidebarTipsTitle1 => 'Project ? engine will not start';

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
  String get settingsWebSearchTitle => 'Web search (SERA Home)';

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
  String get chatAppBarTitle => 'SERA Home – Chat';

  @override
  String get chatBrandLabel => 'Housing type';

  @override
  String get chatBrandHint => 'e.g. house, apartment, cabin';

  @override
  String get chatHousingVilla => 'Villa';

  @override
  String get chatHousingTownhouse => 'Townhouse';

  @override
  String get chatHousingSemiDetached => 'Semi-detached';

  @override
  String get chatHousingApartment => 'Apartment';

  @override
  String get chatHousingStudentApartment => 'Student apartment';

  @override
  String get chatHousingCabin => 'Cabin';

  @override
  String get chatHousingVacationHome => 'Vacation home';

  @override
  String get chatHousingFarmhouse => 'Farmhouse';

  @override
  String get chatHousingAttefall => 'Attefall house';

  @override
  String get chatModelLabel => 'Work type';

  @override
  String get chatModelHint => 'Choose a work type';

  @override
  String get chatWorkCarpentryTitle => 'Carpentry & build';

  @override
  String get chatWorkCarpentryDesc =>
      'Build, assemble, and reinforce: walls, floors, trim, doors, decks, and smart structures.';

  @override
  String get chatWorkPaintingTitle => 'Painting & finishes';

  @override
  String get chatWorkPaintingDesc =>
      'Fill, sand, and paint correctly—indoors and out. Wallpaper, primer, and pro-level finish.';

  @override
  String get chatWorkPlumbingTitle => 'Plumbing';

  @override
  String get chatWorkPlumbingDesc =>
      'Fix clogs, leaks, and replacements. Faucets, traps, radiators, and flow/function.';

  @override
  String get chatWorkElectricalTitle => 'Electrical & lighting';

  @override
  String get chatWorkElectricalDesc =>
      'Lights, fixtures, and fault symptoms—safe checks and tips. Fixed wiring = electrician';

  @override
  String get chatYearLabel => 'Year';

  @override
  String get chatYearHint => 'Select build era (approx.)';

  @override
  String get chatYearOption2020s => '2020s (2020–now)';

  @override
  String get chatYearOption2010s => '2010s';

  @override
  String get chatYearOption2000s => '2000s';

  @override
  String get chatYearOption1990s => '1990s';

  @override
  String get chatYearOption1980s => '1980s';

  @override
  String get chatYearOption1970s => '1970s';

  @override
  String get chatYearOption1950s1960s => '1950s–1960s';

  @override
  String get chatYearOption1900s => '1900s (1900–1949)';

  @override
  String get chatYearOptionPre1900 => 'Pre-1900';

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
  String get chatStatusNone => 'Please select housing and work type.';

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

  @override
  String get chatSafetyHide => 'Hide safety notice';

  @override
  String get chatSafetyShow => 'Show safety notice';

  @override
  String get chatThinkingPreparing => 'Thinking…';

  @override
  String get chatThinkingGathering => 'Gathering info from the knowledge base…';

  @override
  String get chatThinkingComposing => 'Composing a reply…';
}
