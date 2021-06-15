const express = require('express');
const router = express.Router();
const WeatherController = require('../controllers/WeatherController');
const auth = require('../middleware/authentication');
const upload = require('../middleware/file_upload');

router.get('/data', WeatherController.getByID);
router.get('/images', WeatherController.getReportImage);
router.get('/latest-reports', auth.auth_refresh, WeatherController.getLatestReports);

router.post('/upload-report', auth.auth_access, upload.single('image'), WeatherController.uploadReport);

module.exports = router;
