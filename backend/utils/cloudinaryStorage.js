const cloudinary = require('cloudinary').v2;
const multer = require('multer');

// Configure Cloudinary with your environment credentials
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

// Configure Multer to temporarily store files in memory as buffers before streaming
const storage = multer.memoryStorage();

// Middleware configuration
const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // Limit files to 5MB max
  fileFilter: (req, file, cb) => {
    // Only accept image formats
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'), false);
    }
  }
});

// Helper function to stream memory buffer straight to Cloudinary
const uploadToCloudinary = (fileBuffer) => {
  return new Promise((resolve, reject) => {
    const uploadStream = cloudinary.uploader.upload_stream(
      { folder: 'the_curator_media' }, // Automatically organizes files into this folder
      (error, result) => {
        if (error) return reject(error);
        resolve(result.secure_url); // Returns the safe https:// CDN link
      }
    );
    uploadStream.end(fileBuffer);
  });
};

module.exports = { upload, uploadToCloudinary };