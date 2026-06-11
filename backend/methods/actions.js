var User = require("../models/user");
var Post = require("../models/post"); 
var jwt = require("jwt-simple");
require("dotenv").config();

var functions = {
  addNew: async function (req, res) {
    try {
      if (!req.body.name || !req.body.password) {
        return res.status(400).json({ success: false, msg: "Enter all fields" });
      }

      const user = await User.findOne({ name: req.body.name });
      
      if (user) {
        return res.status(400).json({ success: false, msg: "Username already exists" });
      }

      var newUser = new User({
        name: req.body.name,
        password: req.body.password,
      });

      await newUser.save();
      return res.json({ success: true, msg: "Successfully Saved" });

    } catch (err) {
      return res.status(500).json({
        success: false,
        msg: "There is a Problem saving the user account",
      });
    }
  },

  authenticate: async function (req, res) {
    try {
      const user = await User.findOne({ name: req.body.name });
      
      if (!user) {
        return res.status(403).send({ success: false, msg: "User not found" });
      }

      user.comparePassword(req.body.password, function (err, isMatch) {
        if (err) {
          return res.status(500).send({ success: false, msg: "Error checking password" });
        }
        
        if (isMatch) {
          var token = jwt.encode(
            {
              _id: user._id,
              name: user.name,
              createdAt: user.createdAt,
              updatedAt: user.updatedAt,
            },
            process.env.SECRET,
          );
          return res.json({ success: true, token: token });
        } else {
          return res.status(403).send({
            success: false,
            msg: "Authentication failed. Wrong password.",
          });
        }
      });
    } catch (err) {
      return res.status(500).send({ success: false, msg: "Server authentication error" });
    }
  },

  getinfo: function (req, res) {
    if (req.user) {
      return res.json({
        success: true,
        msg: "Hello " + req.user.name,
        id: req.user._id,
        name: req.user.name,
        createdAt: req.user.createdAt,
        updatedAt: req.user.updatedAt,
      });
    } else {
      return res.status(401).json({ success: false, msg: "Unauthorized" });
    }
  },

  // 📝 UPGRADED TO SUPPORT IMAGE ATTACHMENTS
  addPost: async function (req, res) {
    if (!req.body.title || !req.body.body || !req.body.author || !req.body.author_id) {
      return res.status(400).json({ success: false, msg: "Please enter all fields" });
    } 
    
    try {
      var newPost = new Post({
        title: req.body.title,
        body: req.body.body,
        author: req.body.author,
        author_id: req.body.author_id,
        postImage: req.body.postImage || "", // 📷 Captures the optional Cloudinary image URL from Flutter
      });

      await newPost.save();
      return res.json({ success: true, msg: "Post saved successfully", post: newPost });
    } catch (err) {
      return res.status(500).json({
        success: false,
        msg: `There is a problem saving your post: ${err.message}`,
      });
    }
  },

  // Redundant but safe to leave as fallback alternative
  getAllPost: async function (req, res) {
    try {
      const posts = await Post.find({});
      return res.json(posts);
    } catch (err) {
      return res.status(500).json({
        success: false,
        msg: "There was a problem retrieving posts",
      });
    }
  },

  getPostbyId: async function (req, res) {
    try {
      // Adjusted from .find() to .findById() for cleaner object retrieval instead of lists
      const post = await Post.findById(req.params.id);
      if (!post) return res.status(404).json({ success: false, msg: "Post not found" });
      return res.json(post);
    } catch (err) {
      return res.status(500).json({
        success: false,
        msg: "There was a problem retrieving the post",
      });
    }
  },

  getPostbyAuthorId: async function (req, res) {
    try {
      const posts = await Post.find({ author_id: req.params.id });
      return res.json(posts);
    } catch (err) {
      return res.status(500).json({
        success: false,
        msg: "There was a problem retrieving posts",
      });
    }
  },

  searchPost: async function (req, res) {
    try {
      var title = req.params.title;
      const posts = await Post.find({ title: { $regex: `${title}`, $options: "i" } });
      return res.json(posts);
    } catch (err) {
      return res.status(500).json({
        success: false,
        msg: "There was a problem searching posts: " + err.message,
      });
    }
  },

  deletePost: async function (req, res) {
    try {
      await Post.deleteOne({ _id: req.params.id });
      return res.json({ success: true, msg: "Post Deleted" });
    } catch (err) {
      return res.status(500).json({
        success: false,
        msg: "There was an error deleting your post",
      });
    }
  },

  updatePost: async function (req, res) {
    try {
      await Post.updateOne(
        { _id: req.params.id },
        {
          $set: {
            title: req.body.title,
            body: req.body.body,
            author: req.body.author,
            author_id: req.body.author_id,
            postImage: req.body.postImage, // Keeps image properties intact on updates
          },
        }
      );
      return res.json({ success: true, msg: "Post updated" });
    } catch (err) {
      return res.status(500).json({
        success: false,
        msg: "There was an error updating your post",
      });
    }
  },
};

module.exports = functions;