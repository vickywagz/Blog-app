const express = require("express");
const action = require("../methods/actions"); 
const authAction = require("../controllers/authController"); 
const router = express.Router();
const passport = require('passport');
const { upload } = require('../utils/cloudinaryStorage');

router.get("/", (req, res) => {
  res.send("THIS IS HOME");
});

router.get("/dashboard", (req, res) => {
  res.send("THIS IS DASHBOARD");
});

// 🔐 --- EXISTING AUTHENTICATION ROUTING ---
router.post("/adduser", action.addNew);
router.post("/authenticate", authAction.login);

// 🔍 DIAGNOSTIC OVERRIDE FOR GETINFO:
router.get("/getinfo", function (req, res, next) {
  console.log("🚨 [Routes /getinfo] Request hit endpoint.");
  console.log("📦 [Routes /getinfo] Raw Incoming Headers:", req.headers);

  passport.authenticate("jwt", { session: false }, function (err, user, info) {
    console.log("🕵️‍♂️ [Passport Hook Debug] Inner Error:", err);
    console.log("🕵️‍♂️ [Passport Hook Debug] Returned User:", user ? user.email : "NULL");
    console.log("🕵️‍♂️ [Passport Hook Debug] Failure Context (info):", info);

    if (err) { 
      console.log("💥 [Passport Hook] Middleware threw an unhandled error.");
      return next(err); 
    }
    
    if (!user) { 
      console.log("🚫 [Passport Hook] Denied entry. Returning 401 response explicitly.");
      return res.status(401).json({
        success: false,
        message: "Unauthorized",
        debug_info: info ? info.message : "Token verification failed natively"
      });
    }

    console.log("🚀 [Passport Hook] Verification passed! Handing off execution to action.getinfo...");
    req.user = user;
    return action.getinfo(req, res);
  })(req, res, next);
});

router.patch(
  "/update-profile",
  passport.authenticate("jwt", { session: false }),
  authAction.updateProfile
);
router.patch(
  "/update-profile-picture",
  passport.authenticate("jwt", { session: false }), 
  upload.single('image'),                          
  authAction.uploadProfilePicture
);

router.patch("/post/:id/view", authAction.viewPost);

router.post(
  "/post/:id/like",
  passport.authenticate("jwt", { session: false }),
  authAction.toggleLikePost
);

router.post(
  "/post/:id/save",
  passport.authenticate("jwt", { session: false }),
  authAction.toggleSavePost
);

router.get(
  "/notifications",
  passport.authenticate("jwt", { session: false }), 
  authAction.getNotifications
);

// 🛡️ --- NEW OTP & ACCOUNT RECOVERY PIPELINE ---
router.post("/register", authAction.register);
router.post("/verify-otp", authAction.verifyOtp);
router.post("/forgot-password", authAction.forgotPassword);
router.post("/reset-password", authAction.resetPassword);

// 📝 --- EXISTING POST ROUTING ---
router.post("/addpost", action.addPost);
router.get("/getallpost", authAction.getAdvancedFeed);
router.get("/getpostbyid/:id", action.getPostbyId);
router.get("/getpostbyauthorid/:id", action.getPostbyAuthorId);
router.get("/searchpost/:title", action.searchPost);
router.delete("/deletepost/:id", action.deletePost);
router.put("/updatepost/:id", action.updatePost);

module.exports = router;