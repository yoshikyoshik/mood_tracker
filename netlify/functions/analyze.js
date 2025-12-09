const axios = require('axios');

exports.handler = async (event, context) => {
  // --- CORS HEADER (Damit die App zugreifen darf) ---
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS'
  };

  if (event.httpMethod === 'OPTIONS') {
    return { statusCode: 200, headers, body: '' };
  }

  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, headers, body: 'Method Not Allowed' };
  }

  try {
    // 1. Daten aus der App empfangen
    const body = JSON.parse(event.body);
    const entriesText = body.entriesText; // Der Text-Blob deiner Woche

    if (!entriesText) {
      return { statusCode: 400, headers, body: JSON.stringify({ error: 'No text provided' }) };
    }

    // 2. Den perfekten Prompt für den Coach bauen
    const systemPrompt = `
      Du bist ein empathischer, psychologischer Coach. 
      Analysiere die folgenden Tagebuch-Einträge der letzten Woche.
      Suche nach Mustern zwischen Stimmung (Score 1-10), Schlaf, Zyklus und den Aktivitäten/Notizen.
      
      Struktur deine Antwort so:
      1. 🗓️ **Zusammenfassung**: Wie war die Woche generell?
      2. 💡 **Auffälligkeiten**: Was beeinflusst die Stimmung (positiv/negativ)?
      3. 🥑 **Tipp**: Ein konkreter, kleiner Ratschlag für nächste Woche.
      
      Antworte direkt an den Nutzer ("Du hast..."). Sei kurz und prägnant.
    `;

    // 3. Anfrage an OpenAI (ChatGPT)
    const response = await axios.post('https://api.openai.com/v1/chat/completions', {
      model: "gpt-3.5-turbo", // Oder "gpt-4" für noch bessere Ergebnisse (etwas teurer)
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: entriesText }
      ],
      temperature: 0.7,
    }, {
      headers: {
        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
      },
    });

    // 4. Antwort zurücksenden
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ result: response.data.choices[0].message.content }),
    };

  } catch (error) {
    console.error('OpenAI Error:', error.response ? error.response.data : error.message);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: 'Analysis failed' }),
    };
  }
};