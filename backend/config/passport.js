var JwtStrategy = require("passport-jwt").Strategy;
var ExtractJwt = require("passport-jwt").ExtractJwt;
var User = require("../models/user");
require("dotenv").config();

module.exports = function (passport) {
  var opts = {};

  opts.secretOrKey = process.env.SECRET || "secret";
  opts.jwtFromRequest = ExtractJwt.fromAuthHeaderAsBearerToken();

  console.log("🛠️ [Passport Boot] Secret key assigned to verify incoming tokens:", opts.secretOrKey === "secret" ? "FALLBACK 'secret'" : "CUSTOM ENV SECRET");

  passport.use(
    new JwtStrategy(opts, async function (jwt_payload, done) {
      console.log("📥 [Passport Strategy] Intercepted incoming payload successfully:", jwt_payload);
      try {
        const userId = jwt_payload._id || jwt_payload.id;
        console.log("🔍 [Passport Strategy] Looking up user in database with ID:", userId);

        const user = await User.findById(userId);
        if (user) {
          console.log("✅ [Passport Strategy] Match found! Authenticated user:", user.email);
          return done(null, user);
        } else {
          console.log("❌ [Passport Strategy] Signature was valid, but ID doesn't match any user in MongoDB.");
          return done(null, false, { message: "User not found in database" });
        }
      } catch (err) {
        console.error("💥 [Passport Strategy] Critical error during DB lookup:", err);
        return done(err, false);
      }
    }),
  );
};