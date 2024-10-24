const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config(); // To load environment variables from .env file
const GlobalErrorHandler = require('./utils/GlobalErrorHandler')
const ExpressError = require('./utils/ExpressError')

const app = express();
const PORT = process.env.PORT || 5000; // Change this to 5000 to match your Flutter app

const connectDB = async () => {
    try {
      mongoose.connect(process.env.MONGO_URI)
      console.log('Connected to Mongo succesfully')
    } catch (err) {
      console.log('Error while connecting to database')
    }
  }
  connectDB()

// Middleware
const corsOptions = {
    origin: '*',
}

app.use(cors(corsOptions)); // Enable CORS
app.use(express.json())
app.use(express.urlencoded({ extended: true })) 

app.get('/api/message', (req, res) => {
  console.log("Received request for /api/message");  // Add this line
  const message = { text: "Hello from the Node.js server!" };
  res.status(200).json(message);
});
// Use user routes
app.use('/api/auth', require('./routes/auth.route'));
app.use('/api/user', require('./routes/user.route'));
app.use('/api/admin', require('./routes/admin.route'));
// wrong routes handler
app.all('*', (req, res, next) => {
    try {
      new ExpressError(404, false, 'Page not found')
    } catch (error) {
      next(error)
    }
  })
  
app.use(GlobalErrorHandler)

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
