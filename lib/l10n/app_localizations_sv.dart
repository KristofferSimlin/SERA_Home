// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'SERA';

  @override
  String get beta => 'BETA';

  @override
  String get startTitle => 'SERA';

  @override
  String get startSubtitle => 'Service & Equipment Repair Assistant';

  @override
  String get startCta => 'Kom igång';

  @override
  String get startVersion => 'Version 1.0 • För tekniker och supportteam';

  @override
  String get homeAppBarTitle => 'SERA';

  @override
  String get homeAcademy => 'Academy';

  @override
  String get homeForum => 'Forum';

  @override
  String get comingSoon => 'Kommer snart';

  @override
  String get homeNewChat => 'Ny chatt';

  @override
  String get homeSettings => 'Inställningar';

  @override
  String get homeProfile => 'Profil';

  @override
  String get homeSearchHint => 'Sök i chattar…';

  @override
  String get homeNoChats => 'Inga chattar ännu';

  @override
  String get homeRename => 'Byt namn';

  @override
  String get homeDelete => 'Radera';

  @override
  String get homeRenameDialogTitle => 'Döp om chatt';

  @override
  String get homeRenameDialogHint => 'Ange nytt namn';

  @override
  String get homeRenameCancel => 'Avbryt';

  @override
  String get homeRenameSave => 'Spara';

  @override
  String get sidebarTipsTitle1 => 'Felsökning – motor startar inte';

  @override
  String get sidebarTipsTitle2 => 'Läs felkod & nästa steg';

  @override
  String get sidebarTipsTitle3 => 'Underhåll – checklista';

  @override
  String get sidebarTipsTitle4 => 'Säkerhetsråd – hydraulik';

  @override
  String get homeHeroDescription =>
      'SERA är din AI-assistent för entreprenadmaskiner – från felsökning till installation. Snart kompletterad med SERA Academy och ett community-forum där du kan lära, dela erfarenheter och få stöd av andra i branschen.';

  @override
  String get settingsTitle => 'Inställningar';

  @override
  String get settingsConnection => 'Anslutning';

  @override
  String get settingsProxyToggle => 'Proxy-läge (rekommenderas)';

  @override
  String get settingsProxySubtitle =>
      'Döljer API-nyckel och kan lägga till webbsök /search';

  @override
  String get settingsProxyUrlLabel => 'PROXY_URL';

  @override
  String get settingsProxyUrlHint => 'https://api.sera.chat/api/openai-proxy';

  @override
  String get settingsProxyUrlHelper =>
      'Ange ENDAST URL:en (inte \"PROXY_URL=\" framför).';

  @override
  String get settingsDirectKeyLabel => 'OPENAI_API_KEY (direktläge)';

  @override
  String get settingsDirectKeyHint => 'sk-********';

  @override
  String get settingsDirectKeyHelper =>
      'Använd bara för lokal test. Lägg aldrig nyckeln i produktion.';

  @override
  String get settingsProxyTip =>
      'Tips: Kör proxy-läge i produktion. Direktläge exponerar nyckeln i klienten.';

  @override
  String get settingsWebSearchTitle => 'Webbsök (beta)';

  @override
  String get settingsWebSearchToggle => 'Aktivera webbsök via proxy /search';

  @override
  String get settingsWebSearchSubtitle =>
      'Kräver PROXY_SEARCH_URL i .env och route /search i proxyn';

  @override
  String get settingsWebSearchInfo =>
      'När detta är på försöker SERA hämta relevanta källor (manualer, forum, tekniska sidor) för ditt märke/modell/årsmodell och väver in fynden i svaret.';

  @override
  String get settingsLanguageLabel => 'Språk';

  @override
  String get settingsSafetyTitle => 'Säkerhet';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileDataTitle => 'Profil & data';

  @override
  String get profileDataInfo =>
      'Rensa lokalt sparad data (sessioner, meddelanden, utrustning). Krav från App Store för dataradering.';

  @override
  String get profileDelete => 'Radera lagrad data';

  @override
  String get profileDeleteConfirmTitle => 'Radera all lagrad data?';

  @override
  String get profileDeleteConfirmBody =>
      'Detta raderar lokala sessioner, meddelanden och utrustningsval. Åtgärden går inte att ångra.';

  @override
  String get profileDeleteCancel => 'Avbryt';

  @override
  String get profileDeleteConfirm => 'Radera';

  @override
  String get profileDeleteDone => 'All lokal data raderad';

  @override
  String get error => 'Fel';

  @override
  String get profileComingSoonTitle => 'Kommer snart';

  @override
  String get profileComingSoonBody =>
      'Här lägger vi till inloggning, snabbval av utrustning och andra profilinställningar.';

  @override
  String get profilePrivacy => 'Privacy Policy';

  @override
  String get privacyFull =>
      'Integritetspolicy – SERA\n\nSenast uppdaterad: 2025-11-29\nGäller för: SERA (iOS, Android och Web)\n\n1. Vem är personuppgiftsansvarig?\nFöretag: SimlinGroup\nAdress: Ullevivägen 45, 746 51 Bålsta\nE-post: support@sera.chat\n\nVi ansvarar för behandlingen av personuppgifter i samband med din användning av SERA.\n\n2. Kort sammanfattning\n• SERA låter dig felsöka maskinproblem via chatt.\n• Ditt chattinnehåll och utrustningsdata (märke, modell, årsmodell) skickas via vår proxy till en tredjeparts AI-leverantör för att generera svar.\n• All trafik sker över HTTPS. Vi säljer inte dina personuppgifter.\n• Du kan begära radering av chattloggar och utöva dina GDPR-rättigheter (se avsnitt 11).\n\n3. Vilka uppgifter samlar vi in?\nA. Användarinnehåll: Chatttext, utrustningsfält, ev. bilagor.\nB. Tekniska/loggdata: IP (i serverloggar), tidsstämplar, enhets- och webbläsarinfo, krasch/prestandadata om du samtycker.\nC. Kontouppgifter (om konton införs): Namn, e-post, autentisering, betaluppgifter via betalpartner.\nD. Support: Meddelanden till support.\nVi samlar inte in exakt geolokalisering. Kamera/mikrofon/notiser används bara om du aktiverar en funktion som kräver det.\n\n4. Varför behandlar vi uppgifterna (rättslig grund)\n• Leverera tjänsten (avtal).\n• Säkerhet/missbruksförebyggande (berättigat intresse).\n• Förbättring/diagnostik (berättigat intresse eller samtycke).\n• Juridiska skyldigheter (t.ex. bokföring, rättsliga krav).\n• Marknad/kommunikation (endast vid samtycke).\n\n5. Hur genereras AI-svar?\nMeddelande + utrustning går till vår proxy och vidare till AI-leverantör för svar.\n• Vi konfigurerar att data inte används för generell träning där kontroll finns.\n• Leverantören kan behålla begränsade loggar kort tid för att motverka missbruk.\n• Dela inte känsliga uppgifter (personnummer, hälsa m.m.).\n\n6. Delning\nIngen försäljning. Delning kan ske med AI-leverantör, drift/hosting/CDN/e-post/loggning, betalpartner, myndigheter om krav. Allt regleras i avtal.\n\n7. Överföring utanför EU/EES\nKan ske (t.ex. USA). Vi använder SCC eller likvärdiga skydd.\n\n8. Lagring\n• Chattinnehåll: upp till 12 månader eller tills du raderar/begär radering.\n• Serverloggar: upp till 90 dagar för felsökning/säkerhet.\n• Kontodata: så länge kontot är aktivt och därefter enligt lag. Kan anonymiseras/aggreggeras.\n\n9. Säkerhet\nHTTPS, åtkomstkontroller, loggning; kontinuerliga förbättringar.\n\n10. Cookies/lokal lagring (Web)\nNödvändiga cookies/localStorage/IndexedDB för inställningar, sessioner, cache. Analys/marknadsföring endast vid samtycke.\n\n11. Dina rättigheter (GDPR)\nTillgång, rättelse, radering, begränsning, invändning (berättigat intresse), portabilitet i vissa fall, återkalla samtycke. Kontakta support@sera.chat. Klagomål till IMY/tillsynsmyndighet.\n\n12. Barns integritet\nInte riktad till barn. Om under 16 lämnat data, kontakta oss för radering.\n\n13. Dina val\n• Stäng av krasch/diagnostik (om finns).\n• Rensa chatt i appen och be oss radera kopplade serverloggar.\n• Samtyckesdialog för AI vid första användning; avböj begränsar funktioner.\n\n14. Tredjepartslänkar/källor\nKan visas; vi ansvarar inte för deras policys.\n\n15. Ändringar\nVi kan uppdatera policyn; ny version publiceras här och större ändringar meddelas i app/e-post (om uppgifter finns).\n\n16. Kontakt\nsupport@sera.chat\nPost: Ullevivägen 45, 746 51 Bålsta';

  @override
  String get privacyTitle => 'Integritetspolicy';

  @override
  String get privacyUpdated => 'Senast uppdaterad: 2025-11-29';

  @override
  String get privacyApplies => 'Gäller för: SERA (iOS, Android och Web)';

  @override
  String get privacyBody => 'Se hela policyn nedan.';

  @override
  String get chatAppBarTitle => 'SERA – Chatt';

  @override
  String get chatBrandLabel => 'Märke';

  @override
  String get chatBrandHint => 'ex. Volvo, CAT, Wacker Neuson';

  @override
  String get chatModelLabel => 'Modell';

  @override
  String get chatModelHint => 'ex. EC250E, 320 GC';

  @override
  String get chatYearLabel => 'Årsmodell';

  @override
  String get chatYearHint => 'ex. 2019';

  @override
  String get chatExpertiseLabel => 'Kunskapsnivå';

  @override
  String get chatExpertise1 => '1 – Nybörjare';

  @override
  String get chatExpertise2 => '2 – Medel';

  @override
  String get chatExpertise3 => '3 – Expert';

  @override
  String chatStatusTitle(Object equipment) {
    return 'Vald: $equipment';
  }

  @override
  String get chatStatusNone => 'Ingen utrustning vald ännu.';

  @override
  String get chatStatusLocked => ' • Låst';

  @override
  String chatStatusLevel(Object level) {
    return ' • Nivå: $level';
  }

  @override
  String get chatClear => 'Byt';

  @override
  String get chatLock => 'Lås';

  @override
  String get chatSave => 'Spara';

  @override
  String get chatInfo =>
      'Informationen är vägledande. Följ alltid tillverkarens instruktioner och lokala säkerhetsregler. Egen risk.';

  @override
  String get chatInputHint => 'Skriv ett meddelande…';

  @override
  String get chatSend => 'Skicka';

  @override
  String get chatSafetyBanner =>
      'Säkerhetsfilter: Koppla från ström, avlasta tryck, ventilera vid bränslearbete. Använd skyddsutrustning. Följ alltid tillverkarens instruktioner.';
}
