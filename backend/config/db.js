const mongoose = require('mongoose')
require('dotenv').config()

const ConnectDB = async () => {
    try {
        const conn = await mongoose.connect(process.env.DB_URI)

        console.log(`MongoDB Connected : ${conn.connection.host}`)
    } catch (e) {
        console.log(e)
        process.exit(1)
    }
}

module.exports = ConnectDB