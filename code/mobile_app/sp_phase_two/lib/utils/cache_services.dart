import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../models/report_model.dart';
import '../models/user_model.dart';
import '../models/weather_model.dart';

class CacheServices {
  static Database _db;

  // Singleton constructor
  CacheServices._privateConstructor();

  static final CacheServices _instance = CacheServices._privateConstructor();

  factory CacheServices() {
    return _instance;
  }

  // Sqlflite Functions

  Future<void> create() async {
    Directory path = await getApplicationDocumentsDirectory();
    String dbPath = join(path.path, 'database.db');

    _db = await openDatabase(dbPath, version: 1, onCreate: this._create);
  }

  Future _create(Database db, int version) async {
    // Report table
    await db.execute('''
            CREATE TABLE report (
              id INTEGER PRIMARY KEY,
              report_id TEXT,
              date_uploaded TEXT,
              description TEXT,
              report_loc TEXT,
              filename TEXT
            )''');

    // User table
    await db.execute('''
            CREATE TABLE user (
              id INTEGER PRIMARY KEY,
              email TEXT,
              first_name TEXT,
              last_name TEXT,
              last_online TEXT
            )''');

    // Last fetch of a user for a city table
    await db.execute('''
            CREATE TABLE city_fetch (
              id INTEGER PRIMARY KEY,
              city_name TEXT,
              newest_fetch TEXT,
              oldest_fetch TEXT,
              user_email INTEGER,
              FOREIGN KEY (user_email) REFERENCES user (email) 
              ON DELETE NO ACTION ON UPDATE NO ACTION
            )''');

    // Non 'weather' details of weather report
    await db.execute('''
            CREATE TABLE city_weather (
              id INTEGER PRIMARY KEY,
              city_name TEXT,
              latitude NUMERIC,
              longitude NUMERIC,
              last_modified TEXT
            )''');

    await db.execute('''
            CREATE TABLE weather_data (
              id INTEGER PRIMARY KEY,
              dt TEXT,
              pressure INTEGER,
              humidity INTEGER,
              min_temp NUMERIC,
              max_temp NUMERIC,
              weather_id TEXT
            )''');

    await db.execute('''
            CREATE TABLE weather_desc (
              id INTEGER PRIMARY KEY,
              desc_id INTEGER,
              main TEXT,
              description TEXT,
              icon TEXT
            )''');
  }

  ///-----
  /// Weather Cache Functions
  ///-----

  Future<WeatherModel> upsertWeather(WeatherModel weather) async {
    var count = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM city_weather WHERE city_name = ?', [weather.cityName]));

    if (count == 0) {
      weather.id = await _db.insert('city_weather', weather.toMap());
    } else {
      await _db.update('city_weather', weather.toMap(), where: 'id = ?', whereArgs: [weather.id]);
    }

    // Insert current weather and desc
    weather.current.weatherId = 'Current-' + weather.id.toString();
    await upsertWeatherData(weather.current);
    // insert list of hourly weather and desc
    for (var i = 0; i < weather.hourly.length; i++) {
      weather.hourly[i].weatherId = 'Hourly-' + weather.id.toString() + '-' + ((i+1).toString());
      await upsertWeatherData(weather.hourly[i]);
    }
    // insert list of daily weather and desc
    for (var i = 0; i < weather.daily.length; i++) {
      weather.daily[i].weatherId = 'Daily-' + weather.id.toString() + '-' + ((i+1).toString());
      await upsertWeatherData(weather.daily[i]);
    }

    return weather;
  }

  Future<WeatherData> upsertWeatherData(WeatherData data) async {
    var count = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM weather_data WHERE weather_id = ?', [data.weatherId]));

    if (count == 0) {
      data.id = await _db.insert('weather_data', data.toMap());
    } else {
      await _db.update('weather_data', data.toMap(), where: 'id = ?', whereArgs: [data.id]);
    }

    data.weatherDesc.descId = data.id;
    await upsertWeatherDesc(data.weatherDesc);
    return data;
  }

  Future<WeatherDesc> upsertWeatherDesc(WeatherDesc desc) async {
    var count = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM weather_desc WHERE desc_id = ?', [desc.descId]));

    if (count == 0) {
      desc.id = await _db.insert('weather_desc', desc.toMap());
    } else {
      await _db.update('weather_desc', desc.toMap(), where: 'id = ?', whereArgs: [desc.id]);
    }

    return desc;
  }

  Future<WeatherModel> getWeather(String cityName) async {
    List<Map<String, dynamic>> results = (await _db.query('city_weather', columns: WeatherModel.columns, where: 'city_name = ?', whereArgs: [cityName]));

    if (results == null || results.length == 0) return null;
    else {
      WeatherModel weather = WeatherModel.fromMap(results[0]);
      weather.current = (await getWeatherData('Current-' + weather.id.toString()))[0];
      weather.hourly = await getWeatherData('Hourly-' + weather.id.toString() + '-');
      weather.daily = await getWeatherData('Daily-' + weather.id.toString() + '-');
      return weather;
    }
  }

  Future<List<WeatherData>> getWeatherData(String weatherId) async {
    List<Map<String, dynamic>> results = await _db.rawQuery('SELECT * FROM weather_data WHERE weather_id LIKE "$weatherId%"');

    if (results == null || results.length == 0) return null;
    else {
      List<WeatherData> dataList = new List<WeatherData>();
      for (var i = 0; i < results.length; i++) {
        WeatherData data = WeatherData.fromMap(results[i]);
        data.weatherDesc = await getWeatherDesc(data.id);
        dataList.add(data);
      }

      return dataList;
    }
  }

  Future<WeatherDesc> getWeatherDesc(int descId) async {
    List<Map<String, dynamic>> results = (await _db.query('weather_desc', columns: WeatherDesc.columns, where: 'desc_id = ?', whereArgs: [descId]));

    if (results == null || results.length == 0) return null;
    else return WeatherDesc.fromMap(results[0]);
  }

  ///-----
  /// Report Cache Functions
  ///-----

  // Consider having an upload report with list parameter, utilize batch
  Future<Report> upsertReport(Report rep) async {
    var count = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM report WHERE report_id = ?', [rep.reportId]));

    if (count == 0) {
      rep.id = await _db.insert('report', rep.toMap());
    } else {
      await _db.update('report', rep.toMap(), where: "id = ?", whereArgs: [rep.id]);
    }

    print('inserted report to sqlite db');
    return rep;
  }

  // Might change id to reportId
  Future<Report> fetchReportById(int id) async {
    List<Map<String, dynamic>> results = await _db.query('report', columns: Report.columns, where: "id = ?", whereArgs: [id]);

    Report rep = Report.fromJson(results[0]);

    return rep;
  }

  Future<Report> fetchReportByLoc(String loc) async {
    List<Map<String, dynamic>> results = await _db.query('report', columns: Report.columns, where: "report_loc = ?", whereArgs: [loc]);

    Report rep = Report.fromJson(results[0]);

    print('fetch report from sqlite db');
    return rep;
  }

  Future<List<Report>> fetchReportBatch(int lastId, String loc, int limitNum) async {
    List<Map<String, dynamic>> results = await _db.query('report', columns: Report.columns, where: "id > ? AND report_loc = ?", whereArgs: [lastId, loc], orderBy: 'id DESC',limit: limitNum);

    print('results from fetch batch');
    print(results);

    List<Report> parsedRes = new List<Report>();
    if (results.length == 0) return parsedRes;

    for (var i = 0; i < results.length; i++) {
      parsedRes.add(Report.fromMap(results[i]));
    }

    return parsedRes;
  }

  ///-----
  /// User Cache Functions
  ///-----

  Future<User> upsertUser(User user) async {
    var count = Sqflite.firstIntValue(await _db.rawQuery('SELECT COUNT(*) FROM user WHERE email = ?', [user.email]));

    if (count == 0) {
      user.id = await _db.insert('user', user.toMap());
    } else {
      await _db.update('user', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
    }

    if (user.citiesCache.length > 0) {
      for (var i = 0; i < user.citiesCache.length; i++) {
        CityCache rep = user.citiesCache[i];
        rep.userEmail = user.email;
        await upsertCityCache(rep);
      }
    }

    print('inserted user to sqlite db');
    return user;
  }

  Future<CityCache> upsertCityCache(CityCache city) async {
    if (city.id == null) {
      city.id = await _db.insert('city_fetch', city.toMap());
    } else {
      await _db.update('city_fetch', city.toMap(), where: 'id = ?', whereArgs: [city.id]);
    }

    print('inserted city fetch to sqlite db');
    return city;
  }

  Future<List<CityCache>> getCityCache(String email) async {
    List<Map<String, dynamic>> results = await _db.query('city_fetch', columns: CityCache.columns, where: 'user_email = ?', whereArgs: [email]);

    if (results == null) return [];
    else return results.map((i) => CityCache.fromMap(i)).toList();
  }

  Future<User> fetchUserByEmail(String email) async {
    List<Map<String, dynamic>> results = await _db.query('user', columns: User.columns, where: "email = ?", whereArgs: [email]);

    if (results.length == 0) return null;
    User user = User.fromJson(results[0]);

    print('fetch user from sqlite db');
    print(user.id);

    return user;
  }

  ///-----
  ///
  ///-----

  //temp
  Future<void> deleteTables() async {
    await _db.execute("DROP TABLE IF EXISTS user");
    await _db.execute("DROP TABLE IF EXISTS report");
    await _db.execute("DROP TABLE IF EXISTS city_fetch");
    await _db.execute("DROP TABLE IF EXISTS city_weather");
    await _db.execute("DROP TABLE IF EXISTS weather_data");
    await _db.execute("DROP TABLE IF EXISTS weather_desc");

    await _create(_db, 1);
    print('deleted tables');
  }
  
  Future<void> queryAllRows(String tableName) async {
    print('querying $tableName');
    List<Map> results = await _db.query(tableName);
    for (var i = 0; i < results.length; i++) {
      print(results[i]);
    }
  }

  Future<int> getLatestId(String loc) async {
    List<Map<String, dynamic>> results = await _db.query('report', columns: Report.columns, orderBy: 'id DESC', limit: 1);

    if (results.length == 0) return 0;
    Report report = Report.fromMap(results[0]);
    return report.id;
  }
}