import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/settings/bloc.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (BuildContext context, SettingsState state) {
          return ListView(
            children: <Widget>[
              ListTile(
                title: Text('Temperature Units'),
                isThreeLine: true,
                subtitle: Text('Use metric measurements for temperature'),
                trailing: Switch(
                  value: state.temperatureUnit == TemperatureUnit.celsius,
                  onChanged: (_) => context.watch<SettingsBloc>().add(TemperatureUnitsToggled()),
                ),
              ),
              ListTile(
                title: Text('Theme'),
                trailing: Switch(
                  value: state.themeMode == ThemeMode.dark,
                  onChanged: (_) {context.read<SettingsBloc>().add(ModeToggled());},
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
