var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var NotificationSchema = new Schema(
    {
        recipient: {
            type: Schema.Types.ObjectId,
            ref: 'User',
            required: true // The author who owns the post getting the interaction
        },
        sender: {
            type: Schema.Types.ObjectId,
            ref: 'User',
            required: true // The user who tapped the heart or bookmark icon
        },
        type: {
            type: String,
            enum: ['like', 'save'], // Easily expandable if you add 'comment' or 'follow' later
            required: true
        },
        post: {
            type: Schema.Types.ObjectId,
            ref: 'Post',
            required: true // The post that was interacted with
        },
        isRead: {
            type: Boolean,
            default: false
        }
    },
    {
        timestamps: true // Automatically gives us 'createdAt' so Flutter can show "2 minutes ago"
    }
);

module.exports = mongoose.model('Notification', NotificationSchema);