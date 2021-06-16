import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';


import '../../blocs/settings/bloc.dart';
import '../../blocs/weather_data/bloc.dart';
import '../../blocs/report_data/bloc.dart';
import '../global_widgets.dart';
import '../app_theme.dart';

//temp
import '../../utils/session_services.dart';
import './components/weather_widgets.dart';

/// Issues:
/// 2. Proper implementation of submit report

class HomeWeather extends StatefulWidget {
  @override
  State<HomeWeather> createState() => _HomeWeatherState();
}

class _HomeWeatherState extends State<HomeWeather> {
  //TODO: Fetch current weather when online during refresh
  Completer<void> _refreshCompleter;
  Future<File> _uploadImage;
  String base64Image;
  File tmpFile;

  double _height;
  double _width;
  double _pixelRatio;
  bool _large;
  bool _medium;

  @override
  void initState() {
    super.initState();
    _refreshCompleter = Completer<void>();
  }

  selectImage() {
    setState(() {
       _uploadImage = ImagePicker.pickImage(source: ImageSource.gallery);
    });
  }

  submitImage() {
    if(tmpFile == null) {
      print('No file selected!');
      return;
    }

    print(tmpFile.path);

    BlocProvider.of<ReportDataBloc>(context).add(SubmitReport(
      imageFile: File(tmpFile.path),
      location: SessionServices().currCityRaw,
      description: 'Submission'
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WeatherDataBloc, WeatherDataState>(
      listener: (context, state) {
        if (state is WeatherLoaded) {
          _refreshCompleter?.complete();
          _refreshCompleter = Completer();
        }
      },
      child: BlocBuilder<WeatherDataBloc, WeatherDataState>(
        builder: (context, state) {
          if (state is WeatherEmpty) {
            // Default this to current city provided by GPS?
            //print(SessionServices().currUser.subbedCities);
            //print(SessionServices().currUser.subbedCities.isNotEmpty);

            // Offline Test
            if (SessionServices().currUser == null) {
              BlocProvider.of<WeatherDataBloc>(context).add(FetchWeather(cityName: ""));
            } else if (SessionServices().currUser.subbedCities.isNotEmpty) {
              BlocProvider.of<WeatherDataBloc>(context).add(FetchWeather(
                  cityName: SessionServices().currUser.subbedCities[0]),
              );
            }
          } else if (state is WeatherLoading) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              GlobalWidgets.loadingOverlay(context);
            });
          } else if (state is WeatherError) {
            // Do something when error is thrown?
            return Container();
          } else if (state is WeatherLoaded) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (Navigator.of(context).canPop()) Navigator.pop(context, 'dialog');
            });

            TemperatureUnit _units = BlocProvider.of<SettingsBloc>(context).state.temperatureUnit;

            return RefreshIndicator(
              // ignore: missing_return
              onRefresh: () {
                BlocProvider.of<WeatherDataBloc>(context).add(FetchWeather(
                  cityName: SessionServices().currCityRaw,
                ));

                return _refreshCompleter.future;
              },
              child: ListView(
                padding: EdgeInsets.only(left: 24, right: 24),
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  _cityName(text: SessionServices().currCityParsed),
                  // replace DateTime.now() with cached lastUpdate
                  //WeatherWidgets.outdatedNotice(state.weather.lastModified, _boxDecor()),
                  _headers(text: 'Current Weather'),
                  WeatherWidgets.currentWeather(context, state.weather, _units, _boxDecor()),
                  _headers(text: 'Hourly Forecast'),
                  WeatherWidgets.hourlyWeather(state.weather.hourly, _units, _boxDecor(),_height),
                  _headers(text: 'Daily Forecast'),
                  WeatherWidgets.dailyWeather(state.weather.daily, _units, _notRounded(), context),
                  // WeatherWidgets.customButton(selectImage , 'Select Image'),
                  // showImage(),
                  // WeatherWidgets.customButton(submitImage , 'Submit Image'),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }

//  SizedBox currentCondition(
//      CurrentWeather currDay, DailyWeather forTemp, TemperatureUnit unit) {
//    List<Widget> _textData = new List<Widget>();
//    double _curr = Weather.convertTemp(currDay.temp, unit);
//    double _max = Weather.convertTemp(forTemp.temp.tempMax, unit);
//    double _min = Weather.convertTemp(forTemp.temp.tempMin, unit);
//
//    String _capitalized = currDay.weatherDesc[0].subDesc
//        .split(' ')
//        .map((word) => word[0].toUpperCase() + word.substring(1))
//        .join(' ');
//    String _date = DateFormat('d MMMM')
//        .format(DateTime.fromMillisecondsSinceEpoch(currDay.rawDate * 1000));
//    String _icon = Weather.getStringIcon(currDay.weatherDesc[0].icon);
//    String _symbol = (unit == TemperatureUnit.celsius) ? 'C' : 'F';
//
//    String _currTemp = '${_curr.toString()}\u{00B0}$_symbol';
//    String _maxTemp = '\u{2191}${_max.toString()}';
//    String _minTemp = '\u{2193}${_min.toString()}';
//
//    _textData.addAll([
//      Text(_currTemp, style: TextStyle(fontSize: 48)),
//      Row(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: <Widget>[
//          Text(
//            _maxTemp,
//            style: TextStyle(fontSize: 18, color: Colors.red),
//          ),
//          SizedBox(width: 5),
//          Text(
//            _minTemp,
//            style: TextStyle(fontSize: 18, color: Colors.blue),
//          ),
//        ],
//      ),
//      SizedBox(height: 6),
//      Center(child: Text(_capitalized, style: TextStyle(fontSize: 20))),
//      SizedBox(height: 4),
//      Center(child: Text(_date, style: TextStyle(fontSize: 20))),
//    ]);
//
//    return SizedBox(
//      child: Container(
//        decoration: _boxDecor(),
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//          children: <Widget>[
//            Container(
//              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//              child: Column(children: _textData),
//            ),
//            Container(
//              alignment: Alignment.center,
//              padding: EdgeInsets.symmetric(vertical: 15),
//              child: Text(_icon, style: TextStyle(fontSize: 96)),
//            ),
//          ],
//        ),
//      ),
//    );
//  }

//  SizedBox hourlyForecast(
//      List<WeatherData> forecasts, TemperatureUnit unit) {
//    List<Widget> _widgets = new List<Widget>();
//
//    for (var index = 0; index < (forecasts.length / 2); index++) {
//      var _toAdd = new Container(
//        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
//        child: Center(
//          child: Weather.ValueTile(
//            DateFormat('E, ha').format(DateTime.fromMillisecondsSinceEpoch(
//                forecasts[index].dt * 1000)),
//            Weather.convertTemp(forecasts[index].temp, unit).toString(),
//            iconData: Weather.getIconData(forecasts[index].weatherDesc.icon),
//          ),
//        ),
//      );
//
//      _widgets.add(new Divider());
//      _widgets.add(_toAdd);
//    }
//
//    return SizedBox(
//      height: MediaQuery.of(context).size.height * 0.20,
//      child: Container(
//        decoration: _boxDecor(),
//        child: ListView(
//          scrollDirection: Axis.horizontal,
//          shrinkWrap: true,
//          children: _widgets,
//        ),
//      ),
//    );
//  }

//  SizedBox dailyForecast(List<WeatherData> forecasts, TemperatureUnit unit) {
//    List<Widget> _widgets = new List<Widget>();
//
//    for (var index = 0; index < forecasts.length; index++) {
//      double _max = forecasts[index].temp;
//      double _min = forecasts[index].temp;
//
//      String _text = DateFormat('E').format(
//          DateTime.fromMillisecondsSinceEpoch(forecasts[index].dt * 1000));
//      String _number = DateFormat('M/d').format(
//          DateTime.fromMillisecondsSinceEpoch(forecasts[index].dt * 1000));
//      String _maxTemp = '\u{2191}${Weather.convertTemp(_max, unit).toString()}';
//      String _minTemp = '\u{2193}${Weather.convertTemp(_min, unit).toString()}';
//      String _icon =
//          Weather.getStringIcon(forecasts[index].weatherDesc.icon);
//
//      var _div = new Divider(
//        height: 0,
//        thickness: 1,
//        color: Theme.of(context).dividerColor,
//      );
//
//      var _toAdd = new ListTile(
//        contentPadding: EdgeInsets.only(left: 20),
//        title: Text(_text, style: TextStyle(fontSize: 16)),
//        subtitle: Text(_number, style: TextStyle(fontSize: 14)),
//        trailing: Row(
//          mainAxisSize: MainAxisSize.min,
//          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//          children: <Widget>[
//            Text(
//              _icon,
//              style: TextStyle(fontSize: 30),
//              textAlign: TextAlign.center,
//            ),
//            SizedBox(width: 50),
//            Text(
//              _maxTemp,
//              style: TextStyle(fontSize: 14, color: Colors.red),
//            ),
//            SizedBox(width: 10),
//            Text(
//              _minTemp,
//              style: TextStyle(fontSize: 14, color: Colors.blue),
//            ),
//            SizedBox(width: 50),
//            Icon(Icons.arrow_forward_ios),
//          ],
//        ),
//        onTap: () {
//          Navigator.push(
//            context,
//            MaterialPageRoute(
//                builder: (_) =>
//                    Weather.WeatherDetailed(info: forecasts, unit: unit)),
//          );
//        },
//      );
//
//      _widgets.add(_div);
//      _widgets.add(_toAdd);
//    }
//
//    return SizedBox(
//      child: Container(
//        decoration: _boxDecor(),
//        child: Column(children: _widgets),
//      ),
//    );
//  }

  Widget showImage() {
    return FutureBuilder<File>(
      future: _uploadImage,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done && null != snapshot.data) {
          tmpFile = File(snapshot.data.path);
          base64Image = base64Encode(File(tmpFile.path).readAsBytesSync());
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Image.file(
                  File(snapshot.data.path),
                  fit: BoxFit.fill,
                ),
              ),
            ],
          );
        } else if (null != snapshot.error) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else return Container();
      },
    );
  }

  Widget _headers({String text}) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top: 25, left: 15, right: 15, bottom: 15),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTheme.fontName,
          fontWeight: FontWeight.w400,
          fontSize: 18,
          letterSpacing: 0.5,
          color: AppTheme.lightText,
        ),
      ),
    );
  }

  Widget _cityName({String text}) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 15),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTheme.fontName,
          fontWeight: FontWeight.w700,
          fontSize: 24,
          letterSpacing: 0.5,
          color: AppTheme.darkerText,
        ),
      ),
    );
  }

  BoxDecoration _boxDecor({Color color}) {
    return BoxDecoration(
      color: AppTheme.white,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.0),
          bottomLeft: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
          topRight: Radius.circular(68.0)),
      boxShadow: <BoxShadow>[
        BoxShadow(
            color: AppTheme.grey.withOpacity(0.2),
            offset: Offset(1.1, 1.1),
            blurRadius: 10.0),
      ],
    );
  }

  BoxDecoration _notRounded({Color color}) {
    return BoxDecoration(
      color: AppTheme.white,
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8.0),
          bottomLeft: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
          topRight: Radius.circular(8.0)),
      boxShadow: <BoxShadow>[
        BoxShadow(
            color: AppTheme.grey.withOpacity(0.2),
            offset: Offset(1.1, 1.1),
            blurRadius: 10.0),
      ],
    );
  }
}
