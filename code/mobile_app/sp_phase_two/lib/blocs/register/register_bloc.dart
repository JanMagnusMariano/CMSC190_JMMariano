import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';

import '../../repository/rethink_user.dart';

import 'register_event.dart';
import 'register_state.dart';

/// Issues:
/// 1. Implement an input validator and sanitizer

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {

  RegisterBloc() : super(RegisterState.empty());

  @override
  Stream<Transition<RegisterEvent, RegisterState>> transformEvents(
    Stream<RegisterEvent> events,
    TransitionFunction<RegisterEvent, RegisterState> transitionFn,
  ) {
    final nonDebounceStream = events.where((event) {
      return (event is! RegisterEmailChanged &&
          event is! RegisterPasswordChanged);
    });
    final debounceStream = events.where((event) {
      return (event is RegisterEmailChanged ||
          event is RegisterPasswordChanged);
    }).debounceTime(Duration(milliseconds: 300));
    return super.transformEvents(
      nonDebounceStream.mergeWith([debounceStream]),
      transitionFn,
    );
  }

  @override
  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    if (event is RegisterEmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is RegisterPasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is RegisterSubmitted) {
      yield* _mapFormSubmittedToState(event.firstName, event.lastName,
          event.email, event.password);
    } else if (event is RegisterWithGuest) {
      yield* _mapRegisterWithGuest();
    }
  }

  Stream<RegisterState> _mapEmailChangedToState(String email) async* {
    //yield state.update(isEmailValid: Validator.isValidEmail(email),);
    yield state.update(isEmailValid: true);
  }

  Stream<RegisterState> _mapPasswordChangedToState(String password) async* {
    //yield state.update(isPasswordValid: Validator.isValidPassword(password),);
    yield state.update(isPasswordValid: true);
  }

  Stream<RegisterState> _mapFormSubmittedToState(String firstName, lastName,
      email, password) async* {
    yield RegisterState.loading();
    try {
      bool isRegister = await RethinkUser().signUpWithEmail(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password);

      if(isRegister) {
        await RethinkUser().signInWithEmail(email: email, password: password);
        yield RegisterState.success();
      } else RegisterState.failure();
    } catch (_) {
      yield RegisterState.failure();
    }
  }

  Stream<RegisterState> _mapRegisterWithGuest() async* {
    try {
      //await _repository.signInAsGuest();
      yield RegisterState.success();
    } catch (_) {
      yield RegisterState.success();
    }
  }
}