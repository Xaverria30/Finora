const express = require('express');
const { db, auth, firebaseAuthRequest } = require('../firebase');
const { validateFirebaseToken } = require('../middleware');

const router = express.Router();

function sanitizeUser(uid, data) {
  const now = new Date().toISOString();
  return {
    id: uid,
    name: data.name || data.displayName || data.email?.split('@')[0] || 'User',
    email: data.email || '',
    currency: data.currency || 'IDR',
    photoUrl: data.photoUrl || null,
    createdAt: data.createdAt || now,
    updatedAt: data.updatedAt || now
  };
}

router.post('/register', async (req, res) => {
  const { email, password, name, currency, displayName } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    const authData = await firebaseAuthRequest(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp',
      { email, password, returnSecureToken: true }
    );

    const uid = authData.localId;

    const userRef = db.collection('users').doc(uid);
    const userData = {
      uid,
      email,
      name: name || displayName || email.split('@')[0],
      displayName: name || displayName || email.split('@')[0],
      currency: currency || 'IDR',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    await userRef.set(userData);

    res.status(201).json({
      message: 'User registered successfully',
      uid,
      idToken: authData.idToken,
      accessToken: authData.idToken,
      refreshToken: authData.refreshToken,
      expiresIn: authData.expiresIn,
      user: sanitizeUser(uid, userData)
    });
  } catch (err) {
    console.error(err);
    const status = err.status || 500;
    const details = err.error || err.message || 'Internal Server Error';
    res.status(status).json({ error: details });
  }
});

router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    const authData = await firebaseAuthRequest(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword',
      { email, password, returnSecureToken: true }
    );

    const uid = authData.localId;

    const userDoc = await db.collection('users').doc(uid).get();
    const userData = userDoc.exists ? userDoc.data() : { uid, email };

    res.status(200).json({
      message: 'Login successful',
      uid,
      idToken: authData.idToken,
      accessToken: authData.idToken,
      refreshToken: authData.refreshToken,
      expiresIn: authData.expiresIn,
      user: sanitizeUser(uid, userData)
    });
  } catch (err) {
    console.error(err);
    const status = err.status || 500;
    const details = err.error || err.message || 'Internal Server Error';
    res.status(status).json({ error: details });
  }
});

router.post('/refresh', async (req, res) => {
  const { refreshToken } = req.body;
  if (!refreshToken) {
    return res.status(400).json({ error: 'Refresh token is required' });
  }

  try {
    const url = 'https://securetoken.googleapis.com/v1/token';
    const authData = await firebaseAuthRequest(url, {
      grant_type: 'refresh_token',
      refresh_token: refreshToken
    });

    res.status(200).json({
      idToken: authData.id_token,
      accessToken: authData.id_token,
      refreshToken: authData.refresh_token,
      expiresIn: authData.expires_in,
      uid: authData.user_id
    });
  } catch (err) {
    console.error(err);
    const status = err.status || 500;
    const details = err.error || err.message || 'Internal Server Error';
    res.status(status).json({ error: details });
  }
});

router.post('/logout', validateFirebaseToken, async (req, res) => {
  try {
    await auth.revokeRefreshTokens(req.user.uid);
    res.status(200).json({ message: 'Logout successful' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.post('/change-password', validateFirebaseToken, async (req, res) => {
  const { currentPassword, newPassword } = req.body;
  if (!currentPassword || !newPassword) {
    return res.status(400).json({ error: 'currentPassword and newPassword are required' });
  }

  try {
    // Ambil email user dari Firestore untuk re-autentikasi
    const userDoc = await db.collection('users').doc(req.user.uid).get();
    if (!userDoc.exists) {
      return res.status(404).json({ error: 'User not found' });
    }
    const userEmail = userDoc.data().email;

    // Verifikasi password lama via Firebase Identity Toolkit
    await firebaseAuthRequest(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword',
      { email: userEmail, password: currentPassword, returnSecureToken: false }
    );

    // Ganti password via Firebase Admin SDK
    await auth.updateUser(req.user.uid, { password: newPassword });
    res.status(200).json({ message: 'Password updated successfully' });
  } catch (err) {
    console.error(err);
    // Error dari Firebase Identity Toolkit saat verifikasi password lama
    const errorCode = err?.error?.message || err?.message || '';
    if (errorCode.includes('INVALID_PASSWORD') || errorCode.includes('INVALID_LOGIN_CREDENTIALS')) {
      return res.status(401).json({ error: 'Password lama tidak sesuai' });
    }
    const status = err.status || 500;
    const details = err.error || err.message || 'Internal Server Error';
    res.status(status).json({ error: details });
  }
});

router.post('/reset-password', async (req, res) => {
  const { email, newPassword } = req.body;
  if (!email || !newPassword) {
    return res.status(400).json({ error: 'email and newPassword are required' });
  }
  if (newPassword.length < 6) {
    return res.status(400).json({ error: 'Password harus minimal 6 karakter' });
  }

  try {
    // Cari user berdasarkan email di Firebase Auth
    let userRecord;
    try {
      userRecord = await auth.getUserByEmail(email);
    } catch (err) {
      // Jangan ungkapkan apakah email terdaftar atau tidak (keamanan)
      return res.status(200).json({ message: 'Jika email terdaftar, password berhasil direset.' });
    }

    // Reset password langsung via Firebase Admin SDK (tanpa email verification)
    await auth.updateUser(userRecord.uid, { password: newPassword });

    // Revoke semua refresh token agar sesi lama tidak bisa digunakan lagi
    await auth.revokeRefreshTokens(userRecord.uid);

    res.status(200).json({ message: 'Password berhasil direset.' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});


module.exports = router;