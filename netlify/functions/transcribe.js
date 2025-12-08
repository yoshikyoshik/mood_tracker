const axios = require('axios');
const FormData = require('form-data');
const multiparty = require('multiparty');
const fs = require('fs');

exports.handler = async (event, context) => {
  // Nur POST erlauben
  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, body: 'Method Not Allowed' };
  }

  try {
    // 1. Das Audio-File aus dem Request parsen
    const form = new multiparty.Form();
    const data = await new Promise((resolve, reject) => {
      form.parse(event, (err, fields, files) => {
        if (err) reject(err);
        resolve({ fields, files });
      });
    });

    if (!data.files.file || data.files.file.length === 0) {
      return { statusCode: 400, body: JSON.stringify({ error: 'No file uploaded' }) };
    }

    const audioFile = data.files.file[0];

    // 2. Weiterleiten an OpenAI Whisper
    const formData = new FormData();
    formData.append('file', fs.createReadStream(audioFile.path), 'recording.m4a');
    formData.append('model', 'whisper-1');
    formData.append('language', 'de'); // Erzwingt Deutsch (optional, aber gut für Akzente)

    const response = await axios.post('https://api.openai.com/v1/audio/transcriptions', formData, {
      headers: {
        ...formData.getHeaders(),
        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
      },
    });

    // 3. Text zurücksenden
    return {
      statusCode: 200,
      body: JSON.stringify({ text: response.data.text }),
    };

  } catch (error) {
    console.error('Error:', error.response ? error.response.data : error.message);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Transcription failed' }),
    };
  }
};