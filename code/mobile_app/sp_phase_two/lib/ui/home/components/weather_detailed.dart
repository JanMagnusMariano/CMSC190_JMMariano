import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';

import '../../../blocs/settings/bloc.dart';
import '../../../models/weather_model.dart';
import 'weather_icon.dart';

/// Issues:
/// 1. Not yet refactored

class WeatherDetailed extends StatelessWidget {
  final List<WeatherData> _weatherInfo;
  final TemperatureUnit _unit;

  WeatherDetailed({List<WeatherData> info, TemperatureUnit unit})
      : _weatherInfo = info,
        _unit = unit;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _weatherInfo.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Detailed Information'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: TabBar(
            isScrollable: true,
            tabs: _tabTitles(),
          ),
        ),
        body: TabBarView(children: _tabBodies(context)),
      ),
    );
  }

  List<Widget> _tabTitles() {
    List<Widget> _titles = [];

    for (var info in _weatherInfo) {
      String _text = DateFormat('E')
          .format(DateTime.fromMillisecondsSinceEpoch(info.dt * 1000))
          .toString();
      String _number = DateFormat('M/d')
          .format(DateTime.fromMillisecondsSinceEpoch(info.dt * 1000))
          .toString();

      Tab _toAdd = new Tab(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text('$_text\n$_number'),
        ),
      );

      _titles.add(_toAdd);
    }

    return _titles;
  }

  List<Widget> _tabBodies(BuildContext context) {
    List<Widget> _bodies = [];
    Color _divColor = Theme.of(context).textTheme.caption.color;

    for (var info in _weatherInfo) {
      String _capitalized = info.weatherDesc.subDesc
          .split(' ')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');

      var _tabBody = new ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        children: <Widget>[
          _headers(
            context,
            text: getStringIcon(info.weatherDesc.icon),
            fontSize: 64,
            align: TextAlign.center,
          ),
          _headers(
            context,
            text: _capitalized,
            fontSize: 24,
            align: TextAlign.center,
          ),
          _infoRows(info, 3, _divColor),
          _headers(
            context,
            text: 'Day',
            color: Theme.of(context).accentColor,
          ),
          _dayCycle(info, 1, _divColor),
          _headers(
            context,
            text: 'Night',
            color: Theme.of(context).accentColor,
          ),
          _dayCycle(info, 2, _divColor)
        ],
      );

      _bodies.add(_tabBody);
    }

    return _bodies;
  }

  Widget _infoRows(WeatherData data, int mode, Color divColor) {
    List<Widget> _rows = [];
    Map<String, String> _details = {};

//    if (mode == 1) {
//      String _sunrise = DateFormat.jm()
//          .format(DateTime.fromMillisecondsSinceEpoch(data.sunrise * 1000));
//      String _temp = (convertTemp(data.temp, _unit)).toString();
//      _details.addAll({'Temperature': _temp, 'Sunrise': _sunrise});
//    } else if (mode == 2) {
//      String _sunset = DateFormat.jm()
//          .format(DateTime.fromMillisecondsSinceEpoch(data.sunset * 1000));
//      String _temp = (convertTemp(data.temp, _unit)).toString();
//      _details.addAll({'Temperature': _temp, 'Sunset': _sunset});
//    } else if (mode == 3) {
//      _details.addAll({
//        'Pressure': data.pressure.toString() + ' mbar',
//        'Humidity': data.humidity.toString() + '%',
//        // wind speed is m/s
//        'Wind Speed': data.windSpeed.toString() + ' km/h',
//        'Cloud Coverage': data.clouds.toString() + '%',
//      });
//    }

    List<String> _keyList = [], _valList = [];
    _keyList.addAll(_details.keys.toList());
    _valList.addAll(_details.values.toList());

    for (var index = 0; index < _keyList.length; index++) {
      if (index != (_keyList.length - 1))
        _rows.add(_infoRow(_keyList[index], _valList[index], divColor, true));
      else
        _rows.add(_infoRow(_keyList[index], _valList[index], divColor, false));
    }

    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: _rows,
    );
  }

  Widget _infoRow(String leading, trailing, Color divColor, bool _withDiv) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: ListTile(
              leading: Text(leading),
              trailing: Text(trailing),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
          fit: FlexFit.loose,
        ),
        (_withDiv)
            ? Divider(height: 0, thickness: 1.5, color: divColor)
            : Container(),
      ],
    );
  }

  Widget _dayCycle(WeatherData data, int mode, Color divColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
          child: Text(getStringIcon(data.weatherDesc.icon),
              style: TextStyle(fontSize: 32), textAlign: TextAlign.center),
        ),
        SizedBox(width: 10),
        Flexible(fit: FlexFit.loose, child: _infoRows(data, mode, divColor)),
      ],
    );
  }

  Widget _headers(BuildContext context,
      {String text, double fontSize, Color color, TextAlign align}) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Text(
        text,
        textAlign: align ?? TextAlign.left,
        style: TextStyle(
          fontSize: fontSize ?? 20,
          color: color ?? Theme.of(context).textTheme.headline6.color,
        ),
      ),
    );
  }
}

double convertTemp(double temp, TemperatureUnit unit) {
  double currTemp = temp;
  if (unit == TemperatureUnit.celsius)
    currTemp = (currTemp - 273.15);
  else if (unit == TemperatureUnit.fahrenheit)
    currTemp = ((currTemp - 273.15) * (9 / 5)) + 32;
  return currTemp.floorToDouble();
}