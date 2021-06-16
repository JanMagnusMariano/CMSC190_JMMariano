import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// ignore: must_be_immutable
class AuthenticationChanged extends AuthenticationEvent {
  Map<String, dynamic> jsonBody;

  AuthenticationChanged(Map<String, dynamic> jsonBody) {
    this.jsonBody = jsonBody;
  }

  @override
  List<Object> get props => [jsonBody];
}

class DataChanged extends AuthenticationEvent {
  final String accessToken;

  DataChanged({this.accessToken});

  @override
  List<Object> get props => [accessToken];
}

class SubscribeChanged extends AuthenticationEvent {
  final bool choice;
  final String location;
  
  SubscribeChanged({this.choice, this.location});

  @override
  List<Object> get props => [choice, location];
}