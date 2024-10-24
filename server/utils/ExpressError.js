class ExpressError extends Error {
    constructor(statusCode, success, message) {
      super(message);
      this.statusCode = statusCode;
      this.success = success;
      this.message = message;
      this.isOperational = true;
      Error.captureStackTrace(this, this.constructor);
    }
  }
  
  module.exports = ExpressError; 