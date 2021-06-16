import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/weather_model.dart';

import 'weather_icon.dart' as CustomIcon;
import 'weather_tile_vertical.dart' as Tile;
import 'weather_detailed.dart' as Detailed;
import '../../../blocs/settings/bloc.dart';

import '../../global_widgets.dart';

/// Issues
/// 1. Add design to outdatedNotice

class WeatherWidgets {

  WeatherWidgets._();

  static Widget outdatedNotice(String lastUpdate, BoxDecoration decor) {
    int dayDiff = DateTime.now().difference(DateTime.parse(lastUpdate)).inHours;

    String _dateUpdate = DateFormat('MMM d, y').add_jm().format(DateTime.parse(lastUpdate));
    String _day = DateFormat('EEEE').format(DateTime.parse(lastUpdate));

    SizedBox outdated = SizedBox(
      child: Container(
        decoration: decor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.warning),
            SizedBox(width: 15),
            Flexible(
              child: Text(
                'Weather forecast data is outdated\nLast update was at $_day\n $_dateUpdate',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )
      ),
    );

    return (dayDiff >= 1) ? outdated : Container();
  }

  static Widget currentWeather(BuildContext context, WeatherModel weather, TemperatureUnit unit, BoxDecoration decor) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    double _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    bool _large =  GlobalWidgets.isScreenLarge(_width, _pixelRatio);
    bool _medium =  GlobalWidgets.isScreenMedium(_width, _pixelRatio);

    double _curr = convertTemp(weather.current.maxTemp, unit);
    // Display min and max temp properly
    double _max = convertTemp(weather.daily[0].maxTemp, unit);
    double _min = convertTemp(weather.daily[0].minTemp, unit);
    String _symbol = (unit == TemperatureUnit.celsius) ? 'C' : 'F';

    String _currTemp = '${_curr.toString()}\u{00B0}$_symbol';
    String _maxTemp = '\u{2191}${_max.toString()}';
    String _minTemp = '\u{2193}${_min.toString()}';

    String _capitalized = weather.current.weatherDesc.subDesc
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
    String _date = DateFormat('d MMMM')
        .format(DateTime.fromMillisecondsSinceEpoch(weather.current.dt * 1000));
    String _icon = CustomIcon.getStringIcon(weather.current.weatherDesc.icon);

    List<Widget> _infoDump = [
      Text(_currTemp, style: TextStyle(fontSize: (_medium) ? 36 : 48)),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            _maxTemp,
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
          SizedBox(width: 5),
          Text(
            _minTemp,
            style: TextStyle(fontSize: 18, color: Colors.blue),
          ),
        ],
      ),
      SizedBox(height: 6),
      Center(child: Text(_capitalized, style: TextStyle(fontSize: (_medium) ? 16 : 20))),
      SizedBox(height: 4),
      Center(child: Text(_date, style: TextStyle(fontSize: (_medium) ? 16 : 20))),
    ];

    return SizedBox(
      child: Container(
        padding : (_medium) ? EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 18) : EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 18),
        decoration: decor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: (_medium) ? 8 : 10),
              child: Column(children: _infoDump),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text(_icon, style: TextStyle(fontSize: (_medium) ? 84 : 96)),
            ),
          ],
        ),
      ),
    );
  }

  static Widget hourlyWeather(List<WeatherData> hourly, TemperatureUnit unit, BoxDecoration decor, double height) {
    List<Widget> _widgets = new List<Widget>();

    for (var index = 0; index < (hourly.length / 2); index++) {
      var _toAdd = new Container(
        padding: const EdgeInsets.only(top: 0, bottom: 0, right: 16, left: 16),
        child: Center(
          child: Tile.ValueTile(
            DateFormat('EEEE h a k').format(DateTime.fromMillisecondsSinceEpoch(hourly[index].dt * 1000)),
            convertTemp(hourly[index].maxTemp, unit).toString(),
            unitToString(unit),
            iconData: CustomIcon.getIconData(hourly[index].weatherDesc.icon),
          ),
        ),
      );

      _widgets.add(new Divider());
      _widgets.add(_toAdd);
    }

    return SizedBox(
      height: 216,
      width: double.infinity,
      child: Container(
        child: ListView(
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          children: _widgets,
        ),
      ),
    );
  }

  static Widget dailyWeather(List<WeatherData> daily, TemperatureUnit unit, BoxDecoration decor, BuildContext context) {
    List<Widget> _widgets = new List<Widget>();

    for (var index = 0; index < daily.length; index++) {
      double _max = daily[index].maxTemp;
      double _min = daily[index].minTemp;

      String _text = DateFormat('E').format(DateTime.fromMillisecondsSinceEpoch(daily[index].dt * 1000));
      String _number = DateFormat('M/d').format(DateTime.fromMillisecondsSinceEpoch(daily[index].dt * 1000));
      String _maxTemp = '\u{2191}${convertTemp(_max, unit).toString()}';
      String _minTemp = '\u{2193}${convertTemp(_min, unit).toString()}';
      String _icon = CustomIcon.getStringIcon(daily[index].weatherDesc.icon);

      var _div = new Divider(
        height: 0,
        thickness: 1,
        color: Theme.of(context).dividerColor,
      );

      var _toAdd = new ListTile(
        contentPadding: EdgeInsets.only(left: 20),
        title: Text(_text, style: TextStyle(fontSize: 16)),
        subtitle: Text(_number, style: TextStyle(fontSize: 14)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(_icon, style: TextStyle(fontSize: 30), textAlign: TextAlign.center),
            SizedBox(width: 50),
            Text(_maxTemp, style: TextStyle(fontSize: 14, color: Colors.red)),
            SizedBox(width: 10),
            Text(_minTemp, style: TextStyle(fontSize: 14, color: Colors.blue)),
            SizedBox(width: 50),
            Icon(Icons.arrow_forward_ios),
          ],
        ),
        onTap: () => _detailedWeather(context, daily, unit),
      );

      _widgets.add(_div);
      _widgets.add(_toAdd);
    }

    return SizedBox(
      child: Container(
        decoration: decor,
        child: Column(children: _widgets),
      ),
    );
  }

  static Widget customButton(VoidCallback onPressed, String title) {
    return OutlineButton(
      onPressed: onPressed,
      child: Text(title),
    );
  }

  static void _detailedWeather(BuildContext context, List<WeatherData> daily, TemperatureUnit unit) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => Detailed.WeatherDetailed(info: daily, unit: unit)
      ),
    );
  }

  static double convertTemp(double temp, TemperatureUnit unit) {
    double currTemp = temp;
    if (unit == TemperatureUnit.celsius)
      currTemp = (currTemp - 273.15);
    else if (unit == TemperatureUnit.fahrenheit)
      currTemp = ((currTemp - 273.15) * (9 / 5)) + 32;
    return currTemp.floorToDouble();
  }

  static String unitToString(TemperatureUnit unit) {
    if (unit == TemperatureUnit.fahrenheit) return '\u{00B0}F';
    else return '\u{00B0}C';
  }
}
