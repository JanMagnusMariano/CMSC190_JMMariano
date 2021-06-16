import 'package:flutter/material.dart';

// TODO : Clean up code and finalize icons that will be used

// Change to IconData or Image to support night
String getStringIcon(String iconCode) {
  switch (iconCode) {
    case '01d':
      return '\u{2600}';
    case '01n':
      return '\u{2600}';
    case '02d':
      return '\u{1F324}';
    case '02n':
      return '\u{1F324}';
    case '03d':
    case '04d':
      return '\u{2601}';
    case '03n':
    case '04n':
      return '\u{2601}';
    case '09d':
      return '\u{1F326}';
    case '09n':
      return '\u{1F326}';
    case '10d':
      return '\u{1F327}';
    case '10n':
      return '\u{1F327}';
    case '11d':
      return '\u{26C8}';
    case '11n':
      return '\u{26C8}';
    case '13d':
      return '\u{1F328}';
    case '13n':
      return '\u{1F328}';
    case '50d':
      return '\u{1F32B}';
    case '50n':
      return '\u{1F32B}';
    default:
      return '\u{2600}';
//    case '01d': return WeatherIcons.clear_day;
//    case '01n': return WeatherIcons.clear_night;
//    case '02d': return WeatherIcons.few_clouds_day;
//    case '02n': return WeatherIcons.few_clouds_day;
//    case '03d':
//    case '04d':
//      return WeatherIcons.clouds_day;
//    case '03n':
//    case '04n':
//      return WeatherIcons.clear_night;
//    case '09d': return WeatherIcons.shower_rain_day;
//    case '09n': return WeatherIcons.shower_rain_night;
//    case '10d': return WeatherIcons.rain_day;
//    case '10n': return WeatherIcons.rain_night;
//    case '11d': return WeatherIcons.thunder_storm_day;
//    case '11n': return WeatherIcons.thunder_storm_night;
//    case '13d': return WeatherIcons.snow_day;
//    case '13n': return WeatherIcons.snow_night;
//    case '50d': return WeatherIcons.mist_day;
//    case '50n': return WeatherIcons.mist_night;
//    default: return WeatherIcons.clear_day;
  }
}

IconData getIconData(String iconCode) {
  switch (iconCode) {
    case '01d':
      return WeatherIcons.clear_day;
    case '01n':
      return WeatherIcons.clear_night;
    case '02d':
      return WeatherIcons.few_clouds_day;
    case '02n':
      return WeatherIcons.few_clouds_day;
    case '03d':
    case '04d':
      return WeatherIcons.clouds_day;
    case '03n':
    case '04n':
      return WeatherIcons.clear_night;
    case '09d':
      return WeatherIcons.shower_rain_day;
    case '09n':
      return WeatherIcons.shower_rain_night;
    case '10d':
      return WeatherIcons.rain_day;
    case '10n':
      return WeatherIcons.rain_night;
    case '11d':
      return WeatherIcons.thunder_storm_day;
    case '11n':
      return WeatherIcons.thunder_storm_night;
    case '13d':
      return WeatherIcons.snow_day;
    case '13n':
      return WeatherIcons.snow_night;
    case '50d':
      return WeatherIcons.mist_day;
    case '50n':
      return WeatherIcons.mist_night;
    default:
      return WeatherIcons.clear_day;
  }
}

/// Exposes specific weather icons
/// Has all weather conditions specified by open weather maps API
/// https://openweathermap.org/weather-conditions
// hex values and ttf file from https://erikflowers.github.io/weather-icons/
class WeatherIcons {
  static const IconData clear_day = const _WeatherIcon(0xf00d);
  static const IconData clear_night = const _WeatherIcon(0xf02e);

  static const IconData few_clouds_day = const _WeatherIcon(0xf002);
  static const IconData few_clouds_night = const _WeatherIcon(0xf081);

  static const IconData clouds_day = const _WeatherIcon(0xf07d);
  static const IconData clouds_night = const _WeatherIcon(0xf080);

  static const IconData shower_rain_day = const _WeatherIcon(0xf009);
  static const IconData shower_rain_night = const _WeatherIcon(0xf029);

  static const IconData rain_day = const _WeatherIcon(0xf008);
  static const IconData rain_night = const _WeatherIcon(0xf028);

  static const IconData thunder_storm_day = const _WeatherIcon(0xf010);
  static const IconData thunder_storm_night = const _WeatherIcon(0xf03b);

  static const IconData snow_day = const _WeatherIcon(0xf00a);
  static const IconData snow_night = const _WeatherIcon(0xf02a);

  static const IconData mist_day = const _WeatherIcon(0xf003);
  static const IconData mist_night = const _WeatherIcon(0xf04a);
}

class _WeatherIcon extends IconData {
  const _WeatherIcon(int codePoint)
      : super(codePoint, fontFamily: 'WeatherIcons');
}
