const axios = require('axios');
const FormData = require('form-data');
const parser = require('lambda-multipart-parser'); // <--- NEU

exports.handler = async (event, context) => {
  // --- CORS HEADER ---
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
    // 1. Parse das Event direkt (kein Stream nötig)
    const result = await parser.parse(event);

    if (!result.files || result.files.length === 0) {
      console.error('Keine Datei gefunden in:', result);
      return { statusCode: 400, headers, body: JSON.stringify({ error: 'No file uploaded' }) };
    }

    const audioFile = result.files[0];

    // 2. Weiterleiten an OpenAI
    // Wir senden den Buffer direkt (schneller als Dateisystem)
    const formData = new FormData();
    
    // WICHTIG: Bei Buffern braucht FormData zwingend einen Dateinamen ('recording.m4a')
    formData.append('file', audioFile.content, 'recording.m4a'); 
    formData.append('model', 'whisper-1');
    formData.append('language', 'de');

    const response = await axios.post('https://api.openai.com/v1/audio/transcriptions', formData, {
      headers: {
        ...formData.getHeaders(),
        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
      },
    });

    // 3. Erfolg!
    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({ text: response.data.text }),
    };

  } catch (error) {
    console.error('OpenAI Error:', error.response ? error.response.data : error.message);
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ error: 'Transcription failed', details: error.message }),
    };
  }
};