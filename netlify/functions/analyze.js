const axios = require('axios');

exports.handler = async (event, context) => {
  // CORS Header... (wie bisher)
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS'
  };

  if (event.httpMethod === 'OPTIONS') return { statusCode: 200, headers, body: '' };
  if (event.httpMethod !== 'POST') return { statusCode: 405, headers, body: 'Method Not Allowed' };

  try {
    const body = JSON.parse(event.body);
    const entriesText = body.entriesText;
    
    // NEU: Sprache aus dem Request lesen (Fallback: Deutsch)
    const userLang = body.language || 'de'; 

    if (!entriesText) {
      return { statusCode: 400, headers, body: JSON.stringify({ error: 'No text provided' }) };
    }

    // NEU: System Prompt dynamisch generieren
    let systemPrompt = "";
    
    if (userLang.startsWith('en')) {
        systemPrompt = `You are an empathetic psychological coach. Analyze the diary entries. 
        Find patterns between mood (1-10), sleep, and tags.
        Structure: 1. 🗓️ Summary, 2. 💡 Insights, 3. 🥑 Tip. Keep it short. Address the user directly.`;
    } else if (userLang.startsWith('es')) {
        systemPrompt = `Eres un coach psicológico empático. Analiza las entradas del diario.
        Busca patrones entre el estado de ánimo (1-10), el sueño y las etiquetas.
        Estructura: 1. 🗓️ Resumen, 2. 💡 Observaciones, 3. 🥑 Consejo. Sé breve.`;
    } else if (userLang.startsWith('zh')) {
        systemPrompt = `你是一位富有同理心的心理教练。分析日记条目。
        寻找心情 (1-10)、睡眠和标签之间的模式。
        结构：1. 🗓️ 总结，2. 💡 观察，3. 🥑 建议。保持简短。`;
    } else if (userLang.startsWith('ru')) {
        systemPrompt = `Ты — эмпатичный психологический коуч. Проанализируй записи дневника.
        Ищи закономерности между настроением (1-10), сном и тегами.
        Структура: 1. 🗓️ Обзор, 2. 💡 Наблюдения, 3. 🥑 Совет. Будь краток.`;
    } else {
        // Fallback Deutsch
        systemPrompt = `Du bist ein empathischer, psychologischer Coach. Analysiere die Tagebuch-Einträge.
        Suche nach Mustern zwischen Stimmung (1-10), Schlaf und Tags.
        Struktur: 1. 🗓️ Zusammenfassung, 2. 💡 Auffälligkeiten, 3. 🥑 Tipp. Sei kurz.`;
    }

    const response = await axios.post('https://api.openai.com/v1/chat/completions', {
      model: "gpt-3.5-turbo",
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

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ result: response.data.choices[0].message.content }),
    };
  } catch (error) {
    // Error Handling...
    return { statusCode: 500, headers, body: JSON.stringify({ error: error.message }) };
  }
};