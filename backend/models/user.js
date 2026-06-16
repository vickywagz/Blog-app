var mongoose = require("mongoose");
var Schema = mongoose.Schema;
var bcrypt = require("bcrypt");

var UserSchema = new Schema(
  {
    name: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
    },
    password: {
      type: String,
      required: true,
    },

    // 🟢 PROFILE SECTIONS
    bio: {
      type: String,
      trim: true,
      default: "",
    },
    profilePicture: {
      type: String,
      default: "", 
    },

    // 🟢 VERIFICATION FLAGS (ACCOUNT SETUP & PASSWORD RESETS)
    isVerified: {
      type: Boolean,
      default: false,
    },
    otpCode: {
      type: String,
      default: null,
    },
    otpExpires: {
      type: Date,
      default: null,
    },

    // 🟢 SECURITY RESET TOKENS
    passwordResetToken: {
      type: String,
      default: null,
    },
    passwordResetExpires: {
      type: Date,
      default: null,
    },
  },
  { timestamps: true },
);

// --- PRE-SAVE PASSWORD HASHING HOOK ---
UserSchema.pre("save", function (next) {
  var user = this;
  // 🟢 FIX: Changed backticks to a standard string literal for bulletproof modification tracking
  if (this.isModified('password') || this.isNew) { 
    bcrypt.genSalt(10, function (err, salt) {
      if (err) {
        return next(err);
      }
      bcrypt.hash(user.password, salt, function (err, hash) {
        if (err) {
          return next(err);
        }
        user.password = hash;
        next();
      });
    });
  } else {
    next();
  }
});

// --- HELPER METHODS ---

// 🟢 MODERNIZED: Uses async/await with bcrypt instead of the old 'cb' callback parameter
UserSchema.methods.comparePassword = async function (password) {
  try {
    const isMatch = await bcrypt.compare(password, this.password);
    return isMatch;
  } catch (err) {
    throw err;
  }
};

// 🟢 NEW: Generates the JWT authentication token right from the user instance
UserSchema.methods.generateJwtToken = function () {
  const jwt = require("jsonwebtoken");
  
  // Replace 'secret' with your real environment variable (e.g., process.env.JWT_SECRET) if configured
  const secretKey = "secret"; 
  
  // Returns standard Bearer string structure for Passport strategy matching
  return "Bearer " + jwt.sign(
    { id: this._id, email: this.email, name: this.name }, 
    secretKey, 
    { expiresIn: "7d" } // Token remains valid for 7 active tracking days
  );
};

module.exports = mongoose.model("User", UserSchema);