const express = require("express");
const action = require("../methods/actions"); // Your existing core actions
const authAction = require("../controllers/authController"); // Our new security controller
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
router.get(
  "/getinfo",
  passport.authenticate("jwt", { session: false }),
  action.getinfo,
);
router.patch(
  "/update-profile",
  passport.authenticate("jwt", { session: false }),
  authAction.updateProfile
);
router.patch(
  "/update-profile-picture",
  passport.authenticate("jwt", { session: false }), // 🔒 Guards route session
  upload.single('image'),                          // 📷 Multer intercepts 'image' multipart binary
  authAction.uploadProfilePicture
);

// Add these right alongside your other post routing lines in index.js

// 📈 Views tracker (Public - no login required, runs whenever a user taps a post card)
router.patch("/post/:id/view", authAction.viewPost);

// ❤️ Likes Toggle (Secure - requires login)
router.post(
  "/post/:id/like",
  passport.authenticate("jwt", { session: false }),
  authAction.toggleLikePost
);

// 🔖 Bookmarks Toggle (Secure - requires login)
router.post(
  "/post/:id/save",
  passport.authenticate("jwt", { session: false }),
  authAction.toggleSavePost
);

// Add this right alongside your other authenticated user routes in index.js

router.get(
  "/notifications",
  passport.authenticate("jwt", { session: false }), // 🔒 Securely protects your activity feed
  authAction.getNotifications
);

// 🛡️ --- NEW OTP & ACCOUNT RECOVERY PIPELINE ---
// Matches the chronological Phase 2 steps we built
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