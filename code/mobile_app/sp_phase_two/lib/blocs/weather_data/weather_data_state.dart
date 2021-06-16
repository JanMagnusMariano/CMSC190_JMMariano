import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../models/weather_model.dart';

abstract class WeatherDataState extends Equatable {
  const WeatherDataState();

  @override
  List<Object> get props => [];
}

class WeatherEmpty extends WeatherDataState {}

class WeatherLoading extends WeatherDataState {}

class WeatherError extends WeatherDataState {}

class WeatherLoaded extends WeatherDataState {
  final WeatherModel weather;
  final String cityName;
  final String lastUpdated;

  const WeatherLoaded(
      {@required this.weather,
        this.cityName,
        this.lastUpdated})
      : assert(weather != null);

  @override
  List<Object> get props => [weather, cityName, lastUpdated];
}