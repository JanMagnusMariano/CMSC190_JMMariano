import 'package:equatable/equatable.dart';

/// Issues:
/// 1. Think about whether to include 'citiesCache' in .toJson() method
/// 2. Decide whether 'subbedCities' should be stored in a String in .toMap() method
/// 3. Polish code i.e decide whether variables should be private
/// 4. Implement .fromMap() method
/// 5. Add boilerplate code for adding, removing, and updating cityCache and subbedCities

// ignore: must_be_immutable
class User extends Equatable{
  final String email, firstName, lastName, lastOnline;
  int id;
  List<CityCache> citiesCache;
  List<String> subbedCities;

  static final columns = ['id', 'email', 'first_name', 'last_name'];

  User({this.email, this.firstName, this.lastName, this.citiesCache, this.subbedCities, this.lastOnline});

  @override
  List<Object> get props => [id, email, firstName, lastName, citiesCache, subbedCities, lastOnline];

  // For converting to receive HTTP call
  factory User.fromJson(Map<String, dynamic> parsedJson) {
    List<String> citySubbed = List<String>.from(parsedJson['subbed_locs']);

    return User(
      email: parsedJson['id'] as String,
      firstName: parsedJson['first_name'] as String,
      lastName: parsedJson['last_name'] as String,
      lastOnline: parsedJson['last_online'] as String,
      subbedCities: citySubbed,
    );
  }

  // For converting from local sqlite DB / cache
  factory User.fromMap(Map<String, dynamic> dbRow) {}

  // For converting to send over HTTP
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map =  {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'subbed_locs': subbedCities,
      'last_online': lastOnline,
    };

    return map;
  }

  // For converting to local sqlite DB / cache
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map =  {
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'last_online': lastOnline,
    };

    if (id != null) map['id'] = id;
    return map;
  }

  CityCache findCityCached(String cityName) {
    CityCache city;

    if (citiesCache == null || citiesCache.length == 0) return null;

    for (var i = 0; i < citiesCache.length; i++)
      if (citiesCache[i].cityName == cityName) city = citiesCache[i];

    return city;
  }

  void updateCity(CityCache newCity) {
    if (citiesCache == null || citiesCache.length == 0) return;

    for (var i = 0; i < citiesCache.length; i++) {
      if (citiesCache[i].cityName == newCity.cityName) {
        citiesCache[i] = newCity;
        break;
      }
    }
  }
}

///-----
///
///
///
///-----

// ignore: must_be_immutable
class CityCache extends Equatable{
  String cityName, newestFetch, oldestFetch, userEmail;
  int id;

  static final columns = ['id', 'city_name', 'newest_fetch', 'oldest_fetch', 'user_email'];

  CityCache({this.id, this.cityName, this.newestFetch, this.oldestFetch, this.userEmail});

  @override
  List<Object> get props => [id, cityName, newestFetch, oldestFetch, userEmail];

  factory CityCache.fromJson(Map<String, dynamic> parsedJson) {
    return CityCache(
      cityName: parsedJson['city_name'] as String,
      newestFetch: parsedJson['newest_fetch'],
      oldestFetch: parsedJson['oldest_fetch'],
      userEmail: parsedJson['user_email'],
    );
  }

  // For converting from local sqlite DB / cache
  factory CityCache.fromMap(Map<String, dynamic> dbRow) {
    return CityCache(
      id: dbRow['id'],
      cityName: dbRow['city_name'] as String,
      newestFetch: dbRow['newest_fetch'],
      oldestFetch: dbRow['oldest_fetch'],
      userEmail: dbRow['user_email'],
    );
  }

  // For converting to send over HTTP
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map =  {
      'city_name': cityName,
      'newest_fetch': newestFetch,
      'oldest_fetch': oldestFetch,
      'user_email': userEmail,
    };

    return map;
  }

  // For converting to local sqlite DB / cache
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map =  {
      'city_name': cityName,
      'newest_fetch': newestFetch,
      'oldest_fetch': oldestFetch,
      'user_email': userEmail,
    };

    if (id != null) map['id'] = id;
    return map;
  }
}