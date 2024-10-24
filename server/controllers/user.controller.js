const User = require("../models/user.model");
const Order = require("../models/order.model");
const ExpressError = require("../utils/ExpressError");

exports.getUser = async (req, res) => {
  const user = await User.findById(req.user._id).select('-password'); // Exclude password field
  if (!user) throw new ExpressError(400, false, 'User was not found')
  res.status(200).json({ success: true, user });
}

exports.getAllOrders = async (req, res) => {
  console.log("first");
  const orders = await Order.find({ userId: req.user._id });
  if (!orders) throw new ExpressError(400, false, 'No orders found')
  console.log(orders);
  res.status(200).json({ success: true, orders });
}
