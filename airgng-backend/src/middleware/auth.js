const jwt = require('jsonwebtoken');

function bacaToken(req) {
  const header = req.headers.authorization || '';
  if (!header.startsWith('Bearer ')) return null;
  try {
    return jwt.verify(header.slice(7), process.env.JWT_SECRET);
  } catch (_) {
    return null;
  }
}

// Token boleh ada boleh tidak (mis. halaman Jelajahi bisa dilihat tanpa login)
function opsional(req, res, next) {
  req.pengguna = bacaToken(req);
  next();
}

// Wajib login
function wajib(req, res, next) {
  const pengguna = bacaToken(req);
  if (!pengguna) {
    return res.status(401).json({ message: 'Silakan masuk terlebih dahulu.' });
  }
  req.pengguna = pengguna;
  next();
}

module.exports = { opsional, wajib };
