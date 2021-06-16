import 'package:equatable/equatable.dart';

abstract class OfflineTransferEvent extends Equatable {
  const OfflineTransferEvent();
}

class ListenToBroadcast extends OfflineTransferEvent {
  @override
  List<Object> get props => [];
}

class BroadcastAsSource extends OfflineTransferEvent {
  @override
  List<Object> get props => [];
}

// ignore: must_be_immutable
class BroadcastAsPasser extends OfflineTransferEvent {
  String message;

  BroadcastAsPasser({this.message});

  @override
  List<Object> get props => [message];
}

class ReceivePacket extends OfflineTransferEvent {
  @override
  List<Object> get props => [];
}

// ignore: must_be_immutable
class SystemEvent extends OfflineTransferEvent {
  String message;

  SystemEvent({this.message});

  @override
  List<Object> get props => [message];
}

class StopService extends OfflineTransferEvent {
  @override
  List<Object> get props => [];
}