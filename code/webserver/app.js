const express = require('express');
const logger = require('morgan');
const bodyParser = require('body-parser');
const cors = require('cors');

const firebase = require('firebase-admin');

// Change this to env?
//const serviceAccount = require('./weather-anywhere-jmmariano-firebase-adminsdk-2rf1e-4024a5cf53.json');
require('dotenv').config();

firebase.initializeApp({
	credential: firebase.credential.cert({
		projectId: process.env.FIREBASE_PROJECT_ID,
		client_email: process.env.FIREBASE_CLIENT_EMAIL,
		private_key: process.env.FIREBASE_PRIVATE_KEY
	}),
	storageBucket: process.env.FIREBASE_BUCKET,
});

const User = require('./routers/routes/user');
const Weather = require('./routers/routes/weather');
const helmet = require('helmet');
const rateLimit = require("express-rate-limit");
var xss = require('xss-clean')

const config = require('./config/config');

const app = express();

app.use(logger('dev'));
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(cors());

// Routes
app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.use('/user', User);
app.use('/weather', Weather);

app.use(xss()); // Data Sanitization against XSS
app.use(helmet()); // Give your project special HTTP headers using helmet dependency.

//End app security
app.use(function (error, request, response, next) {
    response.status(error.code || 500);
    response.json({ error: error.message });
});

app.listen(process.env.PORT || config.port, function () {
    console.log('App is listening on port 5000');
});
