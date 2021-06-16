import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class Initial extends AuthenticationState {}

class Unauthenticated extends AuthenticationState {}

class AuthenticatedGuest extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final String accessToken;

  Authenticated({this.accessToken});

  Authenticated copyWith({
    String accessToken
  }) {
    return Authenticated(
      accessToken: accessToken ?? this.accessToken,
    );
  }

  @override
  List<Object> get props => [accessToken];

  @override
  String toString() => 'Authenticated { $accessToken }';
}

class AuthenticatedTransition extends AuthenticationState {}