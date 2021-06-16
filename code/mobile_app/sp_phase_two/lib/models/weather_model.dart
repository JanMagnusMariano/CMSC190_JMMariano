import 'package:equatable/equatable.dart';

/// Issues:
/// 1. This file has not been refactored
/// 2. Simplify weather json by putting info inside 'weather_data'
/// 3, Don't store CurrentWeather in cache, instead fetch new data everytime if CurrentWeather changes
/// 4. Do something about 'temp' in daily
/// 5. Change 'lastUpdated' to fit parsing

// ignore: must_be_immutable
class WeatherModel extends Equatable{
  int id;
  String lastModified, cityName;
  double latitude, longitude;
  WeatherData current;
  List<WeatherData> hourly;
  List<WeatherData> daily;

  static final columns = ['id', 'city_name', 'latitude', 'longitude', 'last_modified'];

  @override
  List<Object> get props => [id, cityName, lastModified, latitude, longitude, current, hourly, daily];

  WeatherModel({this.id, this.cityName, this.latitude, this.longitude, this.current, this.hourly, this.daily, this.lastModified});

  // For converting to receive HTTP call
  factory WeatherModel.fromJson(Map<String, dynamic> parsedJson) {
    var hourlyJson = parsedJson['weather_data']['hourly'] as List;
    List<WeatherData> hourlyList =
        hourlyJson.map((index) => WeatherData.fromJson(index)).toList();

    var dailyJson = parsedJson['weather_data']['daily'] as List;
    List<WeatherData> dailyList =
        dailyJson.map((index) => WeatherData.fromJson(index)).toList();

    return WeatherModel(
      cityName: parsedJson['city'] + ',' + parsedJson['province'],
      latitude: parsedJson['weather_data']['lat'],
      longitude: parsedJson['weather_data']['lon'],
      // Change last updated for better parsing
      lastModified: parsedJson['last_modified'],
      current: WeatherData.fromJson(parsedJson['weather_data']['current']),
      hourly: hourlyList,
      daily: dailyList,
    );
  }

  // For converting from local sqlite DB / cache
  factory WeatherModel.fromMap(Map<String, dynamic> dbRow) {
    return WeatherModel(
      id: dbRow['id'],
      cityName: dbRow['city_name'],
      lastModified: dbRow['last_modified'],
      latitude: dbRow['latitude'],
      longitude: dbRow['longitude'],
    );
  }

  // For converting to send over HTTP
  Map<String, dynamic> toJson() {}

  // For converting to local sqlite DB / cache
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map =  {
      'city_name': cityName,
      'last_modified': lastModified,
      'latitude': latitude,
      'longitude': longitude,
    };

    if (id != null) map['id'] = id;
    return map;
  }
}

// ignore: must_be_immutable
class WeatherData extends Equatable {
  int id, dt, pressure, humidity;
  String weatherId;
  double maxTemp, minTemp;
  WeatherDesc weatherDesc;

  static final columns = ['id', 'dt', 'pressure', 'humidity', 'max_temp', 'min_temp', 'weather_id'];

  @override
  List<Object> get props => [id, dt, pressure, humidity, maxTemp, minTemp, weatherId];

  WeatherData({this.id, this.dt, this.maxTemp, this.minTemp, this.pressure, this.humidity, this.weatherDesc, this.weatherId});

  // For converting to receive HTTP call
  factory WeatherData.fromJson(Map<String, dynamic> parsedJson) {
    WeatherDesc descJson = parsedJson['weather'] is List
        ? WeatherDesc.fromJson(parsedJson['weather'][0])
        : WeatherDesc.fromJson(parsedJson['weather']);

    double _maxTemp, _minTemp;

    if (parsedJson['temp'] is Map<String, dynamic>) {
      _maxTemp = parsedJson['temp']['max'].toDouble();
      _minTemp = parsedJson['temp']['min'].toDouble();
    } else {
      _maxTemp = parsedJson['temp'].toDouble();
      _minTemp = parsedJson['temp'].toDouble();
    }

    return WeatherData(
      dt: parsedJson['dt'],
      maxTemp: _maxTemp,
      minTemp: _minTemp,
      pressure: parsedJson['pressure'],
      humidity: parsedJson['humidity'],
      weatherDesc: descJson,
    );
  }

  // For converting from local sqlite DB / cache
  factory WeatherData.fromMap(Map<String, dynamic> dbRow) {
    return WeatherData(
      id: dbRow['id'],
      dt: int.parse(dbRow['dt']),
      maxTemp: dbRow['max_temp'].toDouble(),
      minTemp: dbRow['min_temp'].toDouble(),
      pressure: dbRow['pressure'],
      humidity: dbRow['humidity'],
      weatherId: dbRow['weather_id'],
    );
  }

  // For converting to send over HTTP
  Map<String, dynamic> toJson() {}

  // For converting to local sqlite DB / cache
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map =  {
      'dt': dt,
      'max_temp': maxTemp,
      'min_temp': minTemp,
      'pressure': pressure,
      'humidity': humidity,
    };

    if (weatherId != null) map['weather_id'] = weatherId;
    if (id != null) map['id'] = id;
    return map;
  }
}

// ignore: must_be_immutable
class WeatherDesc extends Equatable{
  int id, descId;
  String mainDesc, subDesc, icon;

  static final columns = ['id', 'main', 'description', 'icon', 'desc_id'];

  @override
  List<Object> get props => [id, mainDesc, subDesc, icon, descId];

  WeatherDesc({this.id, this.mainDesc, this.subDesc, this.icon, this.descId});

  // For converting to receive HTTP call
  factory WeatherDesc.fromJson(Map<String, dynamic> parsedJson) {
    return WeatherDesc(
      mainDesc: parsedJson['main'],
      subDesc: parsedJson['description'],
      icon: parsedJson['icon'],
    );
  }

  // For converting from local sqlite DB / cache
  factory WeatherDesc.fromMap(Map<String, dynamic> dbRow) {
    return WeatherDesc(
      id: dbRow['id'],
      mainDesc: dbRow['main'],
      subDesc: dbRow['description'],
      icon: dbRow['icon'],
      descId: dbRow['desc_id'],
    );
  }

  Map<String, dynamic> toJson() {}

  // For converting to local sqlite DB / cache
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map =  {
      'main': mainDesc,
      'description': subDesc,
      'icon': icon,
    };

    if (descId != null) map['desc_id'] = descId;
    if (id != null) map['id'] = id;
    return map;
  }
}

//// ignore: must_be_immutable
//class HourlyWeather extends Equatable {
//  int id, dt, pressure, humidity, weatherId;
//  double temp;
//  WeatherDesc weatherDesc;
//
//  static final columns = ['id', 'temp', 'pressure', 'humidity', 'temp', 'weather_id'];
//
//  @override
//  List<Object> get props => [id, dt, pressure, humidity, temp, weatherId];
//
//  HourlyWeather({this.id, this.dt, this.temp, this.pressure, this.humidity, this.weatherDesc, this.weatherId});
//
//  factory HourlyWeather.fromJson(Map<String, dynamic> parsedJson) {
//    WeatherDesc descJson = parsedJson['weather'] is List
//        ? WeatherDesc.fromJson(parsedJson['weather'][0])
//        : WeatherDesc.fromJson(parsedJson['weather']);
//
//    return HourlyWeather(
//      dt: parsedJson['dt'],
//      temp: parsedJson['temp'].toDouble(),
//      pressure: parsedJson['pressure'],
//      humidity: parsedJson['humidity'],
//      weatherDesc: descJson,
//    );
//  }
//
//  Map<String, dynamic> toJson() {}
//}

//class DailyWeather {
//  int rawDate, pressure, humidity, sunrise, sunset, clouds;
//  double windSpeed, uvi;
//  DetailedTemp temp;
//  WeatherDesc weatherDesc;
//
//  DailyWeather({
//    this.rawDate,
//    this.temp,
//    this.pressure,
//    this.humidity,
//    this.weatherDesc,
//    this.sunrise,
//    this.sunset,
//    this.windSpeed,
//    this.uvi,
//    this.clouds,
//  });
//
//  factory DailyWeather.fromJson(Map<String, dynamic> json) {
//    WeatherDesc descJson = json['weather'] is List
//        ? WeatherDesc.fromJson(json['weather'][0])
//        : WeatherDesc.fromJson(json['weather']);
//
//    return DailyWeather(
//      rawDate: json['dt'],
//      sunrise: json['sunrise'],
//      sunset: json['sunset'],
//      clouds: json['clouds'],
//      windSpeed: json['wind_speed'].toDouble(),
//      uvi: json['uvi'].toDouble(),
//      temp: DetailedTemp.fromJson(json['temp']),
//      pressure: json['pressure'],
//      humidity: json['humidity'],
//      weatherDesc: descJson,
//    );
//  }
//
//  Map<String, dynamic> toJson() {}
//}
//
//class DetailedTemp {
//  double tempMax, tempMin, day, night;
//
//  DetailedTemp({
//    this.tempMax,
//    this.tempMin,
//    this.day,
//    this.night,
//  });
//
//  factory DetailedTemp.fromJson(Map<String, dynamic> json) {
//    return DetailedTemp(
//      tempMax: json['max'].toDouble(),
//      tempMin: json['min'].toDouble(),
//      day: json['day'].toDouble(),
//      night: json['night'].toDouble(),
//    );
//  }
//
//  Map<String, dynamic> toJson() {
//    return {
//      'min': tempMin,
//      'max': tempMax,
//      'day': day,
//      'night': night,
//    };
//  }
//}