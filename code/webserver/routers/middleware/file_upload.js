const multer  = require('multer');
const path = require('path');

const fileFilter = (req, file, cb) => {
    if (file.mimetype == 'image/jpeg' || file.mimetype == 'image/png') {
        cb(null, true);
    } else {
        cb(null, false);
    }
}

const upload = multer({ storage: multer.memoryStorage(), fileFilter: fileFilter });

module.exports = upload;
