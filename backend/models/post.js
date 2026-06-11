var mongoose = require("mongoose");
var Schema = mongoose.Schema;

var PostSchema = new Schema(
  {
    title: {
      type: String,
      required: true,
    },
    body: {
      type: String,
      required: true,
    },
    author: {
      type: String,
      required: true,
    },
    author_id: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    postImage: { // 🟢 FIX: Renamed from 'image' to 'postImage' to perfectly match action.js
      type: String,
      default: "", 
    },

    // 🟢 METRICS & INTERACTIONS
    viewsCount: {
      type: Number,
      default: 0,
    },
    likes: [
      {
        type: Schema.Types.ObjectId,
        ref: "User",
      },
    ],
    savedBy: [
      {
        type: Schema.Types.ObjectId,
        ref: "User",
      },
    ],
  },
  {
    timestamps: true,
  },
);

// 🟢 PERFORMANCE INDEXING
PostSchema.index({ title: "text", body: "text" });

module.exports = mongoose.model("Post", PostSchema);