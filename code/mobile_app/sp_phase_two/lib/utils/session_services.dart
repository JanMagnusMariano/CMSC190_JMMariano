import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:equatable/equatable.dart';

import '../models/user_model.dart';
import '../models/weather_model.dart';

/// Issues:
/// 1. Add way to delete refresh token
/// 2. Save recent search in memory, then save to cache after app termination
/// 3. Provide proper getters and setters
/// 4. Implement null safety in 'setRefreshToken', i.e upgrade flutter_secure_storage to 4.0.0

// ignore: must_be_immutable
class SessionServices extends Equatable {
  final _storage = new FlutterSecureStorage();
  String accessToken;
  String refreshToken;
  User currUser;

  // temp
  String currCityRaw, currCityParsed;
  List<String> recentSearch = [];

  // Singleton constructor
  SessionServices._privateConstructor();

  static final SessionServices _instance = SessionServices._privateConstructor();

  factory SessionServices() {
    return _instance;
  }

  // Boilerplate code for clarity
  void addSubscribe(String cityName) => this.currUser.subbedCities.add(cityName);

  void removeSubscribe(String cityName) => this.currUser.subbedCities.remove(cityName);

  void setAccessToken(String accessToken) => this.accessToken = accessToken;

  String getAccessToken() => this.accessToken;

  Future<void> setRefreshToken(String refreshToken) async {
    this.refreshToken = refreshToken;
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: 'refresh_token');
  }

  Future<String> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  @override
  List<Object> get props => [accessToken, currUser, recentSearch];
}
