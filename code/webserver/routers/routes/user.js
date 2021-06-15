const express = require('express');
const router = express.Router();
const UserController = require('../controllers/UserController');
const auth = require('../middleware/authentication');

router.get('/get-user', auth.auth_access, UserController.getUserData);
router.get('/refresh-session', auth.auth_refresh, UserController.refreshUser);
router.get('/logout-user', auth.delete_refresh, UserController.logoutUser);

router.post('/register', UserController.registerUser);
router.post('/login', UserController.loginUser);
router.post('/add-location', UserController.subscribeLoc);
router.post('/remove-location', UserController.unsubscribeLoc);

module.exports = router;