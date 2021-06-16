import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

enum TemperatureUnit { fahrenheit, celsius }

class SettingsState extends Equatable {
  final TemperatureUnit temperatureUnit;
  final ThemeMode themeMode;

  const SettingsState({@required this.temperatureUnit, @required this.themeMode})
      : assert(temperatureUnit != null);

  TemperatureUnit flipTemperature() {
    return (temperatureUnit == TemperatureUnit.celsius) ? TemperatureUnit.fahrenheit : TemperatureUnit.celsius;
  }

  ThemeMode flipTheme() {
    return (themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  List<Object> get props => [temperatureUnit, themeMode];

  //@override

}
