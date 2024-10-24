const express = require('express')
const router = express.Router()
const { checkAuth } = require('../middleware/authMiddleware')
const adminController = require('../controllers/admin.controller')
const asyncHandler = require('../utils/asyncHandler')

router.post('/new-order', checkAuth, asyncHandler(adminController.newOrder))
router.get('/all-orders', checkAuth, asyncHandler(adminController.getAllOrders))
router.post('/update-order/', checkAuth, asyncHandler(adminController.updateOrder))
router.get('/all-users', checkAuth, asyncHandler(adminController.getAllUsers))
router.post('/get-order', checkAuth, asyncHandler(adminController.getOrderById))

module.exports = router