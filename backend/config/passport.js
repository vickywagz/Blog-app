var JwtStrategy = require("passport-jwt").Strategy;
var ExtractJwt = require("passport-jwt").ExtractJwt;
var User = require("../models/user");
require("dotenv").config();

module.exports = function (passport) {
  var opts = {};

  // 🟢 FIX: Forces a universal "secret" fallback matching your user model signing process
  opts.secretOrKey = process.env.SECRET || "secret";
  opts.jwtFromRequest = ExtractJwt.fromAuthHeaderAsBearerToken();

  passport.use(
    new JwtStrategy(opts, async function (jwt_payload, done) {
      try {
        // Fallback to .id if ._id does not exist in the token payload
        const userId = jwt_payload._id || jwt_payload.id;

        const user = await User.findById(userId);
        if (user) {
          return done(null, user);
        } else {
          return done(null, false);
        }
      } catch (err) {
        return done(err, false);
      }
    }),
  );
};