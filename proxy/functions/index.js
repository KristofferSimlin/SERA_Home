import express from "express";
import fetch from "node-fetch";

const app = express();
app.use(express.json());

const OPENAI_API_KEY = process.env.OPENAI_API_KEY;

app.post("/chat", async (req, res) => {
  try {
    if (!OPENAI_API_KEY) return res.status(500).json({ error: "Missing OPENAI_API_KEY" });
    const { messages = [], model = "gpt-4o-mini", temperature = 0.2 } = req.body || {};

    const r = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${OPENAI_API_KEY}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ model, messages, temperature, stream: false })
    });

    if (r.status === 401) return res.status(401).json({ error: "Unauthorized to OpenAI" });
    if (!r.ok) {
      const t = await r.text();
      return res.status(r.status).json({ error: "Upstream error", detail: t });
    }

    const data = await r.json();
    const choice = data?.choices?.[0]?.message?.content ?? "";
    return res.json({ text: choice });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Proxy internal error" });
  }
});

app.get("/healthz", (_, res) => res.json({ ok: true }));

const port = process.env.PORT || 8080;
app.listen(port, () => console.log(`SERA proxy listening on :${port}`));
