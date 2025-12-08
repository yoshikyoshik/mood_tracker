const axios = require('axios');
const FormData = require('form-data');
const multiparty = require('multiparty');
const fs = require('fs');

exports.handler = async (event, context) => {
  // --- CORS HEADER START ---
  const headers = {
    'Access-Control-Allow-Origin': '*', // Erlaubt Zugriff von überall (auch localhost)
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS'
  };

  // Preflight Request (OPTIONS) beantworten (wichtig für Browser!)
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers,
      body: ''
    };
  }
  // --- CORS HEADER ENDE ---

  if (event.httpMethod !== 'POST') {
    return { statusCode: 405, headers, body: 'Method Not Allowed' };
  }

  try {
    const form = new multiparty.Form();
    const data = await new Promise((resolve, reject) => {
      form.parse(event, (err, fields, files) => {
        if (err) reject(err);
        resolve({ fields, files });
      });
    });

    if (!data.files.file || data.files.file.length === 0) {
      return { statusCode: 400, headers, body: JSON.stringify({ error: 'No file uploaded' }) };
    }

    const audioFile = data.files.file[0];

    const formData = new FormData();
    formData.append('file', fs.createReadStream(audioFile.path), 'recording.m4a');
    formData.append('model', 'whisper-1');
    formData.append('language', 'de');

    const response = await axios.post('https://api.openai.com/v1/audio/transcriptions', formData, {
      headers: {
        ...formData.getHeaders(),
        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
      },
    });

    return {
      statusCode: 200,
      headers, // <--- WICHTIG: Header auch hier mitsenden!
      body: JSON.stringify({ text: response.data.text }),
    };

  } catch (error) {
    console.error('Error:', error.response ? error.response.data : error.message);
    return {
      statusCode: 500,
      headers, // <--- Und hier auch!
      body: JSON.stringify({ error: 'Transcription failed' }),
    };
  }
};