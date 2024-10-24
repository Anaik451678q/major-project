module.exports = (error, req, res, next) => {
    if (res.headersSent) {
      return;
    }
  
  
    error.statusCode = error.statusCode || 500;
    error.success = error.success || false;
    error.message = error.message || "Internal Server Error";
  
    if (error.name === "CastError" && error.path === "_id") {
      error.statusCode = 400;
      error.message = "Invalid ID";
    }
  
    if (error.name === "TokenExpiredError") {
      error.statusCode = 401;
      error.message = "Session Expired!";
    }
  
    return res.status(error.statusCode).send({
      success: error.success,
      message: error.message,
    });
  };