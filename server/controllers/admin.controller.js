const Order = require('../models/order.model'); // Import the Order model
const User = require('../models/user.model');   // Import the User model (for validation)

// Controller to create a new order
exports.newOrder = async (req, res) => {
    const { 
        collectionDate, 
        collectionTime, 
        deliveryDate, 
        deliveryTime, 
        amount, 
        weight, 
        phoneNumber 
    } = req.body;

    console.log(req.body);

    // Validate required fields
    if (!deliveryDate || !deliveryTime || !collectionDate || !collectionTime || !amount || !weight) {
      throw new ExpressError(400, false, 'All fields are required')
    }

    const user = await User.findOne({ phoneNumber });
    if (!user) {
      throw new ExpressError(400, false, 'User not found')
    }

    // Create a new order
    const newOrder = new Order({
      userId: user._id,
      collectionDate,
      collectionTime,
      deliveryDate,
      deliveryTime,
      amount,
      weight,
    });

    // Save the order to the database
    await newOrder.save();

    res.status(200).json({ success: true, message: 'Order created successfully', order: newOrder });
};

// Controller to get all orders
exports.getAllOrders = async (req, res) => {
    const orders = await Order.find().sort({ createdAt: -1 });
    return res.status(200).json({ success: true, orders });
};

// Controller to update an order
exports.updateOrder = async (req, res) => {
    const { orderId } = req.params;
    const { collectionDate, deliveryDate, amount, weight, paymentStatus, wash_weight } = req.body;

    // Find the order by orderId
    const order = await Order.findOne({ orderId });

    if (!order) {
      throw new ExpressError(404, false, 'Order not found')
    }

    // Update the order fields
    if (collectionDate) order.collectionDate = collectionDate;
    if (deliveryDate) order.deliveryDate = deliveryDate;
    if (amount) order.amount = amount;
    if (weight) order.weight = weight;
    if (paymentStatus !== undefined) order.paymentStatus = paymentStatus;
    if (wash_weight !== undefined) order.wash_weight = wash_weight;

    // Save the updated order
    await order.save();

    return res.status(200).json({ success: true, message: 'Order updated successfully', order });
};

// Controller to get all users
exports.getAllUsers = async (req, res) => {
    const users = await User.find();
    return res.status(200).json({ success: true, users });
};

exports.getOrderById = async (req, res) => {
    const { orderId } = req.body;
    const order = await Order.findOne({ orderId }).lean();
    if (!order) {
      throw new ExpressError(404, false, 'Order not found')
    }
    const user = await User.findById(order.userId).lean();
    if (!user) {
      throw new ExpressError(404, false, 'User not found')
    }
    order.name = user.name;
    order.phoneNumber = user.phoneNumber;
    return res.status(200).json({ success: true, order });
};

// Add a new controller for updating wash weight
exports.updateWashWeight = async (req, res) => {
    const { orderId, wash_weight } = req.body;

    if (!wash_weight) {
      throw new ExpressError(400, false, 'Wash weight is required')
    }

    const order = await Order.findOne({ orderId });
    if (!order) {
      throw new ExpressError(404, false, 'Order not found')
    }

    order.wash_weight = wash_weight;
    await order.save();

    return res.status(200).json({ 
      success: true, 
      message: 'Wash weight updated successfully', 
      order 
    });
};

// Add a new controller for updating payment status
exports.updatePaymentStatus = async (req, res) => {
    const { orderId, paymentStatus } = req.body;

    if (paymentStatus === undefined) {
      throw new ExpressError(400, false, 'Payment status is required')
    }

    const order = await Order.findOne({ orderId });
    if (!order) {
      throw new ExpressError(404, false, 'Order not found')
    }

    order.paymentStatus = paymentStatus;
    await order.save();

    return res.status(200).json({ 
      success: true, 
      message: 'Payment status updated successfully', 
      order 
    });
};

