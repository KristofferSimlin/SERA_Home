// proxy/functions/index.js (ESM)
import express from "express";
import fetch from "node-fetch";
import cors from "cors";

const app = express();
app.use(express.json({ limit: "1mb" }));
app.use(cors()); // underlättar för Flutter Web/localhost

const OPENAI_API_KEY = process.env.OPENAI_API_KEY;
const SERPAPI_KEY = process.env.SERPAPI_KEY; // valfri för /search

// ---- Hjälp: robust JSON-fel ----
function badRequest(res, msg) {
  return res.status(400).json({ error: msg });
}
function upstreamError(res, r, body) {
  return res.status(r.status).json({ error: "Upstream error", status: r.status, body });
}

// ---- Hälso-koll ----
app.get("/healthz", (_, res) => res.json({ ok: true }));

// ---- /chat -> vidarebefordra till OpenAI Chat Completions ----
app.post("/chat", async (req, res) => {
  try {
    if (!OPENAI_API_KEY) return res.status(500).json({ error: "Missing OPENAI_API_KEY" });

    const { messages, model = "gpt-4o-mini", temperature = 0.2, stream = false } = req.body || {};
    if (!Array.isArray(messages) || messages.length === 0) {
      return badRequest(res, "messages[] required");
    }
    if (stream) {
      return badRequest(res, "Server stream inte aktiverad i denna proxy");
    }

    const r = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${OPENAI_API_KEY}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ model, messages, temperature, stream: false }),
    });

    const txt = await r.text();
    if (r.status === 401) return res.status(401).json({ error: "Unauthorized to OpenAI" });
    if (!r.ok) return upstreamError(res, r, txt);

    const data = JSON.parse(txt);
    const choice = data?.choices?.[0]?.message?.content ?? "";
    return res.json({ text: choice });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Proxy internal error" });
  }
});

// ---- /search -> enkel sökproxy (SerpAPI eller DDG fallback) ----
app.get("/search", async (req, res) => {
  try {
    const q = (req.query.q || "").toString().trim();
    if (!q) return badRequest(res, "query ?q= saknas");

    if (SERPAPI_KEY) {
      const u = new URL("https://serpapi.com/search.json");
      u.searchParams.set("engine", "google");
      u.searchParams.set("q", q);
      u.searchParams.set("num", "5");
      u.searchParams.set("api_key", SERPAPI_KEY);

      const r = await fetch(u.toString());
      const j = await r.json();
      const items = (j.organic_results || []).slice(0, 5).map(x => ({
        title: x.title, snippet: x.snippet, link: x.link
      }));
      return res.json({ items });
    }

    // Fallback: DuckDuckGo Lite (kan vara skört över tid)
    const r = await fetch("https://lite.duckduckgo.com/lite/?q=" + encodeURIComponent(q), {
      headers: { "User-Agent": "Mozilla/5.0 (SERA Proxy)" },
    });
    const html = await r.text();

    // Superenkel scraping
    const re = /<a[^>]+href="([^"]+)"[^>]*>([^<]+)<\/a>[^<]*<br\/>\s*([^<]+)<br\/>/gi;
    const items = [];
    let m;
    while ((m = re.exec(html)) && items.length < 5) {
      items.push({ title: m[2], snippet: m[3], link: m[1] });
    }
    return res.json({ items });
  } catch (e) {
    console.error(e);
    return res.status(500).json({ error: "Search error" });
  }
});

const port = process.env.PORT || 8080;
app.listen(port, () => console.log(`SERA proxy listening on :${port}`));
