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
UserSchema.methods.comparePassword = function (password, cb) {
  bcrypt.compare(password, this.password, function (err, isMatch) {
    if (err) {
      return cb(err);
    }
    cb(null, isMatch);
  });
};

module.exports = mongoose.model("User", UserSchema);