import 'package:equatable/equatable.dart';

abstract class ConnectionEvent extends Equatable {
  const ConnectionEvent();
  @override
  List<Object> get props => [];
}

class ListenConnection extends ConnectionEvent {}

class RetryConnection extends ConnectionEvent {}