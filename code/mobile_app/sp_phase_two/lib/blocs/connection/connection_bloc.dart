import 'dart:async';

import 'package:connectivity/connectivity.dart';

import 'connection_state.dart';

/// Issues:
///

class ConnectionBloc {
  StreamController<ConnectionState> connController = StreamController<ConnectionState>();
  StreamSubscription<ConnectivityResult> _subscription;

  // Singleton constructor
  static final ConnectionBloc _instance = ConnectionBloc._privateConstructor();

  factory ConnectionBloc() => _instance;

  ConnectionBloc._privateConstructor() {
    // Subscribe to the connectivity Chanaged Steam
    _subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Use Connectivity() here to gather more info if you need to
      connController.add(_getStatusFromResult(result));
    });
  }

  ConnectionState _getStatusFromResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.mobile:
      case ConnectivityResult.wifi:
        return ConnectionOnline();
      case ConnectivityResult.none:
      default:
        return ConnectionOffline();
    }
  }

  void close() {
    _subscription.cancel();
    connController.close();
  }
}