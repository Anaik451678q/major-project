const { mongoose } = require("mongoose");
const bcrypt = require("bcrypt");
const ExpressError = require("../utils/ExpressError");

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    phoneNumber: { type: String, required: true, trim: true },
    password: { type: String, required: true, trim: true },
    isAdmin: { type: Boolean, default: false },
  },
  { timestamps: true }
);

// Middleware to hash passwords before saving
userSchema.pre("save", async function (next) {
  if (!this.isModified("password")) return next();
  try {
    this.password = await bcrypt.hash(this.password, 10);
    next();
  } catch (err) {
    next(new ExpressError(500, false, "Error hashing the password"));
  }
});

const User = mongoose.model("User", userSchema);

module.exports = User;
