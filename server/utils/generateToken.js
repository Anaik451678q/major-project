const jwt = require('jsonwebtoken')

const generateToken = (res, userId) => {
  const payload = {
    userId: userId,
  }
  const token = jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: '1d',
  })
  res.cookie('access_token', token, {
    // sameSite: 'none', // uncomment it while deployment
    sameSite: 'lax', // comment it while deployment
    path: '/',
    expires: new Date(new Date().getTime() + 2 * 60 * 60 * 1000),
    httpOnly: true,
    // secure: true, // uncomment it while deployment
  })
}

module.exports = generateToken