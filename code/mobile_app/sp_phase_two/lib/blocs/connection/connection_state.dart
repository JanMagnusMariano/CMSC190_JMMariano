import 'package:equatable/equatable.dart';

abstract class ConnectionState extends Equatable {
  const ConnectionState();
  @override
  List<Object> get props => [];
}

class ConnectionOnline extends ConnectionState {}

class ConnectionOffline extends ConnectionState {}