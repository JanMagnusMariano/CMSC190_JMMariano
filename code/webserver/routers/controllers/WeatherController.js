const { v4: uuidv4 } = require('uuid');
const moment = require('moment');
const fstore = require('firebase-admin');
const path = require('path');

const forecast_db = fstore.firestore().collection('forecast_files');
const report_db = fstore.firestore().collection('weather_reports');
const user_db = fstore.firestore().collection('users');
const _bucket = fstore.storage().bucket();

// Weather Route functions

async function getByID(req, res, next) {
	var _query = req.query.id.split('-');
	var _month = _query[0] + '-' + _query[1];
	var _city = _query[3];

	var report = await forecast_db.doc(_month).collection(_city).doc(req.query.id).get();
	var report_data = report.data();

	// Maybe check if null
	if (req.headers['if-modified-since'] == '') {
		res.status(201).json(report_data);
	} else if (report_data['last_modified'] > req.headers['if-modified-since']){
		res.status(201).json(report_data);
	} else {
		res.sendStatus(304);
	}
}

async function uploadReport(req, res, next) {
  try {
		var _filename = uuidv4();
		var _file = _bucket.file(_filename);

		await _file.save(req.file.buffer, {
			contentType: req.file.mimetype,
			gzip: true
		});

		_file.makePublic();
		var _url = _file.publicUrl();

		var rawDate = new Date();
    var isoDate = (rawDate.toISOString().replace('Z', ''));
		var _month = rawDate.getFullYear() + '-' + pad2(rawDate.getMonth() + 1);
		var _id = _month + '-' + pad2(rawDate.getDate()) + '-' + req.body.location;

  	const newUpload = {
			report_loc: req.body.location,
			description: req.body.description,
			filename: _filename,
			date_uploaded: isoDate,
			path: _url,
			size: req.file.size,
    };

    var tableName = rawDate.getFullYear() + '-' + ('0' + (rawDate.getMonth() + 1)).slice(-2);
		await report_db.doc(_month).collection(newUpload.report_loc).doc(_id).set({[isoDate] : newUpload}, {merge : true});
		return res.status(201).json(newUpload);
  } catch (err) {
		return res.sendStatus(401);
  }
}

async function getLatestReports(req, res, next) {
    try {
        var rawDate = new Date();
        var isoDate = (rawDate.toISOString().replace('Z', ''));

				// Make last_online a query parameter
				var user = await user_db.doc(req.data['email']).get();
				var _lastAccess = user.get('last_online');
				var _month = _lastAccess.toString().substring(0, 7);
				var _day = _lastAccess.toString().substring(0, 10)
				var _reports = [];

				var _idList = await report_db.doc(_month).collection(req.query.location).listDocuments();

				for (var i = 0; i < _idList.length; i++) {
					if (_idList[i].id >= _day) {
						var _docRef = await _idList[i].get();
						var _docRefData = _docRef.data();
						var _keys = Object.keys(_docRefData);

						for (var j = 0; j < _keys.length; j++) {
							if (_lastAccess < _keys[j]) {
								_reports.push(_docRefData[_keys[j]]);
							}
						}
					}
				}

				return res.status(201).json({'result': _reports, 'last_fetch': isoDate});
    } catch (err) {
        return res.sendStatus(400);
    }
}

function getReportImage(req, res, next) {
	var fname = req.query.path;
}

// Utility functions
function pad2(n) {
  return (n < 10 ? '0' : '') + n;
}

module.exports = {
	getByID,
    uploadReport,
    getLatestReports,
    getReportImage,
}
