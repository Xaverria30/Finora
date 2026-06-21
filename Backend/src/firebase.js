const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const keyPath = path.join(__dirname, '../firebase-key.json');

if (fs.existsSync(keyPath)) {
  const serviceAccount = require(keyPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
} else {
  admin.initializeApp();
}

const db = admin.firestore();
const auth = admin.auth();

function firebaseAuthRequest(endpoint, body) {
  const https = require('https');
  return new Promise((resolve, reject) => {
    const apiKey = process.env.FIREBASE_API_KEY;
    if (!apiKey) {
      return reject(new Error('FIREBASE_API_KEY environment variable is not configured.'));
    }
    const url = endpoint.includes('?') ? `${endpoint}&key=${apiKey}` : `${endpoint}?key=${apiKey}`;
    const parsedUrl = new URL(url);

    const data = JSON.stringify(body);
    const options = {
      hostname: parsedUrl.hostname,
      path: parsedUrl.pathname + parsedUrl.search,
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length,
      },
    };

    const req = https.request(options, (res) => {
      let responseBody = '';
      res.on('data', (chunk) => {
        responseBody += chunk;
      });
      res.on('end', () => {
        try {
          const parsed = JSON.parse(responseBody);
          if (res.statusCode >= 400) {
            reject({ status: res.statusCode, error: parsed.error || parsed });
          } else {
            resolve(parsed);
          }
        } catch (e) {
          reject({ status: res.statusCode, error: responseBody });
        }
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    req.write(data);
    req.end();
  });
}

module.exports = {
  admin,
  db,
  auth,
  firebaseAuthRequest
};
