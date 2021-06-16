import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/sign_in/bloc.dart';
import '../../../blocs/settings/bloc.dart';
import '../../../blocs/weather_data/bloc.dart';
import '../../../blocs/authentication/bloc.dart';

import 'home_settings.dart';
import 'home_search.dart';

/// Issues:
/// 1. Polish a lot of the UI

class HomeWidgets {
  static AssetImage _drawerImage = AssetImage('lib/assets/images/drawer_header_background.png');

  HomeWidgets._();

  static Widget searchButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: () async {
        final city = await showSearch(
          context: context,
          delegate: HomeSearch(
            BlocProvider.of<WeatherDataBloc>(context),
            BlocProvider.of<AuthenticationBloc>(context),
          ),
        );

        if (city != null)
          BlocProvider.of<WeatherDataBloc>(context).add(FetchWeather(cityName: city));
      },
    );
  }

  static Widget settingsButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) {
            return BlocProvider.value(
              value: BlocProvider.of<SettingsBloc>(context),
              child: Settings(),
            );
          }),
        );
      },
    );
  }

  static Widget drawerMenu(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.70,
      child:  Drawer(
        child: Column(
          children: <Widget>[
            //_drawerHeader(),
      //            Expanded(
      //              child: ListView(
      //                children: <Widget>[
      //                  BlocBuilder<UserDataBloc, UserDataState>(
      //                      builder: (context, state) {
      //                        if (state is UserDataLoaded)
      //                          return homeProfileButton(context);
      //                        else
      //                          return Container();
      //                      }
      //                  ),
      //                ],
      //              ),
      //            ),
            Flexible(
                fit: FlexFit.loose,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: _logoutButton(),
                )
            ),
          ],
        ),
      ),
    );
  }

//   static Widget _drawerHeader() {
//     return DrawerHeader(
//       decoration: BoxDecoration(
//         image: DecorationImage(
//           fit: BoxFit.fill,
//           image: _drawerImage,
//         ),
//       ),
//       // Change the design
// //      child: Stack(
// //        children: <Widget>[
// //          Positioned(
// //            bottom: 12.0,
// //            left: 16.0,
// //            child: Text(
// //              'Flutter',
// //              style: TextStyle(
// //                fontSize: 20.0,
// //                color: Colors.white,
// //              ),
// //            ),
// //          ),
// //        ],
// //      ),
//     );
//   }

  static Widget _logoutButton() {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(15),
            child: FlatButton(
              padding: EdgeInsets.symmetric(vertical: 15),
              color: Colors.red.withOpacity(0.8),
              child: Text(
                'Log Out',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              onPressed: () => BlocProvider.of<SignInBloc>(context).add(SignOut()),
            ),
          );
        }

        return Container();
      },
    );
  }

}

class TitleView extends StatelessWidget {
  final String titleTxt;
  final String subTxt;
  final AnimationController animationController;
  final Animation animation;

  const TitleView(
      {Key key,
      this.titleTxt: "",
      this.subTxt: "",
      this.animationController,
      this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: new Transform(
            transform: new Matrix4.translationValues(
                0.0, 30 * (1.0 - animation.value), 0.0),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        titleTxt,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          //fontFamily: FitnessAppTheme.fontName,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          letterSpacing: 0.5,
                          //color: FitnessAppTheme.lightText,
                        ),
                      ),
                    ),
                    InkWell(
                      highlightColor: Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      onTap: () {},
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Row(
                          children: <Widget>[
                            Text(
                              subTxt,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                //fontFamily: FitnessAppTheme.fontName,
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                letterSpacing: 0.5,
                                //color: FitnessAppTheme.nearlyDarkBlue,
                              ),
                            ),
                            SizedBox(
                              height: 38,
                              width: 26,
                              child: Icon(
                                Icons.arrow_forward,
                                //color: FitnessAppTheme.darkText,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
