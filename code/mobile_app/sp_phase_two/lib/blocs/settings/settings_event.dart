import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class TemperatureUnitsToggled extends SettingsEvent {}

class ModeToggled extends SettingsEvent {}
