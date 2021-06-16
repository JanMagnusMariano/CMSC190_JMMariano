import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class WeatherDataEvent extends Equatable {
  const WeatherDataEvent();
}

class FetchWeather extends WeatherDataEvent {
  final String cityName;

  const FetchWeather({@required this.cityName}) : assert(cityName != null);

  @override
  List<Object> get props => [cityName];
}

class WeatherLoggedOut extends WeatherDataEvent {
  @override
  List<Object> get props => [];
}

//class RefreshWeather extends WeatherDataEvent {
//  final String cityName;
//
//  const RefreshWeather({@required this.cityName}) : assert(cityName != null);
//
//  @override
//  List<Object> get props => [cityName];
//}