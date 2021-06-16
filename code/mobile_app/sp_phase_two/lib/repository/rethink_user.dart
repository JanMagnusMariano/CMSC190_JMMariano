import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spphasetwo/utils/session_services.dart';
import 'dart:async';

import '../utils/cache_services.dart';
import '../models/user_model.dart';

/// Issues:
/// 2. Move server variables to a secure configuration file instead of hard-coding

class RethinkUser {
  static const server_url = 'http://anywhere-forecast.herokuapp.com';
  //static const server_url = '192.168.1.27:3001';
  //String _signedInEmail;
  //static const server_url = '192.168.43.178:3001';
  bool isSignedIn = false;

  final _controller = StreamController<Map<String, dynamic>>();

  // Singleton constructor
  RethinkUser._privateConstructor();

  static final RethinkUser _instance = RethinkUser._privateConstructor();

  factory RethinkUser() {
    return _instance;
  }

  Stream<Map<String, dynamic>> get status async* {
    String refreshToken = await SessionServices().getRefreshToken();
    if (refreshToken == null) yield {};
    else await refreshTokens(refreshToken: refreshToken);
    yield* _controller.stream;
  }

  Future<void> signInWithEmail({String email, String password}) async {
    // Test for offline

    print('Check');

    if (email == "" && password == "") {
      print("Offline test");
      _controller.add(null);
      return;
    }

    print('Check2');

    final http.Response res = await http.post(
      Uri.parse(server_url + '/user/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password' : password,
      }),
    );

    print('Check3');

    if (res.statusCode == 201 || res.statusCode == 200) {
      print('signed in');
      _controller.add(jsonDecode(res.body));
    } else { 

      // add null to controller so that Unauthenticated is returned
      //print('Failed in signUpWithEmail');
      _controller.add({});
    }
  }

  Future<void> refreshTokens({String refreshToken}) async {


    final http.Response res = await http.get(
      Uri.parse(server_url + '/user/refresh-session/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $refreshToken',
      },
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      print('refreshed access token');
      _controller.add(jsonDecode(res.body));
    } else {
      // add null to controller so that Unauthenticated is returned
      print('invalid refresh token');
      await SessionServices().deleteRefreshToken();
      _controller.add({});
    }
  }

  Future<void> signOut() async {
    String refreshToken = await SessionServices().getRefreshToken();

    final http.Response res = await http.get(
      Uri.parse(server_url + '/user/logout-user/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $refreshToken',
      },
    );

    if (res.statusCode == 201 || res.statusCode == 200) {
      print('deleted refresh token');

      List<CityCache> _cities = SessionServices().currUser.citiesCache;
      print(_cities);
      for (var i = 0; i < _cities.length; i++) {
        await CacheServices().upsertCityCache(_cities[i]);
      }
      //await CacheServices()
      _controller.add({});
    } else {
      // add null to controller so that Unauthenticated is returned
      print('invalid refresh token');
      await SessionServices().deleteRefreshToken();
      _controller.add({});
    }
  }

  Future<bool> signUpWithEmail (
      {String firstName, lastName, email, password}) async {
    final http.Response res = await http.post(
      new Uri.http(server_url, '/user/register/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'id' : email,
        'first_name': firstName,
        'last_name': lastName,
        'password' : password,
        'subbed_locs' : [],
      }),
    );

    if (res.statusCode == 201) {
      print('registered');
      return true;
    } else {
      print('Failed in signUpWithEmail');
      return false;
    }
  }

  //------------------ Data fetching functions ---------------------------------

  Future<User> getUserData({String accessToken, email}) async {
    final Map<String, String> queryParams = {
      'email' : email
    };

    final _uriString = '$server_url/user/get-user/?email=$email';
    print(_uriString);

    final http.Response res = await http.get(
      Uri.parse(_uriString),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $accessToken',
      },
    );

    User currModel = User.fromJson(json.decode(res.body));
    return currModel;
  }

  Future<void> changeExtra(email, bool choice, String place) async {
    if (choice) {
      final http.Response res = await http.post(
        new Uri.http(server_url, '/user/add-location/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          //'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, dynamic>{
          "email" : email,
          "location" : place,
        }),
      );
    } else {
      final http.Response res = await http.post(
        new Uri.http(server_url, '/user/remove-location/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          //'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(<String, dynamic>{
          "email" : email,
          "location" : place,
        }),
      );
    }
  }

  Future<void> updateData(
      String mainPlace, String extraPlaces, bool willKeep) async {
    User currData = await getUserData();
    List<dynamic> _extras = [];

    if (willKeep) {
      _extras.add(extraPlaces);
      for (var index = 0; index < currData.subbedCities.length; index++)
        _extras.add(currData.subbedCities[index]);
      _extras.sort();
    } else {
      currData.subbedCities.removeWhere((element) => element == extraPlaces);
      _extras = currData.subbedCities;
    }
  }

  Future<List<dynamic>> getExtraPlaces() async {
    User _currModel = await getUserData();
    return _currModel.subbedCities;
  }

  bool signedIn() => isSignedIn;

  void dispose() => _controller.close();
}
