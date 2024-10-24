const { default: mongoose } = require("mongoose");

const orderSchema = new mongoose.Schema(
  {
    orderId: { type: String, unique: true },
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    collectionDate: { type: Date, required: true},
    deliveryDate: { type: Date, required: true },
    amount: { type: Number, required: true },
    paymentStatus: {
      type: Boolean,
      required: true,
      default: false,
    },
    weight: { type: Number, required: true },
  },
  { timestamps: true }
);

const generateOrderId = async () => {
  let orderId;
  const existingIds = await Order.find().select('orderId'); // Fetch existing order IDs
  const existingIdSet = new Set(existingIds.map(order => order.orderId)); // Set for faster lookup

  // Generate a new orderId until it's unique
  do {
    orderId = Math.random().toString(36).substring(2, 8).toUpperCase(); // Generate a random 6-character ID
  } while (existingIdSet.has(orderId));

  return orderId;
};

// Pre-save hook to generate unique orderId before saving the order
orderSchema.pre('save', async function (next) {
  if (!this.orderId) {
    this.orderId = await generateOrderId(); // Generate unique orderId
  }
  next();
});

const Order = mongoose.model("Order", orderSchema);

module.exports = Order;
