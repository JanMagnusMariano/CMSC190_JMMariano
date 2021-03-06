import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class RegisterEmailChanged extends RegisterEvent {
  final String email;

  const RegisterEmailChanged({@required this.email});

  @override
  List<Object> get props => [email];

  @override
  String toString() => 'EmailChanged { email :$email }';
}

class RegisterPasswordChanged extends RegisterEvent {
  final String password;

  const RegisterPasswordChanged({@required this.password});

  @override
  List<Object> get props => [password];

  @override
  String toString() => 'PasswordChanged { password: $password }';
}

class RegisterSubmitted extends RegisterEvent {
  final String firstName, lastName, email, password;

  const RegisterSubmitted({
    @required this.firstName,
    @required this.lastName,
    @required this.email,
    @required this.password,
  });

  @override
  List<Object> get props => [firstName, lastName, email, password];

  @override
  String toString() {
    return 'Submitted { email: $email, password: $password }';
  }
}

class RegisterWithGuest extends RegisterEvent {}