import 'package:wifi_p2p/routing.dart';
import 'package:wifi_p2p/wifi_p2p.dart';
import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class OfflineServices extends Equatable {
  static RoutingTable routingTable;
  bool hasConn = false;

  OfflineServices._privateConstructor();

  static final OfflineServices _instance = OfflineServices._privateConstructor();

  factory OfflineServices() {
    return _instance;
  }

  @override
  // TODO: implement props
  List<Object> get props => [routingTable, hasConn];

}