const express = require("express");
const router = express.Router();
const { registerUser, loginUser } = require("../controllers/auth.controller");
const asyncHandler = require("../utils/asyncHandler");

router.post("/register", asyncHandler(registerUser));
router.post("/login", asyncHandler(loginUser));
module.exports = router;
