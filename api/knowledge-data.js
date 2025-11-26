// Enkel kunskapsbas som proxyn kan använda för att svara på /api/openai-search.
// Lägg till fler poster i arrayen nedan – de används för att skapa sammanfattningar
// som sedan skickas vidare till klienten (Flutter) och in i OpenAI-prompten.
//
// Fält:
// - title: kort rubrik på källan
// - snippet: 1–2 meningar som beskriver innehållet
// - link: källa eller referens (kan vara intern URL)
// - tags: nyckelord (t.ex. märke/modell/system)
// - years: valfria årsmodeller som posten gäller för
// - keywords: extra nyckelord att matcha på (symptom, system, etc.)
export const knowledge = [
  {
    title: 'Exempel: Volvo EC250E servicehydraulik',
    snippet: 'Tryckmätning: hydraulpump A 310 bar, pump B 305 bar. Kontrollera filtret om trycket avviker ±15 bar.',
    link: 'https://example.com/manuals/volvo-ec250e-hydraulik',
    tags: ['volvo', 'ec250e', 'hydraulik'],
    years: [2018, 2019, 2020, 2021],
    keywords: ['hydraultryck', 'pump', 'filter'],
  },
  {
    title: 'Exempel: CAT 320 GC startsystem',
    snippet: 'Startproblem? Kontrollera batteri >12.4V, kablage till startrelä och ECU-koder MID 039.',
    link: 'https://example.com/manuals/cat-320gc-start',
    tags: ['cat', '320 gc', 'start'],
    years: [2017, 2018, 2019, 2020],
    keywords: ['startar inte', 'relä', 'batteri'],
  },
  {
    title: 'Brun ABC – mörk display/panel',
    snippet: 'Displayen är mörk: 1) Huvudströmbrytare/batteri: minst 22.7 V (≥11.35 V per batteri) under last. '
        + '2) Kontrollera säkring för display/ICM och jordpunkt (rengör/drag åt). '
        + '3) Mät spänning vid panelens matning, ska vara batterispänning. '
        + '4) Inspektera kontaktdon och kabelstam för fukt/korrosion.',
    link: '',
    tags: ['brun', 'abc', 'display', 'el'],
    years: [2017, 2018, 2019, 2020],
    keywords: ['mörk', 'svart', 'display', 'panel', 'instrument', 'säkring', 'batteri', 'jord', 'volt'],
  },
];
