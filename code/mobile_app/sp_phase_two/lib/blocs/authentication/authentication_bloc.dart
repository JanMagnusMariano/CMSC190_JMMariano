import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../repository/rethink_user.dart';
import '../../utils/session_services.dart';
import '../../models/user_model.dart';
import '../../utils/cache_services.dart';

import 'authentication_event.dart';
import 'authentication_state.dart';

/// Issues
/// 3. Consider whether to create new AuthenticationState AuthenticatedAsGuest
/// 6. Consider whether to save accessToken in cache and long expire time (1 day?) since app does not need to be super strict

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  StreamSubscription<Map<String, dynamic>> _userSubscription;

  AuthenticationBloc() : super(Initial()) {
    _userSubscription = RethinkUser().status.listen(
          (user) => add(AuthenticationChanged(user))
    );
  }

  @override
  Stream<AuthenticationState> mapEventToState(AuthenticationEvent event) async* {
    if (event is AuthenticationChanged) {
      print("Auth change");
      yield* _mapAuthenticationChanged(event);
    } else if (event is DataChanged) {
      yield* _mapDataChanged(event, state);
    } else if (event is SubscribeChanged) {
      await _mapSubscribeChanged(event);
    }
  }

  Stream<AuthenticationState> _mapDataChanged(DataChanged event, AuthenticationState state) async* {
    if (state is Authenticated) {
      yield AuthenticatedTransition();
      yield state.copyWith();
    }
  }

  Stream<AuthenticationState> _mapAuthenticationChanged(AuthenticationChanged event) async* {
    yield AuthenticatedTransition();

    if (event.jsonBody == null) {
      //yield Unauthenticated();
      print("Testing for offline");
      yield Authenticated();
    } else {
      // Fetch rest of user data
      if(event.jsonBody['access'] == null) yield Unauthenticated();
      else {
        // Store access token in memory, refresh token in secure_storage
        SessionServices().setAccessToken(event.jsonBody['access']);
        await SessionServices().setRefreshToken(event.jsonBody['refresh']);
        // Get user data from server
        User currUser = await RethinkUser().getUserData(
            accessToken: event.jsonBody['access'],
            email: event.jsonBody['email'],
        );
        // Check if user.cityCache is stored in memory
        SessionServices().currUser = currUser;
        // temp
        //await CacheServices().deleteTables();
        print('here?');
        print(currUser.email);
        currUser.citiesCache = await CacheServices().getCityCache(currUser.email);
        print('here2?');
        print(currUser.toMap());
        await CacheServices().upsertUser(currUser);
        print('here3?');

        yield Authenticated(accessToken: event.jsonBody['access']);
      }
    }
  }

  Future<void> _mapSubscribeChanged(SubscribeChanged event) async {
    String currEmail = SessionServices().currUser.email;
    await RethinkUser().changeExtra(currEmail, event.choice, event.location);
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }
}
