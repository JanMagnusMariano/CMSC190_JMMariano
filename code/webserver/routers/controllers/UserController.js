const fstore = require('firebase-admin');
const moment = require('moment');

const auth = require('../middleware/authentication');
const token = require('../../services/jwt-jsonwebtoken');
const CustomError = require ('../../services/custom_error');

const date_format = moment();
const user_db = fstore.firestore().collection('users');

// User Route Functions

async function registerUser(req, res, next) {
	var reg_users = await user_db.doc(req.body.id).get();
	if (reg_users.exists) return next(new CustomError('User already exists', 401));

	auth.hash_password(req.body.password).then(async (hash) => {
		var rawDate = new Date();
		var isoDate = (rawDate.toISOString().replace('Z', ''));

		req.body['last_modified'] = isoDate;
		req.body['last_online'] = isoDate;
		req.body['password'] = hash;

		await user_db.doc(req.body.id).set(req.body).then((result) => res.status(201).json(req.body));
	});
}

async function loginUser(req, res, next) {
	var reg_users = await user_db.doc(req.body.email).get();
	if (!reg_users.exists) return next(new CustomError('User does not exist', 401));
	var user_data = reg_users.data();

	auth.auth_password(req.body.password, user_data['password']).then(async (authenticated) => {
		if(authenticated) {
			const curr_user = {
				email: user_data['id'],
				access: token.generateAccess(user_data['id']),
				refresh: token.generateRefresh(user_data['id']),
				last_online: user_data['last_online'],
			};

			return res.status(201).json(curr_user);
		} else return next(new CustomError('User authentication failed', 401));
	});
}

async function refreshUser(req, res) {
	req.data.access = token.generateAccess(req.data.email);
	return res.status(201).json(req.data);
}

function logoutUser(req, res) {
	return res.sendStatus(201);
}

async function getUserData(req, res) {
	var reg_users = await user_db.doc(req.query.email).get();
	res.status(201).json(reg_users.data());
}

async function subscribeLoc(req, res, next) {
	var reg_users = await user_db.doc(req.body.email).get();
	var user_data = reg_users.data();
	if(user_data['subbed_locs'].includes(req.body.location)) {
		return next(new CustomError('Subscribe location failed', 401));
	} else {
		user_data['subbed_locs'].push(req.body.location);
		await user_db.doc(req.body.email).update({'subbed_locs' : user_data['subbed_locs']});
		res.status(201).json(user_data);
	}
}

async function unsubscribeLoc(req, res, next) {
	var reg_users = await user_db.doc(req.body.email).get();
	var user_data = reg_users.data();
	if(!user_data['subbed_locs'].includes(req.body.location)) {
		return next(new CustomError('Unsubscribe location failed', 401));
	} else {
		var index = user_data['subbed_locs'].findIndex(e => e == req.body.location);
		user_data['subbed_locs'].splice(index, 1);
		await user_db.doc(req.body.email).update({'subbed_locs' : user_data['subbed_locs']});
		res.status(201).json(user_data);
	}
}

module.exports = {
	registerUser,
	loginUser,
	refreshUser,
	logoutUser,
	getUserData,
	subscribeLoc,
	unsubscribeLoc,
}
