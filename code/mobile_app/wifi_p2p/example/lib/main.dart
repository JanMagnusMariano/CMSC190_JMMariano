import 'package:flutter/material.dart';
import 'package:wifi_p2p/routing.dart';
import 'dart:async';

import 'package:wifi_p2p/wifi_p2p.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  List<StreamSubscription> _subscriptions = [];
  List<String> _currPeers = [];
  List<String> _currPackets = [];

  bool _isConnected = false;
  bool _isHost = false;
  bool _isOpen = false;
  bool hasConn = false;
  bool _isBroadcasting = false;
  bool _hasReply = false;

  String _serverAddress = "";
  String _deviceName = "";
  WifiP2pSocket _socket;
  WifiP2pRoutePacket _routePacket;
  RoutingTable _routeTable;

  List<RouteRequest> _reqList = List<RouteRequest>();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initPlatformState() async {
    await WifiP2p.verifyPermissions();

    _subscriptions.add(WifiP2p.wifiP2pEvents.peerChange.listen((res) {
      if(_currPeers != res) {
        setState(() {
          _currPeers = res;
        });if
      } else if(res.isEmpty) {
        setState(() {
          _currPeers = res;
        });
      }
    }));

    _subscriptions.add(WifiP2p.wifiP2pEvents.connChange.listen((res) {
      print(res.deviceAddress);

      setState(() {
        if(!res.isConnected && !res.isHost) {
          _isOpen = false;
          if(_isConnected) {
            if(_isHost) WifiP2p.closeServerPort(8888);
            else WifiP2p.disconnectFromServer(8888);
          }
        }

        if(res.deviceAddress != null) {
          _deviceName = res.deviceAddress;
        }
        _isConnected = res.isConnected;
        _isHost = res.isHost;
        _serverAddress = res.serverAddress;
      });
    }));

    WifiP2pRoutePacket routePacket = WifiP2p.openRoutePacket();

    setState(() {
      _routePacket = routePacket;
    });

    _routePacket.packetStream.listen((event) async {
      print('Received packet : ' + event.toString());

      if(event.toString().contains("rreq")) {
        RouteRequest _req = RouteRequest.fromRequestString(event);
        //_currPackets.add(_req);

        if(_req.srcAddress == _routeTable.deviceAddress) {

        } else {
            RoutingTableEntry _entry = new RoutingTableEntry(
                _req.srcAddress, _req.senderAddress,
                _req.srcSequence, _req.hopCount, false);

          List<String> addressList = _routeTable.routeTable.map((e) => e.destAddress).toList();

          if(addressList.contains(_req.srcAddress)) {
            // Check sequence number or hop count or other relevant data
            int entryIndex = addressList.indexOf(_req.srcAddress);
            print('Index : ' + entryIndex.toString());
            RoutingTableEntry _tableEntry = _routeTable.routeTable[entryIndex];

            if(_tableEntry.destSequence < _entry.destSequence) {
              _routeTable.routeTable[entryIndex] = _entry;

              if (hasConn) {
                //List<String> _registered = _routeTable.routeTable.map((e) => e.destAddress).toList();

                _routeTable.seqNumber++;
                RouteReply _currRep = new RouteReply("rrep", _routeTable.deviceAddress,
                    _routeTable.deviceAddress, _req.srcAddress, _routeTable.seqNumber, _req.hopCount);

                print("eh1?");
                WifiP2p.sendRoutePacket(_currRep.toReplyString(), 10);
              } else {
                RouteRequest _currReq = new RouteRequest("rreq", _req.srcAddress,
                    _routeTable.deviceAddress, _req.destAddress, _req.srcSequence,
                    _req.destSequence, _req.reqId, _req.hopCount + 1);

                print("eh2?");
                WifiP2p.sendRoutePacket(_currReq.toRequestString(), 10);
              }
            } else if(_tableEntry.destSequence == _entry.destSequence &&
                _tableEntry.hopCount > _entry.hopCount) {
              _routeTable.routeTable[entryIndex] = _entry;

              if (hasConn) {
                //List<String> _registered = _routeTable.routeTable.map((e) => e.destAddress).toList();

                _routeTable.seqNumber++;
                RouteReply _currRep = new RouteReply("rrep", _routeTable.deviceAddress,
                    _routeTable.deviceAddress, _req.srcAddress, _routeTable.seqNumber, _req.hopCount);

                print("eh1?");
                WifiP2p.sendRoutePacket(_currRep.toReplyString(), 10);
              } else {
                RouteRequest _currReq = new RouteRequest("rreq", _req.srcAddress,
                    _routeTable.deviceAddress, _req.destAddress, _req.srcSequence,
                    _req.destSequence, _req.reqId, _req.hopCount + 1);

                print("eh2?");
                WifiP2p.sendRoutePacket(_currReq.toRequestString(), 10);
              }
            } else {
              print("Duplcate packet");
            }
          } else {
            _routeTable.routeTable.add(_entry);

            if (hasConn) {
              //List<String> _registered = _routeTable.routeTable.map((e) => e.destAddress).toList();

              _routeTable.seqNumber++;
              RouteReply _currRep = new RouteReply("rrep", _routeTable.deviceAddress,
                  _routeTable.deviceAddress, _req.srcAddress, _routeTable.seqNumber, _req.hopCount);

              print("eh1?");
              WifiP2p.sendRoutePacket(_currRep.toReplyString(), 10);
            } else {
              RouteRequest _currReq = new RouteRequest("rreq", _req.srcAddress,
                  _routeTable.deviceAddress, _req.destAddress, _req.srcSequence,
                  _req.destSequence, _req.reqId, _req.hopCount + 1);

              print("eh2?");
              WifiP2p.sendRoutePacket(_currReq.toRequestString(), 10);
            }
          }
        }
      } else if(event.toString().contains("rrep")) {
        print("Reply packet received, begin transferring data");

        RouteReply _rep = RouteReply.fromReplyString(event);

        if(_rep.srcAddress == _routeTable.deviceAddress) {
          // check in routing table first if sequence number is valid
          // then check if destination's sequence number is greater or equal to curr sequence number

          RoutingTableEntry _entry = new RoutingTableEntry(
              _rep.destAddress, _rep.senderAddress,
              _rep.destSequence, _rep.hopCount, true);

          List<String> addressList = _routeTable.routeTable.map((e) => e.destAddress).toList();

          // kung wala idagdag
          if(addressList.contains(_rep.destAddress)) {
            // Check sequence number or hop count or other relevant data
            int entryIndex = addressList.indexOf(_rep.destAddress);
            print('Index : ' + entryIndex.toString());
            RoutingTableEntry _tableEntry = _routeTable.routeTable[entryIndex];

            if(_tableEntry.destSequence < _rep.destSequence) {
              _routeTable.routeTable[entryIndex] = _entry;

              _hasReply = true;
              _currPackets.add(_rep.destAddress);
              print("Trying to connect");
              WifiP2p.stopService();
              await new Future.delayed(new Duration(milliseconds: 5000));
              WifiP2p.connect(_rep.destAddress);
            } else if(_tableEntry.destSequence == _rep.destSequence &&
                _tableEntry.hopCount > _rep.hopCount) {
              _routeTable.routeTable[entryIndex] = _entry;

              _hasReply = true;
              _currPackets.add(_rep.destAddress);
              print("Trying to connect");
              WifiP2p.stopService();
              await new Future.delayed(new Duration(milliseconds: 5000));
              WifiP2p.connect(_rep.destAddress);
            }
          } else {
            _routeTable.routeTable.add(_entry);

            _hasReply = true;

            setState(() {
              _currPackets.add(_rep.destAddress);
            });

            print("Trying to connect111");
            WifiP2p.stopService();
            await new Future.delayed(new Duration(milliseconds: 5000));
            WifiP2p.connect(_rep.destAddress);
          }
        } else {
          // Check if route entry exists
          RoutingTableEntry _entry = new RoutingTableEntry(
              _rep.destAddress, _rep.senderAddress,
              _rep.destSequence, _rep.hopCount, true);

          if(_routeTable.routeTable.contains(_entry)) {
            print("Duplicate request");
            // Check sequence number or hop count or other relevant data
          } else {
            _routeTable.routeTable.add(_entry);
          }

          RouteReply _currRep = new RouteReply("rrep", _rep.destAddress,
              _routeTable.deviceAddress, _rep.srcAddress, _rep.destSequence,
              _rep.hopCount + 1);

          print("eh3?");
          WifiP2p.sendRoutePacket(_currRep.toReplyString(), 10);
        }
      }
      // check if seqNum is greater
      // if yes, update
      // if no, check if equal
      // if yes, check if hop count is same
      // if yes, ignore
      // if no, update because shorter path
      // if no, ignore because seqNum is less
    });

    await WifiP2p.register();
    _deviceName = await WifiP2p.getLocalMacAddress();
    _routeTable = new RoutingTable(_deviceName, hasConn);

    print("Device address " + _deviceName);
    WifiP2p.listenToBroadcasts();
  }

  Future<void> openPortAndAccept(int port) async {
    print('Is open: ' + _isOpen.toString());

    if(!_isOpen) {
      WifiP2pSocket socket = await WifiP2p.openServerPort(port);
      setState(() {
        _socket = socket;
      });

      socket.inStream.listen((event) {
        print('Received : ' + event.payload);
      });

      _isOpen = await WifiP2p.acceptClient(port);
    }
  }

  Future<void> connectToPort(int port) async {
    print('Flutter - Connect to port');

    WifiP2pSocket socket = await WifiP2p.connectToServer(_serverAddress, port);
    setState(() {
      _socket = socket;
    });

    _socket.inStream.listen((event) {
      print('Sent : ' + event.payload);
    });
  }

  void broadcastRequest() async {
    RouteRequest _currReq;
    // check first destination w shortest hop count and valid
    _currReq = new RouteRequest("rreq", _routeTable.deviceAddress, _routeTable.deviceAddress,
        null, _routeTable.seqNumber, null, _routeTable.broadcastId, 0);

    _reqList.add(_currReq);

    _hasReply = false;
    for(var i = 0; i < 3; i++) {
      if(_hasReply) {
        print("Flutter - Reply received");
        break;
      }

      _currReq = new RouteRequest("rreq", _routeTable.deviceAddress, _routeTable.deviceAddress,
          null, _routeTable.seqNumber, null, _routeTable.broadcastId, 0);

      if(_reqList.isEmpty) {
        _reqList.add(_currReq);
      } else {
        for(var i = 0; i < _reqList.length; i++) {
          if(_reqList[i].srcAddress == _currReq.srcAddress) {
            if(_reqList[i].srcSequence < _currReq.srcSequence) {
              _reqList[i] = _currReq;
            }
          }
        }
      }

      WifiP2p.sendRoutePacket(_currReq.toRequestString(), (i + 1) * 10);
      while(!_hasReply && (!await WifiP2p.checkBroadcastState())) {
        await new Future.delayed(new Duration(milliseconds: 1000));
      }

      if(!_hasReply) {
        print("Flutter - packet exceeded, retrying");
        await WifiP2p.stopService();
        _routeTable.seqNumber++;
        await WifiP2p.restartWifi();
        await new Future.delayed(new Duration(milliseconds: 5000));
      }
    }

    if(!_hasReply) {
      WifiP2p.listenToBroadcasts();
      print("Flutter - packet exceeded, no more retrying");
    }
  }

  void restartWifi() async {
    await WifiP2p.stopService();
    await WifiP2p.restartWifi();
    await new Future.delayed(new Duration(milliseconds: 5000));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(_platformVersion),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton(
                  child: Text("Create group"),
                  onPressed: () async {
                    await WifiP2p.createGroup();
                  },
                ),
                ElevatedButton(
                  child: Text("Remove group"),
                  onPressed: () async {
                    await WifiP2p.removeGroup();
                  },
                ),

                ElevatedButton(
                  child: Text("Listen"),
                  onPressed: () {
                    WifiP2p.listenToBroadcasts();
                  },
                ),
                ElevatedButton(
                  child: Text("Send route packet"),
                  onPressed: () async {
                    bool hasRoute = false;

                    for(var i = 0; i < _routeTable.routeTable.length; i++) {
                      // find lowest hop count and hasConn
                      if(_routeTable.routeTable[i].hasConn) {
                        //send data
                        print("Valid route found");
                        print("Trying to connect");
                        WifiP2p.stopService();
                        await new Future.delayed(new Duration(milliseconds: 5000));
                        WifiP2p.connect(_routeTable.routeTable[i].destAddress);
                      }
                    }
                    if(!hasRoute) broadcastRequest();
                    //await WifiP2p.sendRoutePacket(_currReq.toRequestString());
                  },
                ),
                ElevatedButton(
                  child: Text("Toggle internet"),
                  onPressed: () {
                    print("Flutter - Simulating internet on");
                    hasConn = true;
                  },
                ),
                ElevatedButton(
                  child: Text("Restart Wifi"),
                  onPressed: () async {
                    restartWifi();
                  },
                ),
                ElevatedButton(
                  child: Text("KILL SERVICE"),
                  onPressed: () async {
                    await WifiP2p.stopService();
                    // setState(() {
                    //   _currPackets = [];
                    // });
                  },
                ),
                // ElevatedButton(
                //   child: Text("Discover services"),
                //   onPressed: () {
                //     WifiP2p.discoverServices();
                //   },
                // ),
                ElevatedButton(
                  child: Text("Discover peers"),
                  onPressed: () async {
                    await WifiP2p.discoverDevices();
                  },
                ),
                Column(
                  children: _currPackets.map((e) {
                    return ListTile(
                      title: Text(e),
                      onTap: () async {
                        await WifiP2p.connect(e);
                      },
                    );
                  }).toList(),
                ),
                Column(
                  children: _currPeers.map((e) {
                    return ListTile(
                      title: Text(e),
                      onTap: () async {
                        await WifiP2p.connect(e);
                      },
                    );
                  }).toList(),
                ),
                (_isConnected) ?
                ElevatedButton(
                    child: Text("Disconnect"),
                    onPressed: () async {
                      _currPeers = [];
                      _isOpen = false;
                      if(_isHost) await WifiP2p.closeServerPort(8888);
                      else await WifiP2p.disconnectFromServer(8888);
                      WifiP2p.wifiP2pEvents.unregisterSocket(8888);
                      await WifiP2p.disconnect();
                      _socket = null;
                    }
                ) :
                Container(),
                (_isConnected && _isHost) ? Container(child: Text("is host"))
                    : Container(child: Text("is client")),
                (_isConnected) ?
                ListTile(
                  title: Text("Open and accept data from port 8888"),
                  subtitle: _isConnected ? Text("Active") : Text("Disable"),
                  onTap: _isConnected && _isHost ? () async => await openPortAndAccept(8888) : () => showError(),
                ) :
                Container(),
                (_isConnected) ?
                ListTile(
                  title: Text("Connect to port 8888"),
                  subtitle: Text("This is available to only Client"),
                  onTap: _isConnected && !_isHost ? () async => await connectToPort(8888) : () => showError(),
                ) :
                Container(),
                (_isConnected) ?
                ListTile(
                  title: Text("Send hello world"),
                  onTap: _isConnected ? () => _socket.write("Hello World") : null,
                ) :
                Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showError() {
    print('Returned null');
    print('_isConnected: ' + _isConnected.toString());
    print('_isHost: ' + _isHost.toString());
  }

  @override
  void dispose() {

    super.dispose();
    WifiP2p.stopDiscoverDevices();
    WifiP2p.unregister();
  }
}
