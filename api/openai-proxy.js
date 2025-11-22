// Simple Vercel serverless proxy to OpenAI chat completions.
// Expects OPENAI_API_KEY to be set in the Vercel project settings.

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

export default async function handler(req, res) {
  if (req.method === 'OPTIONS') {
    return res.status(200).set(corsHeaders).end();
  }

  if (req.method !== 'POST') {
    return res.status(405).set(corsHeaders).json({ error: 'Only POST is allowed' });
  }

  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    return res.status(500).set(corsHeaders).json({ error: 'Missing OPENAI_API_KEY' });
  }

  try {
    const body = typeof req.body === 'string' ? JSON.parse(req.body) : req.body || {};

    const upstream = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify(body),
    });

    const text = await upstream.text();
    let data;
    try {
      data = JSON.parse(text);
    } catch (_) {
      data = { raw: text };
    }

    return res.status(upstream.status).set(corsHeaders).json(data);
  } catch (err) {
    return res.status(500).set(corsHeaders).json({ error: String(err) });
  }
}
