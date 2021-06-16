import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import '../models/weather_model.dart';

import 'package:flutter/services.dart';

//temp
import '../utils/cache_services.dart';
import '../models/user_model.dart';
import '../models/report_model.dart';
import '../utils/session_services.dart';

/// Issues:
/// 1. Check if weather data has changed in server before sending GET request

class RethinkWeather {
  // Move server variables to a secure configuration file
  static const server_url = 'http://anywhere-forecast.herokuapp.com';
  //static const server_url = '192.168.1.27:3001';
  //static const server_url = '192.168.43.178:3001';
  List<dynamic> municipalityJson = [], provinceJson = [];

  // Singleton constructor
  RethinkWeather._privateConstructor();

  static final RethinkWeather _instance = RethinkWeather._privateConstructor();

  factory RethinkWeather() => _instance;

  Future<void> setData() async {
    String munString = await rootBundle.loadString('lib/assets/municipalities.json');
    String provString = await rootBundle.loadString('lib/assets/provinces.json');

    municipalityJson = await jsonDecode(munString);
    provinceJson = await jsonDecode(provString);
  }

  ///-----

  Future<WeatherModel> fetchWeather(String date, String cityName, String lastModified) async {
    List<String> splitDate = date.split('-');
    String parsedCity = cityName.split(',')[0];
    String tableDate = splitDate[0] + '-' + splitDate[1];

    final Map<String, String> queryParams = {
      'table' : tableDate,
      'id' : '$date-$parsedCity',
    };

    print('$date-$parsedCity');

    final _uriString = '$server_url/weather/data/?id=2021-06-05-Valenzuela,MM';

    final http.Response res = await http.get(
      Uri.parse(_uriString),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        //'Authorization': 'Bearer ' + SessionServices().accessToken,
        'If-Modified-Since': lastModified,
      },
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(res.body));
    } else {
      return null;
    }
  }

  Future<WeatherModel> fetchCurrentWeather(String cityName, String lastModified) async {
    String currDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return fetchWeather(currDate, cityName, lastModified);
  }

  ///-----

  Future<void> submitReport(File imgFile, String location, String description) async {
    var stream  = new http.ByteStream(imgFile.openRead());
    stream.cast();
    var length = await imgFile.length();

    final _uriString = '$server_url/weather/upload-report/';

    var req = http.MultipartRequest('POST',
      Uri.parse(_uriString),
    );

    final mimeType = lookupMimeType(imgFile.path).split('/');

    String accToken = SessionServices().accessToken;
    req.headers['Authorization'] = 'Bearer $accToken';
    req.headers['Content-Type'] = 'multipart/form-data';
    req.fields['location'] = location;
    req.fields['description'] = description;

    print(mimeType);

    var multipartFile = new http.MultipartFile('image', stream, length,
      filename: basename(imgFile.path),
      contentType: MediaType(mimeType[0], mimeType[1]),
    );

    req.files.add(multipartFile);
    var res = await req.send();
    if (res.statusCode == 200 || res.statusCode == 201) {
      print('ah?');
    } else {
      print('eh?');
    }
  }

  // maybe change to future<map>
  Future<Map<String, dynamic>> fetchLatestReports(String loc, String date) async {
    print(SessionServices().refreshToken);

    String refToken = SessionServices().refreshToken;
    String _url = '$server_url/weather/latest-reports/?location=$loc';

    final res = await http.get(
      Uri.parse(_url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $refToken',
      },
    );

    print(res.body[0]);
    Map<String, dynamic> reports = jsonDecode(res.body);

    print(reports);
    print(reports['last_fetch']);
    List<Report> parsedReports = new List<Report>();

    try {
      for (var i = 0; i < reports['result'].length; i++) {
        parsedReports.add(Report.fromJson(reports['result'][i]));
      }
    } catch(error) {}

    print(parsedReports.length);

    return {
      'reports': parsedReports,
      'last_fetch': reports['last_fetch'],
    };
  }

  Future<void> fetchReportImage(String filename) async {

  }

  // ignore: missing_return
  String getTitle(String _cityName) {
    List<String> _parsedName = _cityName.split(',');

    // Returns city name
    for (var item in provinceJson) {
      if (item['key'] == _parsedName[1]) {
        return (_parsedName[0] + ', ' + item['name']);
      }
    }
  }

  // ignore: missing_return
  String getKey(String _cityName) {
    List<String> _parsedName = _cityName.split(',');

    // Returns province acronym
    for (var item in provinceJson) {
      if (item['name'] == _parsedName[1])
        return (_parsedName[0] + ',' + item['key']);
    }
  }

  List<Object> get props => [municipalityJson, provinceJson];
}
