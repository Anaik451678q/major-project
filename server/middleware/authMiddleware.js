const jwt = require('jsonwebtoken')
const User = require('../models/user.model')
const ExpressError = require('../utils/ExpressError')

const checkAuth = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) return res.status(401).json({ authStatus: false, error: 'No token provided' });

  const token = authHeader.split(' ')[1];
  const data = jwt.verify(token, process.env.JWT_SECRET)
  if (!data) {
    return res.status(401).json({ authStatus: false, error: 'Invalid token' });
  }
  console.log(data);
  req.user = await User.findById(data.userId).select('-password')
  if (!req.user) throw new ExpressError(400, false, 'User was not found')

  next();
};

module.exports = { checkAuth }