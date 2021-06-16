import 'dart:async';
import 'package:rxdart/rxdart.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/cache_services.dart';
import '../../utils/session_services.dart';
import '../../repository/rethink_weather.dart';
import '../../models/weather_model.dart';

import 'weather_data_event.dart';
import 'weather_data_state.dart';

/// Issues
/// 1. Catch cases wherein fetch is done but there is no internet connection
/// 2. If nothing has changed in weather data from repository, return cached data and change 'last_updated'

class WeatherDataBloc extends Bloc<WeatherDataEvent, WeatherDataState> {

  WeatherDataBloc() : super(WeatherEmpty());

  @override
  Stream<Transition<WeatherDataEvent, WeatherDataState>> transformEvents(
      Stream<WeatherDataEvent> events,
      TransitionFunction<WeatherDataEvent, WeatherDataState> transitionFn,
      ) {
    return super.transformEvents(
      events.debounceTime(const Duration(milliseconds: 500)),
      transitionFn,
    );
  }

  @override
  Stream<WeatherDataState> mapEventToState(WeatherDataEvent event) async* {
    // TODO: Add Logic
    if (event is FetchWeather) {
      yield* _mapFetchWeatherToState(event);
    } else if (event is WeatherLoggedOut) {
      yield WeatherEmpty();
    }
//    else if (event is RefreshWeather) {
//      yield* _mapRefreshWeatherToState(event);
//    }
  }

  Stream<WeatherDataState> _mapFetchWeatherToState(FetchWeather event) async* {
    yield WeatherLoading();
    try {
      WeatherModel _toReturn;
      _toReturn = await CacheServices().getWeather(event.cityName);

      if (_toReturn == null) {
        _toReturn = await fetchCurrent(event.cityName, '');
        await CacheServices().upsertWeather(_toReturn);
        yield WeatherLoaded(weather: _toReturn);
      } else {
        // Check if data has changed in server
        WeatherModel _fetchReturn = await fetchCurrent(event.cityName, _toReturn.lastModified);
        if (_fetchReturn == null) yield WeatherLoaded(weather: _toReturn);
        else {
          await CacheServices().upsertWeather(_fetchReturn);
          yield WeatherLoaded(weather: _fetchReturn);
        }
      }
    } catch (_) {
      yield WeatherError();
    }
  }

//  Stream<WeatherDataState> _mapRefreshWeatherToState(
//      RefreshWeather event) async* {
//    yield WeatherLoading();
//    try {
//      String _cityName = RethinkWeather().getKey(event.cityName.replaceFirst(', ', ','));
//      final WeatherModel _toReturn = await fetchCurrent(_cityName, '');
//      print('Refreshed ' + event.cityName);
//      yield WeatherLoaded(weather: _toReturn);
//    } catch (_) {
//      print('Error in Refresh Weather');
//      yield WeatherError();
//    }
//  }

  Future<WeatherModel> fetchCurrent(String cityName, String lastModified) async {
    final WeatherModel weather = await RethinkWeather().fetchCurrentWeather(cityName, lastModified);
    SessionServices().currCityRaw = cityName;
    SessionServices().currCityParsed = RethinkWeather().getTitle(cityName);
    return weather;
  }
}