var JwtStrategy = require("passport-jwt").Strategy;
var ExtractJwt = require("passport-jwt").ExtractJwt;
var User = require("../models/user");
require("dotenv").config();

module.exports = function (passport) {
  var opts = {};

  opts.secretOrKey = process.env.SECRET;
  opts.jwtFromRequest = ExtractJwt.fromAuthHeaderAsBearerToken();

  passport.use(
    new JwtStrategy(opts, async function (jwt_payload, done) {
      try {
        // 🟢 FIX: Fallback to .id if ._id does not exist in the token payload
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
