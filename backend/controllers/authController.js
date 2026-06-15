const User = require("../models/user");
const Post = require("../models/post"); 
const Notification = require("../models/Notification");
const sendEmail = require("../utils/sendEmail");
const { uploadToCloudinary } = require("../utils/cloudinaryStorage");

// 📦 INTERNAL HELPER HOOK
// Moved to the top so your controller functions can reference it safely
const createNotificationHook = async (recipientId, senderId, type, postId) => {
  try {
    if (!recipientId || !senderId) return;
    // Prevent creating a notification if an author interacts with their own post
    if (recipientId.toString() === senderId.toString()) return;

    const notification = new Notification({
      recipient: recipientId,
      sender: senderId,
      type,
      post: postId,
    });
    await notification.save();
  } catch (error) {
    console.error("Notification Hook Error:", error); // Fails silently to prevent blocking interactions
  }
};

// 🟢 REGISTER A NEW USER & DISPATCH OTP (WITH DEV-MODE LOG FALLBACK)
exports.register = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    if (!name || !email || !password) {
      return res
        .status(400)
        .json({ success: false, msg: "Please provide all fields" });
    }

    let user = await User.findOne({ email });
    if (user) {
      return res
        .status(400)
        .json({ success: false, msg: "User already exists with this email" });
    }

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000);

    user = new User({
      name,
      email,
      password,
      isVerified: false,
      otpCode: otp,
      otpExpires: otpExpires,
    });

    await user.save();

    try {
      await sendEmail({
        email: user.email,
        subject: "Verify your account - The Curator",
        message: `Your verification code is: ${otp}. It expires in 10 minutes.`,
      });

      return res.status(201).json({
        success: true,
        msg: "Registration initiated! Please check your email for the OTP verification code.",
      });
    } catch (emailErr) {
      // 🟢 DEV-MODE BYPASS: Render firewalls block SMTP sockets on free instances.
      // We log the active verification code locally to the console and allow the app to advance.
      console.log("⚠️ Outbound SMTP email delivery failed or was blocked by host.");
      console.log(`🚀 [DEV MODE OTP BYPASS FOR ${user.email}] ➡️ ${otp} ⬅️`);

      return res.status(201).json({
        success: true,
        msg: `[Dev Mode] Registration initiated! Use code ${otp} to verify your account.`,
      });
    }
  } catch (error) {
    console.error(error);
    return res
      .status(500)
      .json({ success: false, msg: "Server error during registration" });
  }
};

// 🟢 VERIFY ACCOUNT OTP
exports.verifyOtp = async (req, res) => {
  try {
    const { email, otpCode } = req.body;

    if (!email || !otpCode) {
      return res
        .status(400)
        .json({
          success: false,
          msg: "Please enter your email and the verification code",
        });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res
        .status(404)
        .json({ success: false, msg: "User profile not found" });
    }

    if (user.isVerified) {
      return res
        .status(400)
        .json({ success: false, msg: "Account has already been verified" });
    }

    if (user.otpCode !== otpCode || new Date() > user.otpExpires) {
      return res
        .status(400)
        .json({ success: false, msg: "Invalid or expired verification code" });
    }

    user.isVerified = true;
    user.otpCode = null;
    user.otpExpires = null;
    await user.save();

    return res.status(200).json({
      success: true,
      msg: "Account verified successfully! You can now log in.",
    });
  } catch (error) {
    console.error(error);
    return res
      .status(500)
      .json({ success: false, msg: "Server error during token verification" });
  }
};

// 🟢 UPDATE USER PROFILE (Name and Bio)
exports.updateProfile = async (req, res) => {
  try {
    if (!req.user || !req.user.id) {
      return res
        .status(401)
        .json({ success: false, msg: "Unauthorized. Please log in." });
    }

    const { name, bio } = req.body;
    const updates = {};

    if (name !== undefined) updates.name = name;
    if (bio !== undefined) updates.bio = bio;

    const updatedUser = await User.findByIdAndUpdate(
      req.user.id,
      { $set: updates },
      { new: true, runValidators: true },
    ).select("-password -otpCode -passwordResetToken");

    if (!updatedUser) {
      return res
        .status(404)
        .json({ success: false, msg: "User profile not found" });
    }

    return res.status(200).json({
      success: true,
      msg: "Profile updated successfully!",
      user: updatedUser,
    });
  } catch (error) {
    console.error(error);
    return res
      .status(500)
      .json({
        success: false,
        msg: "Server error updating profile parameters",
      });
  }
};

// 🟢 UPLOAD PROFILE PICTURE
exports.uploadProfilePicture = async (req, res) => {
  try {
    if (!req.file) {
      return res
        .status(400)
        .json({ success: false, msg: "Please provide an image file" });
    }

    const imageUrl = await uploadToCloudinary(req.file.buffer);

    const updatedUser = await User.findByIdAndUpdate(
      req.user.id,
      { $set: { profilePicture: imageUrl } },
      { new: true },
    ).select("-password -otpCode -passwordResetToken");

    return res.status(200).json({
      success: true,
      msg: "Profile picture updated successfully!",
      profilePicture: imageUrl,
      user: updatedUser,
    });
  } catch (error) {
    console.error(error);
    return res
      .status(500)
      .json({ success: false, msg: "Media cloud upload failed" });
  }
};

// 🟢 INCREMENT VIEWS COUNTER
exports.viewPost = async (req, res) => {
  try {
    const { id } = req.params;

    const updatedPost = await Post.findByIdAndUpdate(
      id,
      { $inc: { viewsCount: 1 } },
      { new: true },
    );

    if (!updatedPost) {
      return res.status(404).json({ success: false, msg: "Post not found" });
    }

    return res
      .status(200)
      .json({ success: true, viewsCount: updatedPost.viewsCount });
  } catch (error) {
    console.error(error);
    return res
      .status(500)
      .json({ success: false, msg: "Server error updating view count" });
  }
};

// 🟢 TOGGLE LIKE STATUS (With Notifications Hook Fixed)
exports.toggleLikePost = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const post = await Post.findById(id);
    if (!post) {
      return res.status(404).json({ success: false, msg: "Post not found" });
    }

    const hasLiked = post.likes.includes(userId);
    let updateOperation;

    if (hasLiked) {
      updateOperation = { $pull: { likes: userId } };
    } else {
      updateOperation = { $addToSet: { likes: userId } };
      // 🟢 Trigger Notification Hook when liked
      await createNotificationHook(post.author_id, userId, "like", post._id);
    }

    const updatedPost = await Post.findByIdAndUpdate(id, updateOperation, {
      new: true,
    });

    return res.status(200).json({
      success: true,
      isLiked: !hasLiked,
      likesCount: updatedPost.likes.length,
    });
  } catch (error) {
    console.error(error);
    return res
      .status(500)
      .json({ success: false, msg: "Server error toggling like status" });
  }
};

// 🟢 TOGGLE SAVE/BOOKMARK STATUS (With Notifications Hook Fixed)
exports.toggleSavePost = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const post = await Post.findById(id);
    if (!post) {
      return res.status(404).json({ success: false, msg: "Post not found" });
    }

    const isSaved = post.savedBy.includes(userId);
    let updateOperation;

    if (isSaved) {
      updateOperation = { $pull: { savedBy: userId } };
    } else {
      updateOperation = { $addToSet: { savedBy: userId } };
      // 🟢 Trigger Notification Hook when bookmarked
      await createNotificationHook(post.author_id, userId, "save", post._id);
    }

    await Post.findByIdAndUpdate(id, updateOperation, { new: true });

    return res.status(200).json({
      success: true,
      isSaved: !isSaved,
      msg: isSaved
        ? "Post removed from bookmarks"
        : "Post saved to bookmarks successfully!",
    });
  } catch (error) {
    console.error(error);
    return res
      .status(500)
      .json({
        success: false,
        msg: "Server error toggling bookmark save status",
      });
  }
};

// 🟢 GET USER NOTIFICATIONS FEED
exports.getNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({ recipient: req.user.id })
      .populate("sender", "name profilePicture")
      .populate("post", "title")
      .sort({ createdAt: -1 });

    return res.status(200).json({
      success: true,
      notifications,
    });
  } catch (error) {
    console.error(error);
    return res
      .status(500)
      .json({
        success: false,
        msg: "Server error retrieving notifications feed",
      });
  }
};

// 🟢 GET ALL POSTS WITH ADVANCED FILTERING, KEYWORD SEARCH, & SORTING
exports.getAdvancedFeed = async (req, res) => {
  try {
    const { search, sort } = req.query;
    let queryCondition = {};

    if (search) {
      queryCondition = {
        $or: [
          { title: { $regex: search, $options: "i" } },
          { body: { $regex: search, $options: "i" } },
        ],
      };
    }

    let postQuery = Post.find(queryCondition).populate(
      "author_id",
      "name profilePicture",
    );

    if (sort === "popular") {
      postQuery = postQuery.sort({ viewsCount: -1 });
    } else if (sort === "liked") {
      postQuery = postQuery.sort({ "likes.length": -1 });
    } else {
      postQuery = postQuery.sort({ createdAt: -1 });
    }

    const posts = await postQuery;

    return res.status(200).json({
      success: true,
      count: posts.length,
      posts,
    });
  } catch (error) {
    console.error(error);
    return res
      .status(500)
      .json({ success: false, msg: "Server error parsing dynamic feed query" });
  }
};

// 🟢 FORGOT PASSWORD - REQUEST RECOVERY CODE
exports.forgotPassword = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ success: false, msg: 'Please provide an email address' });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, msg: 'No account found with this email' });
    }

    // Generate a 6-digit recovery code
    const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
    
    // Set token expiration window to 10 minutes
    user.passwordResetToken = resetCode;
    user.passwordResetExpires = new Date(Date.now() + 10 * 60 * 1000);
    await user.save();

    try {
      await sendEmail({
        email: user.email,
        subject: 'Password Reset Verification Code - The Curator',
        message: `You requested a password reset. Your recovery code is: ${resetCode}. It expires in 10 minutes.`,
      });

      return res.status(200).json({ success: true, msg: 'Recovery code dispatched to your email!' });
    } catch (emailErr) {
      user.passwordResetToken = null;
      user.passwordResetExpires = null;
      await user.save();
      console.error(emailErr);
      return res.status(500).json({ success: false, msg: 'Failed to dispatch recovery email' });
    }
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, msg: 'Server error processing password reset request' });
  }
};

// 🟢 RESET PASSWORD - OVERWRITE FIELD WITH NEW HASH
exports.resetPassword = async (req, res) => {
  try {
    const { email, otpCode, newPassword } = req.body;

    if (!email || !otpCode || !newPassword) {
      return res.status(400).json({ success: false, msg: 'Please enter all fields' });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ success: false, msg: 'User profile not found' });
    }

    // Verify code validation parameters and active time window expiration frames
    if (user.passwordResetToken !== otpCode || new Date() > user.passwordResetExpires) {
      return res.status(400).json({ success: false, msg: 'Invalid or expired recovery code' });
    }

    // Overwrite old value (triggers the pre-save hook automatically to encrypt it)
    user.password = newPassword;
    
    // Clear out recovery token slots from memory completely
    user.passwordResetToken = null;
    user.passwordResetExpires = null;
    await user.save();

    return res.status(200).json({ success: true, msg: 'Password updated successfully! You can now log in.' });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ success: false, msg: 'Server error updating security parameters' });
  }
};