import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/weather_data/bloc.dart';

import '../../../repository/rethink_weather.dart';
import '../../../utils/session_services.dart';
import '../../../blocs/authentication/bloc.dart';

/// Issues
/// 1. Fix recent search as well as remove duplicate values

class HomeSearch extends SearchDelegate {
  final WeatherDataBloc weatherBloc;
  final AuthenticationBloc authBloc;
  final List<dynamic> municipalities, provinces;

  List<dynamic> recentList = [], cities = [];
  String selectedResult = '';

  HomeSearch(this.weatherBloc, this.authBloc)
      : municipalities = RethinkWeather().municipalityJson,
        provinces = RethinkWeather().provinceJson
  {
    List<String> _recentSearchParsed = SessionServices().recentSearch;

    for (var i = 0; i < _recentSearchParsed.length; i++) {
      var _split = _recentSearchParsed[i].toString().split(',');
      recentList.add({'name': _split[0], 'province': _split[1]});
    }

    for (var i = 0; i < municipalities.length; i++)
      if (municipalities[i].containsKey('city')) cities.add(municipalities[i]);
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = ThemeData(
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white)
        ),
      ),
    );
    assert(theme != null);
    return theme.copyWith(
      primaryColor: Theme.of(context).primaryColor,
      textTheme: theme.textTheme.copyWith(
        headline6: TextStyle(fontWeight: FontWeight.normal),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () => close(context, null),
    );
  }

  @override
  // ignore: missing_return
  Widget buildResults(BuildContext context) {}

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (BuildContext subContext, AuthenticationState state) {
          List<dynamic> _recommend = recentList, _subscribed = [];
          List<Widget> _body = [];

          if (_recommend.isNotEmpty)
            _body.addAll([_headers('Recent', subContext), buildRows(_recommend)]);

          if (SessionServices().currUser.subbedCities.isNotEmpty) {
            for (var toParse in SessionServices().currUser.subbedCities) {
              String parsed = (toParse.split(','))[0];
              _subscribed.addAll(cities.where((e) => e['name'].contains(parsed)));
            }

            _body.addAll([_headers('Favorites', subContext), buildRows(_subscribed)]);
          }

          return ListView(children: _body);
        },
      );
    } else {
      List<dynamic> _recommend = [];
      _recommend.addAll(cities.where((e) => e['name'].contains(query)));
      return buildRows(_recommend);
    }
  }

  Widget buildRows(List<dynamic> recommend) {

    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.all(0),
      itemCount: recommend.length,
      itemBuilder: (context, index) {
        String _currCity = recommend[index]['name'];
        String _fullEntry = _currCity + ',' + recommend[index]['province'];

        int _provIndex = provinces
            .indexWhere((e) => e['key'] == recommend[index]['province']);

        bool _isSubscribed = (SessionServices().currUser.subbedCities.isNotEmpty)
            ? SessionServices().currUser.subbedCities.contains(_fullEntry)
            : false;

        bool _userLoaded = authBloc.state is Authenticated;

        return CityRow(
          title: _currCity,
          isSubscribed: _isSubscribed,
          subtitle: provinces[_provIndex]['name'],
          canInteract: _userLoaded,
          subscribe: () {
            SessionServices().addSubscribe(_fullEntry);
            authBloc.add(SubscribeChanged(choice: true, location: _fullEntry));
          },
          unsubscribe: () {
            SessionServices().removeSubscribe(_fullEntry);
            authBloc.add(SubscribeChanged(choice: false, location: _fullEntry));
          },
          choose: () {
            SessionServices().recentSearch.add(_fullEntry);
            Navigator.pop(context, _fullEntry);
          },
        );
      },
    );
  }

  Widget _headers(String headerName, BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(15.0),
      child: Text(
        headerName,
        style: TextStyle(
          fontSize: 20,
          color: Theme.of(context).accentColor,
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CityRow extends StatefulWidget {
  String title, subtitle;
  Function subscribe, unsubscribe, choose;
  bool isSubscribed, canInteract;

  CityRow(
      {this.title,
      this.subtitle,
      this.isSubscribed,
      this.subscribe,
      this.unsubscribe,
      this.choose,
      this.canInteract});

  @override
  State<CityRow> createState() => _CityRowState();
}

class _CityRowState extends State<CityRow> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Container(
        padding: EdgeInsets.only(left: 15),
        child: Text(widget.title),
      ),
      subtitle: Container(
        padding: EdgeInsets.only(left: 15),
        child: Text(widget.subtitle, style: TextStyle(fontSize: 12)),
      ),
      trailing: widget.canInteract ? IconButton(
          icon: widget.isSubscribed
              ? Icon(Icons.close, color: Colors.red)
              : Icon(Icons.add, color: Colors.green),
          onPressed: () {
            setState(() {
              widget.isSubscribed ? widget.unsubscribe() : widget.subscribe();
              widget.isSubscribed = (!widget.isSubscribed);
            });
          }) : SizedBox(),
      onTap: widget.choose,
    );
  }
}