var mongoose = require('mongoose')
var Schema = mongoose.Schema

var PostSchema = new Schema(
    {
        title : {
            type : String,
            required : true,
        },
        body : {
            type : String,
            required : true,
        },
        author : {
            type : String,
            required : true,
        },
        author_id : {
            type : String,
            required : true
        }
    },
    {
        timestamps : true
    }
)

module.exports = mongoose.model('Post',PostSchema)