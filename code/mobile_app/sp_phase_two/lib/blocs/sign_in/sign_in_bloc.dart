import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

import '../../repository/rethink_user.dart';

import 'sign_in_event.dart';
import 'sign_in_state.dart';

/// Issues:
/// 1. Implement an input validator and sanitizer
/// 2. Include email when signing out so data in cache can be removed

class SignInBloc extends Bloc<SignInEvent, SignInState> {

  SignInBloc() : super(SignInState.empty());

  @override
  Stream<Transition<SignInEvent, SignInState>> transformEvents(
    Stream<SignInEvent> events,
    TransitionFunction<SignInEvent, SignInState> transitionFn,
  ) {
    final nonDebounceStream = events.where((event) {
      return (event is! SignInEmailChanged && event is! SignInPasswordChanged);
    });
    final debounceStream = events.where((event) {
      return (event is SignInEmailChanged || event is SignInPasswordChanged);
    }).debounceTime(Duration(milliseconds: 300));
    return super.transformEvents(
      nonDebounceStream.mergeWith([debounceStream]),
      transitionFn,
    );
  }

  @override
  Stream<SignInState> mapEventToState(SignInEvent event) async* {
    if (event is SignInEmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is SignInPasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is SignInWithGooglePressed) {
      yield* _mapSignInWithGoogleToState();
    } else if (event is SignInWithCredentialsPressed) {
      yield* _mapSignInWithEmailToState(
        email: event.email,
        password: event.password,
      );
    } else if (event is SignInWithGuest) {
      yield* _mapSignInWithGuest();
    } else if (event is SignOut) {
      yield await _mapSignOut();
    }
  }

  Stream<SignInState> _mapEmailChangedToState(String email) async* {
    //yield state.update(isEmailValid: Validator.isValidEmail(email));
    yield state.update(isEmailValid: true);
  }

  Stream<SignInState> _mapPasswordChangedToState(String password) async* {
    //yield state.update(isPasswordValid: Validator.isValidPassword(password));
    yield state.update(isPasswordValid: true);
  }

  Stream<SignInState> _mapSignInWithGoogleToState() async* {
    try {
      //await _repository.signInWithGoogle();
      yield SignInState.success();
    } catch (_) {
      yield SignInState.failure();
    }
  }

  Stream<SignInState> _mapSignInWithEmailToState({String email, String password}) async* {
    yield SignInState.loading();
    try {
      print('Signing in');
      await RethinkUser().signInWithEmail(email: email, password: password);
      print('Finished Sign in');
      yield SignInState.success();
    } catch (_) {
      yield SignInState.failure();
    }
  }

  Stream<SignInState> _mapSignInWithGuest() async* {
    yield SignInState.loading();
    try {
      //await _repository.signInAsGuest();
      await RethinkUser().signInWithEmail(email: "", password: "");
      yield SignInState.success();
    } catch (_) {
      yield SignInState.success();
    }
  }

  Future<SignInState> _mapSignOut() async {
    await RethinkUser().signOut();
    return SignInState.success();
  }
}
