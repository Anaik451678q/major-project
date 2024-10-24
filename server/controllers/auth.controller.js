const User = require("../models/user.model");
const bcrypt = require("bcrypt");
const ExpressError = require("../utils/ExpressError");
const jwt = require('jsonwebtoken')

// Controller function for user registration
exports.registerUser = async (req, res) => {
  const { name, phoneNumber, password } = req.body;
  console.log(req.body)
  // Validate input
  if (name==="" || phoneNumber==="" || password==="") {
    throw new ExpressError(400, false, "All fields are required");
  }

  // Check if user already exists
  const existingUser = await User.findOne({ phoneNumber });
  if (existingUser) {
    throw new ExpressError(400, false, "User already exists");
  }

  // Check if this is the first user
  const isFirstUser = await User.countDocuments() === 0;

  // Create new user
  const newUser = new User({
    name,
    phoneNumber,
    password,
    isAdmin: isFirstUser, // Set isAdmin to true if this is the first user
  });

  // Save user to the database
  await newUser.save();

  // Respond with success message
  res.status(201).json({ success: true, message: "User registered successfully" });
};

exports.loginUser = async (req, res) => {
  const { phoneNumber, password } = req.body;

  const user = await User.findOne({ phoneNumber });
  if (!user) return res.status(404).json({ error: 'User not found' });

  const isPasswordValid = await bcrypt.compare(password, user.password);
  if (!isPasswordValid) return res.status(401).json({ error: 'Invalid credentials' });

  const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET, { expiresIn: '1h' });
  res.json({ token });
}


