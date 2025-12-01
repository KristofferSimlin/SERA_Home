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
  String get homeCardTroubleshootingTitle => 'Felsökning';

  @override
  String get homeCardTroubleshootingBadge => 'FELFÖRSÖKNING';

  @override
  String get homeCardTroubleshootingBody =>
      'SERA hjälper dig att snabbt identifiera fel i entreprenadmaskiner med AI-drivna analyser.\nFörklara symtom, få förslag på orsaker och steg-för-steg-lösningar.\nPerfekt för både fälttekniker och mekaniker som behöver snabba svar.\nAlltid tillgängligt och uppdaterat.';

  @override
  String get homeCardMaintenanceTitle => 'Underhåll';

  @override
  String get homeCardMaintenanceBadge => 'UNDERHÅLL';

  @override
  String get homeCardMaintenanceBody =>
      'Få tydliga instruktioner för service, inspektion och planerat underhåll.\nSERA guidar dig genom rätt intervaller, rekommenderade åtgärder och vanliga problem.\nMindre gissande, mer struktur.\nHjälper dig hålla maskinerna driftsäkra längre.';

  @override
  String get homeCardTrainingTitle => 'Utbildning';

  @override
  String get homeCardTrainingBadge => 'UTBILDNING';

  @override
  String get homeCardTrainingBody =>
      'SERA Academy erbjuder guider, utbildningar och lättförståeligt material.\nLär dig funktioner, system, installationer och säkerhetsrutiner.\nPerfekt för nya tekniker eller den som vill utveckla sina färdigheter.\nAllt samlat i ett enkelt, digitalt format.';

  @override
  String get homeCardCommunityTitle => 'Community';

  @override
  String get homeCardCommunityBadge => 'COMMUNITY';

  @override
  String get homeCardCommunityBody =>
      'Ett forum där tekniker, förare och entusiaster kan dela kunskap och erfarenheter.\nStäll frågor, diskutera lösningar och hjälp andra i branschen.\nBygger en stark gemenskap runt SERA och entreprenadmaskiner.\nEn plats att lära, inspireras och växa tillsammans.';

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
  String get privacyTitle => 'Integritetspolicy';

  @override
  String get privacyUpdated => 'Senast uppdaterad: 2025-11-29';

  @override
  String get privacyApplies => 'Gäller för: SERA (iOS, Android och Web)';

  @override
  String get privacyBody => 'Se hela policyn nedan.';

  @override
  String get privacyFull =>
      'Integritetspolicy – SERA\\n\\nSenast uppdaterad: 2025-11-29\\nGäller för: SERA (iOS, Android och Web)\\n\\n1. Vem är personuppgiftsansvarig?\\n\\nFöretag: SimlinGroup\\nAdress: Ullevivägen 45, 746 51 Bålsta\\nE-post: support@sera.chat\\n\\nVi ansvarar för behandlingen av personuppgifter i samband med din användning av SERA.\\n\\n2. Kort sammanfattning\\n• SERA låter dig felsöka maskinproblem och chattfunktionalitet.\\n• Ditt chattinnehåll och utrustningsdata (t.ex. märke, modell, årsmodell) skickas via vår server (\"proxy\") till en tredjeparts AI-leverantör för att generera svar.\\n• All trafik sker över HTTPS. Vi säljer inte dina personuppgifter.\\n• Du kan begära radering av chattloggar och utöva dina GDPR-rättigheter (se avsnitt 11).\\n\\n3. Vilka uppgifter samlar vi in?\\n\\nBeroende på hur du använder SERA kan vi behandla följande kategorier:\\n\\nA. Användarinnehåll\\n• Text du skriver i chatten, valda utrustningsfält (märke, modell, årsmodell), ev. bifogade bilder/anteckningar.\\n\\nB. Tekniska data & loggar\\n• IP-adress (i serverloggar), tidsstämplar, enhets- och webbläsarinfo (för felsökning och säkerhet).\\n• Krasch- och prestandadata om du samtycker till det i appen.\\n\\nC. Kontouppgifter (om konton införs)\\n• Namn, e-post, autentiseringsuppgifter, betalningsrelaterade uppgifter (hanteras via betalpartner).\\n\\nD. Support\\n• Meddelanden du skickar till support och relaterad korrespondens.\\n\\nVi samlar inte in exakt geolokalisering. Kamerabibliotek, mikrofon, notiser etc. används bara om du uttryckligen aktiverar en sådan funktion.\\n\\n4. Varför behandlar vi uppgifterna? (ändamål och rättslig grund)\\n• Leverera tjänsten (avtal): Generera svar och felsökningsförslag, spara historik till dig, visa källor.\\n• Säkerhet & missbruksförebyggande (berättigat intresse): Upptäcka spam/missbruk, skydda system.\\n• Förbättring & felsökning (berättigat intresse eller samtycke): Prestanda, kraschloggar, kvalitetsuppföljning.\\n• Juridiska skyldigheter (rättslig förpliktelse): Ex. bokföring, hantering av rättsliga krav.\\n• Marknad/kommunikation (samtycke): Endast om du aktivt har godkänt.\\n\\n5. Hur genereras AI-svar och hur används SERA:s kunskapsbibliotek?\\n\\nNär du använder chatten skickas ditt meddelande och eventuell utrustningsinformation från appen till vår server/proxy. Proxyn vidarebefordrar nödvändigt innehåll till en tredjeparts AI-leverantör för att generera ett svar. För att förbättra kvalitet och precision använder SERA även ett eget, kuraterat kunskapsbibliotek (\"SERA:s bibliotek\").\\n\\nSå här fungerar det i korthet:\\n• 1) Din fråga: Ditt chattinnehåll och valda utrustningsfält (märke, modell, årsmodell) tas emot av vår server.\\n• 2) Sök i SERA:s bibliotek: Vår server söker efter relevanta utdrag i SERA:s bibliotek (t.ex. manualer, servicebulletiner, säkerhetsföreskrifter och tekniska fakta som vi får använda).\\n• 3) Minimal delning: Endast de nödvändiga utdragen från biblioteket samt din fråga (och utrustningsfält) skickas vidare till AI-leverantören för att generera svaret. Vi delar inte hela dokument om det inte behövs för att uppfylla din förfrågan.\\n• 4) Svar + källor: AI-svaret returneras till appen, ofta med källhänvisningar till de biblioteksposter som användes.\\n\\nOm SERA:s bibliotek:\\n• Biblioteket ägs och förvaltas av SERA och består av innehåll som vi har rätt att använda (eget material, licensierat material eller material som omfattas av lagliga undantag).\\n• Biblioteket innehåller inte dina personuppgifter. Vi för inte in individuellt chattinnehåll i biblioteket, annat än möjligen i aggregerad/anonymiserad form för att förbättra täckning och kvalitet.\\n• Biblioteket kan lagras och uppdateras löpande oberoende av din appinstallation (så att du får förbättringar utan att uppdatera appen).\\n\\nTredjeparts AI-leverantör:\\n• Vi konfigurerar leverantören så att data inte används för generell modellträning där sådana kontroller finns tillgängliga.\\n• Leverantören kan behålla begränsade loggar under en kort period för att motverka missbruk och säkerställa driften.\\n• All kommunikation sker över HTTPS.\\n\\nDin kontroll:\\n• Dela inte känsliga personuppgifter i chatten (t.ex. hälsodata, personnummer).\\n• Om du inte vill att ditt chattinnehåll ska delas med en tredjeparts AI-leverantör kan du avstå från att använda chattfunktionen; andra delar av appen kan vara begränsade.\\n• Du kan begära radering av chattloggar enligt GDPR (se §11).\\n\\n6. Delning av uppgifter\\n\\nVi delar inte dina personuppgifter för försäljning. Vi kan dela uppgifter med:\\n• Tredjeparts AI-leverantör (endast för att generera det svar du begär).\\n• Drift- och infrastrukturpartners (hosting, CDN, e-post, logghantering).\\n• Betalpartner (om köp införs).\\n• Myndigheter om lagen kräver det eller för att skydda rättigheter/säkerhet.\\n\\nAlla parter behandlar uppgifter enligt avtal (personuppgiftsbiträdesavtal eller motsvarande).\\n\\n7. Överföring utanför EU/EES\\n\\nVissa mottagare kan finnas i länder utanför EU/EES (t.ex. USA). Vi säkerställer lämpliga skyddsåtgärder, t.ex. Standardavtalsklausuler (SCC). Du kan kontakta oss för mer information om tillämpliga skydd.\\n\\n8. Lagringstider\\n• Chattinnehåll: Som standard upp till 12 månader, eller tills du raderar det i appen eller begär radering.\\n• Serverloggar (IP, fel, prestanda): upp till 90 dagar för felsökning/säkerhet.\\n• Kontodata (om tillämpligt): så länge kontot är aktivt och därefter enligt rättsliga krav. Vi kan anonymisera/aggreggera data för statistik.\\n\\n9. Säkerhet\\n\\nVi använder tekniska och organisatoriska åtgärder för att skydda uppgifter, inklusive kryptering i transit (HTTPS), åtkomstkontroller och loggning. Ingen metod är 100 % säker, men vi arbetar kontinuerligt med förbättringar.\\n\\n10. Cookies och lokal lagring (Web)\\n\\nPå webben kan vi använda nödvändiga cookies och/eller localStorage/IndexedDB för inställningar, sessionshantering och cache. Analys- eller marknadsföringscookies används endast om du samtycker.\\n\\n11. Dina rättigheter (GDPR)\\n\\nDu har rätt att:\\n• få tillgång till dina personuppgifter,\\n• begära rättning eller radering,\\n• begära begränsning av behandling,\\n• invända mot behandling som sker med stöd av berättigat intresse,\\n• få dataportabilitet i vissa fall,\\n• återkalla samtycke när behandling grundas på samtycke.\\n\\nKontakta oss på support@sera.chat. Du kan även lämna klagomål till Integritetsskyddsmyndigheten (IMY) eller motsvarande tillsynsmyndighet inom EU.\\n\\n12. Barns integritet\\n\\nSERA riktar sig inte till barn. Om du tror att ett barn under 16 har lämnat uppgifter till oss, kontakta oss så tar vi bort informationen.\\n\\n13. Dina val och kontroller\\n• Du kan när som helst stänga av insamling av krasch/diagnostik (om funktionen finns).\\n• Du kan rensa chatt i appen och be oss radera serverloggar som är kopplade till dig.\\n• Samtycke för AI-behandling: vid första chattanvändningen visar vi en tydlig dialog. Du kan välja att inte fortsätta; då kan vissa funktioner vara begränsade.\\n\\n14. Tredjepartslänkar och källor\\n\\nSERA kan visa källhänvisningar (t.ex. till manualer, dokumentation). Vi ansvarar inte för tredjeparts webbplatser och deras policys.\\n\\n15. Förändringar i policyn\\n\\nVi kan uppdatera denna policy. Ny version publiceras här med uppdaterat datum. Vid väsentliga ändringar informerar vi i appen eller via e-post (om uppgifter finns).\\n\\n16. Kontakt\\n\\nFrågor om integritet? Kontakta: support@sera.chat\\nPostadress: Ullevivägen 45, 746 51 Bålsta';

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
