import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'settings_event.dart';
import 'settings_state.dart';

/// Issues:
/// 1. Migrate 'recentSearch' to session_services

class SettingsBloc extends HydratedBloc<SettingsEvent, SettingsState> {
  SettingsBloc()
      : super(SettingsState(
          temperatureUnit: TemperatureUnit.celsius,
          themeMode: ThemeMode.light
        ));

  @override
  Stream<SettingsState> mapEventToState(SettingsEvent event) async* {
    if (event is TemperatureUnitsToggled) {
      yield SettingsState(
        temperatureUnit: state.flipTemperature(),
        themeMode: state.themeMode,
      );
    } else if (event is ModeToggled) {
      yield SettingsState(
        temperatureUnit: state.temperatureUnit,
        themeMode: state.flipTheme(),
      );
    }
  }

  @override
  SettingsState fromJson(Map<String, dynamic> parsedJson) {
    return SettingsState(
      temperatureUnit: TemperatureUnit.values[parsedJson['temperature_units'] as int],
      themeMode: ThemeMode.values[parsedJson['theme_mode'] as int]
    );
  }

  @override
  Map<String, dynamic> toJson(SettingsState state) {
    return {
      'temperature_units': state.temperatureUnit.index,
      'theme_mode': state.themeMode.index,
    };
  }
}