import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:wifi_p2p/routing.dart';

class WifiP2p {
  static const MethodChannel _channel = const MethodChannel('wifi_p2p');

  static WifiP2pEvents wifiP2pEvents = WifiP2pEvents();


  static Future<String> register() async {
    print("Flutter - register...");
    return await _channel.invokeMethod("register");
  }

  static Future<bool> unregister() async {
    print("Flutter - unregister...");
    return await _channel.invokeMethod("unregister");
  }

  static Future<bool> discoverDevices() async {
    print("Flutter - discover peers...");
    return await _channel.invokeMethod("discoverPeers");
  }

  static Future<bool> stopDiscoverDevices() async {
    print("Flutter - cancel discover peers...");
    return await _channel.invokeMethod("cancelDiscover");
  }

  static Future<bool> connect(String deviceAddress) async {
    print("Flutter - connecting to device $deviceAddress...");
    return await _channel.invokeMethod("connect", {"payload" : deviceAddress});
  }

  static Future<bool> disconnect() async {
    print("Flutter - disconnecting connections...");
    return await _channel.invokeMethod("disconnect");
  }

  static Future<bool> verifyPermissions() async {
    print("Flutter - verify permissions...");
    return await _channel.invokeMethod("verifyPermissions");
  }

  static Future<bool> restartWifi() async {
    print("Flutter - restarting wifi...");
    return await _channel.invokeMethod("restartWifi");
  }

  static Future<String> getLocalMacAddress() async {
    print("Flutter - getting address...");
    return await _channel.invokeMethod("getLocalMacAddress");
  }

  // Test

  // static Future<void> startService(String instanceName) async {
  //   print("Flutter - starting service...");
  //   _channel.invokeMethod("startService", {"payload" : instanceName});
  // }
  //
  // static Future<void> discoverServices() async {
  //   print("Flutter - discovering services...");
  //   _channel.invokeMethod("discoverServices");
  // }
  //
  // static Future<void> startAndDiscoverServices(String instanceName, int count) async {
  //   print("Flutter - starting service...");
  //   _channel.invokeMethod("startAndDiscoverServices", {"instanceName" : instanceName, "count" : count});
  // }
  //
  // static Future<void> modifyPayload(String instanceName, int count) async {
  //   print("Flutter - modifying payload...");
  //   _channel.invokeMethod("modifyPayload", {"instanceName" : instanceName, "count" : count});
  // }

  static Future<void> listenToBroadcasts() async {
    print("Flutter - listening to broadcasts...");
    _channel.invokeMethod("listenToBroadcasts");
  }
  //
  // static Future<void> toggleInternet() async {
  //   //print("Flutter - sending data...");
  //   _channel.invokeMethod("toggleInternet");
  // }
  //
  static Future<void> sendRoutePacket(String req, int limit) async {
    print("Flutter - sending route packet...");
    await _channel.invokeMethod("sendRoutePacket", {"payload" : req, "limit" : limit});
  }

  static Future<void> stopBroadcasting() async{
    print("Flutter - stopping broadcast");
    await _channel.invokeMethod("stopBroadcasting");
  }

  static Future<void> stopService() async{
    print("Flutter - forcefully stopping service");
    await _channel.invokeMethod("stopService");
  }

  // Legacy WiFi
  static Future<bool> createGroup() async {
    print("Flutter - creating group...");
    return await _channel.invokeMethod("createGroup");
  }

  static Future<bool> removeGroup() async {
    print("Flutter - removing group...");
    return await _channel.invokeMethod("removeGroup");
  }

  // Socket - Server
  static Future<WifiP2pSocket> openServerPort(int port) async {
    await _channel.invokeMethod("openServerPort", {"port": port});
    return wifiP2pEvents.registerSocket(port, true);
  }

  static Future<void> closeServerPort(int port) async {
    print("Flutter - closing server...");
    await _channel.invokeMethod("closeServerPort", {"port": port});
    wifiP2pEvents.unregisterSocket(port);
  }

  static Future<bool> acceptClient(int port) async {
    return await _channel.invokeMethod("acceptClient", {"port": port});
  }

  // Socket - Client
  static Future<WifiP2pSocket> connectToServer(String serverAddress, int port) async {
    bool isConnected = await _channel.invokeMethod("connectToServer", {
      "serverAddress": serverAddress,
      "port": port,
    });

    if(isConnected) return wifiP2pEvents.registerSocket(port, false);
    else return null;
  }

  static Future<bool> disconnectFromServer(int port) async {
    return await _channel.invokeMethod("disconnectFromServer", {"port": port});
  }

  // Utility functions
  static Future<bool> sendData(int port, bool isHost, String payload) async {
    String action = (isHost) ? 'sendDataToClient' : 'sendDataToServer';
    return await _channel.invokeMethod(action, {
      "payload": payload,
      "port": port,
    });
  }

  static Future<bool> checkBroadcastState() async {
    return await _channel.invokeMethod("checkBroadcastState");
  }

  // AODV Initialization
  static WifiP2pRoutePacket openRoutePacket() {
    return wifiP2pEvents.registerRoutePacket();
  }
}

class WifiP2pEvents {
  static const EventChannel _peerEventChannel = EventChannel('wifi_p2p/peers-change');
  static const EventChannel _connEventChannel = EventChannel('wifi_p2p/conn-change');
  static const EventChannel _socketChannel = EventChannel('wifi_p2p/socket');
  static const EventChannel _packetChannel = EventChannel('wifi_p2p/route-packet');

  static Stream<List<String>> _peerChangeStream;
  static Stream<WifiP2pInfo> _connChangeStream;
  static Stream<WifiP2pMessage> _socketStream;
  static Stream<String> _packetStream;

  Map<int, WifiP2pSocket> sockets = {};

  WifiP2pEvents() {
    _socketStream = _socketChannel.receiveBroadcastStream().map((event) {
      Map<String, dynamic> data = new Map<String, dynamic>.from(event);
      return WifiP2pMessage.fromJson(data);
    });

    _packetStream = _packetChannel.receiveBroadcastStream().map((event) {
      print("Flutter - " + event);
      // Change this
      // if(event.toString().contains("rreq")) {
      //   return RouteRequest.fromRequestString(event);
      // } else {
      //   return null;
      // }
      return event;
    });
  }

  // Socket methods

  WifiP2pSocket registerSocket(int port, bool isHost) {
    if(sockets[port] == null) {
      sockets[port] = WifiP2pSocket(port, isHost, _socketStream.where((e) {
        return e.port == port;
      }));
    }

    return sockets[port];
  }

  void unregisterSocket(int port) {
    if(sockets[port] == null) return;
    sockets.remove(port);
  }

  // Route packet methods

  WifiP2pRoutePacket registerRoutePacket() {
    return WifiP2pRoutePacket(_packetStream);
  }

  // Stream methods

  Stream<List<String>> get peerChange {
    _peerChangeStream = _peerEventChannel.receiveBroadcastStream().map((event) {
      List<String> devices = new List<String>();
      List<dynamic> result = event;

      for(int i = 0; i < result.length; i++) {
        devices.add(result[i].toString());
      }

      return devices;
    });
    return _peerChangeStream;
  }

  Stream<WifiP2pInfo> get connChange {
    _connChangeStream = _connEventChannel.receiveBroadcastStream().map((event) {
      Map<String, dynamic> data = new Map<String, dynamic>.from(event);
      return WifiP2pInfo.fromJson(data);
    });
    return _connChangeStream;
  }
}

// Custom Classes

class WifiP2pSocket {
  bool isHost;
  int port;
  Stream<WifiP2pMessage> _inStream;

  Stream<WifiP2pMessage> get inStream => _inStream;

  WifiP2pSocket(this.port, this.isHost, this._inStream);

  Future<bool> write(String payload) async {
    return WifiP2p.sendData(port, isHost, payload);
  }
}

class WifiP2pRoutePacket {
  Stream<String> _packetStream;

  Stream<String> get packetStream => _packetStream;

  WifiP2pRoutePacket(this._packetStream);
}

// JSON Model

class WifiP2pMessage {
  int port, dataAvailable;
  String payload;

  WifiP2pMessage({this.port, this.dataAvailable, this.payload});

  factory WifiP2pMessage.fromJson(Map<String, dynamic> parsedJson) {
    return WifiP2pMessage(
      port: parsedJson['port'],
      dataAvailable: parsedJson['dataAvailable'],
      payload: parsedJson['payload']
    );
  }
}

class WifiP2pInfo {
  bool isHost, isConnected;
  String serverAddress, deviceAddress;

  WifiP2pInfo({this.isHost, this.isConnected, this.serverAddress, this.deviceAddress});

  factory WifiP2pInfo.fromJson(Map<String, dynamic> parsedJson) {
    return WifiP2pInfo(
      isHost: parsedJson['isHost'],
      isConnected: parsedJson['isConnected'],
      serverAddress: parsedJson['serverAddress'],
      deviceAddress: parsedJson['deviceAddress'],
    );
  }
}

