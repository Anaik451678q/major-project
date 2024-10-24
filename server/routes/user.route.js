const express = require('express')
const router = express.Router()
const userController = require('../controllers/user.controller')
const asyncHandler = require('../utils/asyncHandler')
const { checkAuth } = require('../middleware/authMiddleware')

router.get('/get-user', checkAuth, asyncHandler(userController.getUser))
router.get('/all-orders', checkAuth, asyncHandler(userController.getAllOrders))

module.exports = router