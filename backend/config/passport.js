var JwtStrategy = require('passport-jwt').Strategy
var ExtractJwt = require('passport-jwt').ExtractJwt

var User = require('../models/user')
require('dotenv').config()

module.exports = function (passport) {
    var opts = {}

    opts.secretOrKey = process.env.SECRET
    opts.jwtFromRequest = ExtractJwt.fromAuthHeaderAsBearerToken()

    passport.use(new JwtStrategy(opts, function (jwt_payload, done) {
        User.findById(jwt_payload._id, function (err, user) {
            if (err) {
                return done(err, false)
            }
            if (user) {
                return done(null, user)
            } else {
                return done(null, false)
            }
        })
    }))
}