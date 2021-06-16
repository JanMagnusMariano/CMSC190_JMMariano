import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:spphasetwo/blocs/offline_transfer/offline_transfer_bloc.dart';

import '../blocs/authentication/bloc.dart';
import '../blocs/connection/bloc.dart' as Local;
import '../blocs/sign_in/bloc.dart';
import '../blocs/weather_data/bloc.dart';
import '../blocs/report_data/bloc.dart';

import 'authenticate/sign_in.dart';
import 'home/home.dart';

import 'global_widgets.dart';
import 'splash_screen.dart';

/// Issues
///

class StartScreen extends StatelessWidget {
  static bool _isOnline = true;

  @override
  Widget build(BuildContext context) {
    print('start_screen rebuild');

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        buildWhen: (AuthenticationState prev, AuthenticationState curr) {
          return !(curr is AuthenticatedTransition);
        },
        builder: (context, state) {
          var connectionStatus = Provider.of<Local.ConnectionState>(context);

          if (connectionStatus is Local.ConnectionOnline && !_isOnline) {
            _isOnline = true;
            SchedulerBinding.instance.addPostFrameCallback((_) {
              GlobalWidgets.onlineSnackbar(context);
            });
          } else if (connectionStatus is Local.ConnectionOffline && _isOnline) {
            _isOnline = false;
            SchedulerBinding.instance.addPostFrameCallback((_) {
              GlobalWidgets.offlineSnackbar(context);
            });
          }

          if (state is Unauthenticated) {
            return BlocProvider<SignInBloc>(
              create: (context) => SignInBloc(),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 3000),
                child: SignIn(),
              ),
            );
          } else if (state is Authenticated) {
            // Move this
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (Navigator.of(context).canPop()) Navigator.pop(context, 'dialog');
            });

            return MultiBlocProvider(
              providers: [
                BlocProvider<WeatherDataBloc>(create: (context) => WeatherDataBloc()),
                BlocProvider<SignInBloc>(create: (context) => SignInBloc()),
                BlocProvider<ReportDataBloc>(create: (context) => ReportDataBloc()),
                BlocProvider<OfflineTransferBloc>(create: (context) => OfflineTransferBloc()),
              ],
              child: Home(),
            );
          } else if (state is AuthenticatedTransition) {
            print('Still in?');
          } else if (state is Initial) {
            print('Splash Screen');
            return SplashScreen();
          }

          //GlobalWidgets.loadingOverlay(context);
        },
      ),
    );
  }
}
