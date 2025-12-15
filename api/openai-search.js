// Serverless route för webbsök/kunskapsbas. Returnerar { items: [{title, snippet, link}] }
// och matchar mot knowledge-data.js. Används av Flutter-klienten via PROXY_SEARCH_URL.

import { knowledge } from './knowledge-data.js';

const serpApiKey = process.env.SERPAPI_KEY;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

function setCors(res) {
  Object.entries(corsHeaders).forEach(([k, v]) => res.setHeader(k, v));
}

function normalize(str) {
  return (str || '').toString().trim().toLowerCase();
}

function tokenize(str) {
  return normalize(str)
    .split(/[\s,.;:()]+/)
    .filter(Boolean);
}

function scoreEntry(entry, tokens, maybeYear) {
  const tags = (entry.tags || []).map(normalize);
  const keywords = (entry.keywords || []).map(normalize);
  let score = 0;

  for (const t of tokens) {
    if (tags.some((tag) => tag.includes(t) || t.includes(tag))) score += 3;
    if (keywords.some((kw) => kw.includes(t) || t.includes(kw))) score += 2;
    if (entry.title && normalize(entry.title).includes(t)) score += 1;
    if (entry.snippet && normalize(entry.snippet).includes(t)) score += 1;
  }

  if (maybeYear && Array.isArray(entry.years) && entry.years.includes(maybeYear)) {
    score += 3;
  }

  return score;
}

async function serpSearch(q) {
  if (!serpApiKey) return null;
  const url = new URL('https://serpapi.com/search.json');
  url.searchParams.set('engine', 'google');
  url.searchParams.set('q', q);
  url.searchParams.set('api_key', serpApiKey);
  url.searchParams.set('num', '8');

  const res = await fetch(url, { headers: { Accept: 'application/json' } });
  if (!res.ok) return null;
  const data = await res.json();
  const organic = Array.isArray(data.organic_results) ? data.organic_results : [];
  if (!organic.length) return null;

  return organic.slice(0, 8).map((it) => ({
    title: it.title,
    snippet: it.snippet || it.description || '',
    link: it.link || it.cached_page_link || '',
  }));
}

export default async function handler(req, res) {
  if (req.method === 'OPTIONS') {
    setCors(res);
    return res.status(200).end();
  }

  if (req.method !== 'GET' && req.method !== 'POST') {
    setCors(res);
    return res.status(405).json({ error: 'Only GET/POST are allowed' });
  }

  const q =
    req.method === 'GET'
      ? req.query.q
      : (typeof req.body === 'string' ? JSON.parse(req.body || '{}') : req.body || {}).q;

  if (!q || !q.trim()) {
    setCors(res);
    return res.status(400).json({ error: 'Missing query (q)' });
  }

  const tokens = tokenize(q);
  const year = (() => {
    const match = q.match(/\b(20\d{2}|19\d{2})\b/);
    return match ? Number(match[1]) : null;
  })();

  const scored = knowledge
    .map((entry) => ({ entry, score: scoreEntry(entry, tokens, year) }))
    .filter((x) => x.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, 6)
    .map(({ entry }) => ({
      title: entry.title,
      snippet: entry.snippet,
      link: entry.link,
    }));

  let items = scored;
  try {
    const serpItems = await serpSearch(q);
    if (serpItems && serpItems.length) {
      items = serpItems;
    }
  } catch (e) {
    // falla tillbaka till knowledge-data
  }

  setCors(res);
  return res.status(200).json({ items });
}
