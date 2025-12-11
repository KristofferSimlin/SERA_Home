import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../features/chat/chat_controller.dart';

const String _defaultProxyUrlHost = 'https://api.sera.chat/api/openai-proxy';
const String _defaultProxyUrlWeb = '/api/openai-proxy';

const String _baseSystemPrompt =
    'Du är SERA – en säkerhetsmedveten felsökningsassistent för maskiner.'
    '\nSTIL: Rak, professionell, jordnära. Inga artighetsfraser.'
    '\nEKO: Upprepa inte användarens text. Citera kort endast vid behov.'
    '\nTON: Svenska. Korta stycken, punktlistor när det passar.'
    '\nBETEENDE: Ställ 1–2 följdfrågor vid oklarheter. Ge tydliga nästa steg.'
    '\nSÄKERHET: Lägg alltid till Säkerhetsfilter om el/hydraulik/bränsle/tryck/värme berörs.'
    '\nKÄLLOR: När du får extern kunskap (WEBB-TRÄFFAR), använd den som primär fakta. Återge värden, steg och formuleringar så nära källan som möjligt, undvik att sammanfatta bort detaljer.'
    '\nTABELLER: Behåll flera meningar per cell om de finns; radbryt i celler hellre än att ta bort innehåll.'
    '\nSERVICE-SCHEMA: Om användaren ber om service-/underhållsschema, svara med tydliga checklistor och punktlistor (använd Markdown - [ ] för avbockning). Inga felsökningstabeller då; håll fokus på servicepunkter och säkerhetssteg.'
    '\nUNDVIK: "Som en AI", överdriven artighet, ursäkter.';

const String _level1Prompt = '''
EXPERTIS=1 (nybörjare) — använd denna struktur, var pedagogisk och förklara även självklara kontroller.
KONTEKST: Maskintyp, fabrikat/modell, system/problemområde. Fyll från UTRUSTNING och användartext; om saknas, fråga kort.
MÅL: Super grundlig, steg-för-steg, förklara varför varje kontroll görs.
STRUKTUR:
1) Kort introduktion (2–3 meningar, nybörjare).
2) Säkerhet först: punktlista med varför (LOTO, avstängning, tryckavlastning, stöd/stöttor/lyftpunkter, parkeringsläge, PPE).
3) Översiktlig felsökningsstrategi: 5–7 punkter (enkla kontroller → visuellt → mätningar → demontering).
3b) Vanliga felbilder (kortlista 4–8 rader): Symptom → sannolik orsak → snabbtest/mätning → tolkning → åtgärd. Anpassa efter systemområdet, håll det kompakt.
4) Tabell (minst 8–10 symptomrader, hela meningar): Symptom | Trolig orsak | Kontroll/test (steg-för-steg) | Verktyg/mätinstrument | Normalt värde/förväntat resultat | Åtgärd/reparation. Var generös med orden per cell (2–3 meningar där det behövs). Tillåt 1–3 troliga orsaker per symptom genom att lägga flera rader med samma Symptom men olika orsaker/tester. Inkludera grundkontroller (bränslenivå, huvudströmbrytare, nödstopp, oljor, läckage, säkringar/reläer, kontakter).
5) Steg-för-steg-flöde med om/annars-hänvisning och kort “varför”.
6) (Valfritt) Minilexikon för termer (matarpump, givare, jordpunkt, CAN-bus m.m.).
7) Vanliga misstag & tips (t.ex. byta delar innan mätning, inte mäta under last).
SPRÅK: Tydlig svensk verkstadston, vänlig/proffsig.
AVSLUT: Kort notis om att komplettera med tillverkarens manualer och säkerhetsföreskrifter.
''';

const String _level2Prompt = '''
EXPERTIS=2 (medel) — mekanikern kan grunderna, fokus på logisk struktur och mätning.
KONTEKST: Maskintyp, fabrikat/modell, system/problemområde. Fyll från UTRUSTNING och användartext; fråga kort om saknas.
MÅL: Komprimerad men tydlig felsökning med mätpunkter och typiska felbilder.
STRUKTUR:
1) Kort introduktion (2–3 meningar, mekaniker med viss erfarenhet).
2) Säkerhet: kort lista (LOTO, tryckavlastning, lyft/säkring, PPE).
3) Översiktlig strategi (4–6 punkter): snabba uppenbara orsaker → visuell kontroll → systematiska mätningar (spänning/tryck/flöde/motstånd) → diagnos/felkoder → ev. demontering/byte.
3b) Vanliga felbilder (kort lista 4–8 rader): Symptom → sannolik orsak → test/mätpunkt → tolkning → åtgärd. Anpassa efter systemområdet, håll det kompakt.
4) Tabell (minst 8–10 symptomrader, hela meningar): Symptom | Trolig orsak | Kontroll/test | Verktyg/mätinstrument | Gränsvärden/normalvärden | Rekommenderad åtgärd. Var generös med ord per cell (2–3 meningar vid behov). Tillåt 1–3 troliga orsaker per symptom genom att repetera Symptom-raden med olika orsaker/tester. Lägg mer vikt vid mätpunkter, givare, kontakter, reläer, ventiler, tryckbegränsning/pilottryck/interna läckage.
5) Steg-för-steg-flöde med om → gå till steg X. Referera till mätvärden.
6) Vanliga felbilder & fällor (jordpunkter, kabelbrott i böj, interna läckage, etc.).
SPRÅK: Teknisk svenska, kompaktare än nivå 1.
AVSLUT: Kort notis om att verifiera mot tillverkarens manual/serviceinfo/säkerhetsföreskrifter.
''';

const String _level3Prompt = '''
EXPERTIS=3 (expert) — hoppa över nybörjarbasics. Gå direkt på avancerad diagnos.
KONTEKST: Maskintyp, fabrikat/modell, system/problemområde. Fyll från UTRUSTNING och användartext; om saknas, fråga kort och precist.
VIKTIGT: Inga triviala kontroller (bränsle, huvudbrytare, nödstopp, oljenivå, synliga skador) om inte uttryckligen efterfrågat.
STRUKTUR:
1) Kort introduktion (1–2 meningar, direkt på sak).
2) Säkerhet (3–5 punkter): trycksatta system, högspänning, lagrad energi, lyft/infästning.
3) Felsökningsstrategi för expert: systematisk uteslutning, mätning under last, felkod/logg-analys, kända svagheter.
3b) Vanliga felbilder (kort lista 4–8 rader, avancerat): Symptom → rotorsak/felbild → test/mätpunkt → gränsvärde/tolkning → åtgärd. Anpassa efter systemområdet.
4) Avancerad tabell (minst 8–10 symptomrader, hela meningar): Symptom | Trolig rotorsak/felbild | Diagnostiskt test (mätpunkter) | Mätvärden/gränsvärden | Tolkning | Rekommenderad åtgärd. Var generös med ord per cell och fokusera på spänningsfall under start, ECU-matning/jord, tryck vid testportar, pilottryck, interna bypass, CAN/kommunikation. Tillåt 1–3 rotorsaker per symptom genom att använda flera rader med samma Symptom men olika orsaker/tester.
5) Steg-för-steg flöde (kort): om/annars-logik med mättrösklar.
6) Kända svagheter & typiska rotorsaker (kabelstammar, givare som drar buss, ventiler som kärvar, firmware-buggar).
SPRÅK: Kort, teknisk svenska för proffs. Fackspråk OK.
AVSLUT: Kort neutral notis att verifiera mot verkstadshandbok/elschema/serviceinfo för aktuellt serienummer.
''';

String _expertiseAddon(int? level) {
  switch (level) {
    case 1:
      return _level1Prompt;
    case 2:
      return _level2Prompt;
    case 3:
      return _level3Prompt;
    default:
      return '\nEXPERTIS=okänd: fråga kort om nivå, annars anta medel.';
  }
}

String _equipmentAddon({String? brand, String? model, String? year}) {
  final parts = <String>[];
  if ((brand ?? '').isNotEmpty) parts.add('Märke: $brand');
  if ((model ?? '').isNotEmpty) parts.add('Modell: $model');
  if ((year ?? '').isNotEmpty) parts.add('Årsmodell: $year');
  if (parts.isEmpty) {
    return '\nUTRUSTNING: okänd (be användaren om märke, modell, årsmodell).';
  }
  return '\nUTRUSTNING: ${parts.join(', ')}';
}

String _webNotesAddon(String? webNotes) {
  if (webNotes == null || webNotes.trim().isEmpty) return '';
  return '\nWEBB-TRÄFFAR (använd som primär källa, behåll formuleringar och detaljer – undvik att sammanfatta bort information):\n$webNotes';
}

String _postProcess(String s) {
  final polite = RegExp(
    r'^(tack(?: så mycket)?(?: för att du| för info| för information)?|'
    r'hoppas allt är bra|tack för ditt meddelande|tack för att du hör av dig)[\.\!\,\s\-–—:]*',
    caseSensitive: false,
  );
  var out = s.trimLeft().replaceFirst(polite, '');
  final echo =
      RegExp(r'^(du (säger|skriver|nämner) att[:\s]+)', caseSensitive: false);
  out = out.replaceFirst(echo, '');
  return out.trimLeft();
}

String _contentFromList(List<dynamic> content) {
  final buffer = StringBuffer();
  for (final part in content) {
    if (part is String) {
      buffer.write(part);
      continue;
    }
    if (part is Map<String, dynamic>) {
      final textField = part['text'];
      if (textField is String) {
        buffer.write(textField);
        continue;
      }
      if (textField is Map) {
        final value = textField['value'] ?? textField['content'];
        if (value is String) {
          buffer.write(value);
          continue;
        }
      }
      final innerContent = part['content'];
      if (innerContent is String) {
        buffer.write(innerContent);
      }
    }
  }
  return buffer.toString();
}

String _extractText(Map<String, dynamic> data) {
  final choices = data['choices'];
  if (choices is List && choices.isNotEmpty) {
    final first = choices.first;
    final message = first is Map<String, dynamic> ? first['message'] : null;
    if (message is Map<String, dynamic>) {
      final content = message['content'];
      if (content is String && content.trim().isNotEmpty) {
        return content;
      }
      if (content is List && content.isNotEmpty) {
        final combined = _contentFromList(content);
        if (combined.trim().isNotEmpty) return combined;
      }
    }
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    final text = first is Map<String, dynamic> ? first['text'] : null;
    if (text is String && text.trim().isNotEmpty) return text;
  }
  final topLevel =
      data['text'] ?? data['content'] ?? data['reply'] ?? data['response'];
  if (topLevel is String) return topLevel;
  return '';
}

class OpenAIClient {
  final bool useProxy;
  final String? proxyUrl; // /chat
  final String? directKey;

  OpenAIClient({
    required this.useProxy,
    this.proxyUrl,
    this.directKey,
  });

  factory OpenAIClient.fromSettings(SettingsState s) {
    final envProxy = (dotenv.env['PROXY_URL'] ?? '').trim();
    final envKey = dotenv.env['OPENAI_API_KEY'];
    final resolvedProxy = (s.proxyUrl?.isNotEmpty == true)
        ? s.proxyUrl!.trim()
        : (envProxy.isNotEmpty
            ? envProxy
            : (kIsWeb ? _defaultProxyUrlWeb : _defaultProxyUrlHost));
    return OpenAIClient(
      useProxy: s.proxyEnabled,
      proxyUrl: resolvedProxy,
      directKey: s.directApiKey?.isNotEmpty == true ? s.directApiKey : envKey,
    );
  }

  Future<String> completeChat(
    List<(bool, String)> history,
    String newUserMessage, {
    int? expertise,
    String? brand,
    String? model,
    String? year,
    String? webNotes, // sammanfattning från webbsök
  }) async {
    final systemPrompt = _baseSystemPrompt +
        _expertiseAddon(expertise) +
        _equipmentAddon(brand: brand, model: model, year: year) +
        _webNotesAddon(webNotes);

    if (useProxy) {
      if (proxyUrl == null || proxyUrl!.isEmpty) {
        throw 'PROXY_URL saknas. Ange i inställningar eller .env';
      }
      final res = await http.post(
        Uri.parse(proxyUrl!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            ...history.map(
                (e) => {'role': e.$1 ? 'user' : 'assistant', 'content': e.$2}),
            {'role': 'user', 'content': newUserMessage},
          ],
          'model': 'gpt-4o',
          'temperature': 0.2,
        }),
      );
      if (res.statusCode == 401) {
        throw '401 (otillåten). Kontrollera proxy-konfiguration.';
      }
      if (res.statusCode >= 400) {
        throw 'Proxyfel ${res.statusCode}: ${res.body}';
      }
      // Debug-logga proxysvaret för felsökning
      debugPrint('Proxy response: ${res.body}');
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final text = _extractText(data);
      return _postProcess(text.isEmpty ? '[Tomt svar]' : text);
    } else {
      if (directKey == null || directKey!.isEmpty) {
        throw 'OPENAI_API_KEY saknas. Ange i Inställningar eller .env';
      }
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $directKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            ...history.map(
                (e) => {'role': e.$1 ? 'user' : 'assistant', 'content': e.$2}),
            {'role': 'user', 'content': newUserMessage},
          ],
          'temperature': 0.2,
          'stream': false,
        }),
      );
      if (res.statusCode == 401) {
        throw '401 (otillåten). Kontrollera API-nyckeln.';
      }
      if (res.statusCode >= 400) {
        throw 'OpenAI-fel ${res.statusCode}: ${res.body}';
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final text = _extractText(data);
      return _postProcess(text.isEmpty ? '[Tomt svar]' : text);
    }
  }

  Future<String> generateWorkOrder(
    String description, {
    required bool preferSwedish,
  }) async {
    final languageNote = preferSwedish
        ? 'SPRÅK: Svara på svenska när användaren skriver på svenska. Om texten är tydligt på engelska, svara på engelska.'
        : 'LANGUAGE: Reply in English unless the user clearly writes in Swedish, then switch to Swedish.';

    const styleNote =
        'STIL: Kort, rak, verkstadston. Inga artighetsfraser, inga utsvävningar.';

    final systemPrompt = '''
Du är SERA – en serviceledare som sammanfattar utfört arbete till en professionell arbetsorder/rapport.
$styleNote
$languageNote

Mål: Omskriv användarens beskrivning till en kompakt arbetsordertext i preteritum (utfört arbete). Beskriv vad som gjordes, hur, och resultatet. Inga stegvisa instruktioner eller uppmaningar.
Format (Markdown):
- Rubrik: kort, 1 rad, vad som hanterades.
- Objekt: maskin/aggregat/plats (skriv "Okänt" om saknas).
- Händelse/felbild: 1–2 rader om vad som observerades.
- Utfört arbete: 3–6 punkter i preteritum som beskriver åtgärderna (inga uppmaningar).
- Kontroll/resultat: 2–3 punkter om test/utfall.
- Rekommendation/uppföljning (valfritt): kort om ev. efterkontroll eller förebyggande.
Håll texten kompakt med hög informationsdensitet.
''';

    final payload = {
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': description},
      ],
      'model': 'gpt-4o',
      'temperature': 0.18,
    };

    if (useProxy) {
      if (proxyUrl == null || proxyUrl!.isEmpty) {
        throw 'PROXY_URL saknas. Ange i inställningar eller .env';
      }
      final res = await http.post(
        Uri.parse(proxyUrl!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (res.statusCode == 401) {
        throw '401 (otillåten). Kontrollera proxy-konfiguration.';
      }
      if (res.statusCode >= 400) {
        throw 'Proxyfel ${res.statusCode}: ${res.body}';
      }
      debugPrint('Work order proxy response: ${res.body}');
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final text = _extractText(data);
      return _postProcess(text.isEmpty ? '[Tomt svar]' : text);
    } else {
      if (directKey == null || directKey!.isEmpty) {
        throw 'OPENAI_API_KEY saknas. Ange i Inställningar eller .env';
      }
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $directKey',
        },
        body: jsonEncode(payload),
      );
      if (res.statusCode == 401) {
        throw '401 (otillåten). Kontrollera API-nyckeln.';
      }
      if (res.statusCode >= 400) {
        throw 'OpenAI-fel ${res.statusCode}: ${res.body}';
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final text = _extractText(data);
      return _postProcess(text.isEmpty ? '[Tomt svar]' : text);
    }
  }
}
