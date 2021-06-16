import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../blocs/connection/bloc.dart' as Local;
import '../../blocs/weather_data/bloc.dart';
import '../../blocs/report_data/bloc.dart';

import '../../blocs/settings/bloc.dart';
import 'home_weather.dart';
import 'home_reports.dart';
import 'home_wifip2p.dart';
import 'home_profile.dart';
import '../global_widgets.dart' as Global;
import '../app_theme.dart';

import 'components/home_widgets.dart';
import 'components/home_feedback.dart';

import '../../utils/session_services.dart';
import '../slide_route.dart';

/// Issues:
/// 1. Finish offline prompts
/// 2. Fix SettingsBloc

class Home extends StatefulWidget{
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final _pageViewController = PageController();

  AnimationController animationController;

  static bool _isOnline = true;
  static HomeWeather _weather = HomeWeather();
  static HomeReports _reports = HomeReports();
  static HomeWifiP2p _wifiP2p = HomeWifiP2p();
  static HomeProfile _profile = HomeProfile();

  int _currIndex = 0;
  Widget _currWindow, _currAppBar;

  @override
  void initState() {
    _getCurrWindow();
    _getCurrAppBar();

    animationController = AnimationController(
    duration: const Duration(milliseconds: 600), vsync: this);
    super.initState();
  }

  void _changePage(int index) {
    animationController.reverse().then<dynamic>((data) {
      setState(() {
        _currIndex = index;
        _getCurrWindow();
        _getCurrAppBar();
      });
    });
  }

  void _getCurrWindow() {
    if (_currIndex == 0) _currWindow = _weather;
    else if (_currIndex == 1) _currWindow = _reports;
    else if (_currIndex == 2) _currWindow = _wifiP2p;
    else if (_currIndex == 3) _currWindow = _profile;
  }

  void _getCurrAppBar() {
    _currAppBar = HomeWidgets.searchButton(context);
  }

  Widget build(BuildContext context) {
    print('home build');
    var connectionStatus = Provider.of<Local.ConnectionState>(context);

//    if (connectionStatus is Local.ConnectionOnline && !_isOnline) {
//      _isOnline = true;
////      SchedulerBinding.instance.addPostFrameCallback((_) {
////        GlobalWidgets.onlineSnackbar(context);
////      });
//    } else if (connectionStatus is Local.ConnectionOffline && _isOnline) {
//      _isOnline = false;
//      SchedulerBinding.instance.addPostFrameCallback((_) {
//        Global.noConnectionOverlay(context,
//          whenRetry: () {
//            Scaffold.of(context).hideCurrentSnackBar();
//            //BlocProvider.of<SignInBloc>(context).add(SignInWithGuest());
//          },
//          whenOffline: () {
//            Navigator.of(context, rootNavigator: true).pop('dialog');
////            BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
////            BlocProvider.of<WeatherDataBloc>(context).clear();
//          },
//        );
//      });
//    }

    return BlocBuilder<SettingsBloc, SettingsState> (
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Color(0xFFF2F3F8),
          //backgroundColor: Colors.black,
          resizeToAvoidBottomInset: true,
          //drawer: HomeWidgets.drawerMenu(context),
          appBar: AppBar(
            elevation: 0.0,
            actions: <Widget>[
              _currAppBar,
              //HomeWidgets.settingsButton(context),
            ],
            backgroundColor: Color(0xFFF2F3F8),
            title: Container(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Anywhere Forecast',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  letterSpacing: 1.1,
                  color: AppTheme.darkerText,
                ),
              ),
            ),
          ),
            // title: BlocBuilder<WeatherDataBloc, WeatherDataState>(
            //   // ignore: missing_return
            //     builder: (context, state) {
            //       if (state is WeatherLoaded) {
            //         return Text(
            //             SessionServices().currCityParsed,
            //             style: TextStyle(fontSize: 16)
            //         );
            //       }
            //       return Container();
            //     }
            // ),
          body: PageView(
            controller: _pageViewController,
            children: <Widget>[
              _weather,
              _reports,
              _wifiP2p,
              _profile,
            ],
            onPageChanged: _changePage,
          ),
          bottomNavigationBar: BottomAppBar(
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: Theme.of(context).copyWith(
              canvasColor: Color(0xff1B213B),
              primaryColor: Color(0xffFF5555),
              textTheme: Theme.of(context)
                  .textTheme
                  .copyWith(caption: new TextStyle(color: Colors.white))),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                fixedColor: Color(0xffFF5555),
                currentIndex: _currIndex,
                onTap: (index) {
                  // Fix traversal
                  _pageViewController.animateToPage(index , duration: Duration(milliseconds: 200), curve: Curves.bounceOut);
                },
                items: const<BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.description),
                    label: 'Reports',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.wifi),
                    label: 'Sharing',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                  ),

                ],
              ),
            ),
            shape: CircularNotchedRectangle(),
            color: Colors.blueGrey,
          ),
          floatingActionButton: new FloatingActionButton(
            onPressed: () => {
              Navigator.of(context).push(
                SlideRoute(page: Scaffold(body :
                  BlocProvider.value(
                    value: BlocProvider.of<ReportDataBloc>(context),
                    child: HomeFeedback(),
                  )
                ),
              )),
            },
            tooltip: 'Increment',
            child: new Icon(Icons.add),
            elevation: 4.0,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    animationController.dispose();
    super.dispose();
  }
}
