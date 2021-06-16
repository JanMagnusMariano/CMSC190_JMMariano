import 'dart:async';
import 'package:rxdart/rxdart.dart';

import 'package:bloc/bloc.dart';
import 'package:spphasetwo/blocs/offline_transfer/bloc.dart';
import 'package:wifi_p2p/routing.dart';
import 'package:wifi_p2p/wifi_p2p.dart';

import '../../utils/offline_services.dart';

import 'offline_transfer_event.dart';
import 'offline_transfer_state.dart';

// Logging
import 'package:logger/logger.dart';
import '../../utils/custom_logger.dart';

class OfflineTransferBloc extends Bloc<OfflineTransferEvent, OfflineTransferState> {
  StreamSubscription peerStream, connStream, packetStream;
  WifiP2pRoutePacket routingPacket;
  WifiP2pSocket socket;

  String serverAddress;
  bool isConnected = false;
  bool hasReply = false;
  var logger = Logger(output: new FileOutput(), printer: new FilePrinter());

  List<String> logs = [];

  // @override
  // Stream<Transition<OfflineTransferEvent, OfflineTransferState>> transformEvents(
  //     Stream<OfflineTransferEvent> events,
  //     TransitionFunction<OfflineTransferEvent, OfflineTransferState> transitionFn,
  //     ) {
  //   return super.transformEvents(
  //     events.debounceTime(const Duration(milliseconds: 500)),
  //     transitionFn,
  //   );
  // }

  OfflineTransferBloc() : super(OfflineTransfer());

  void initStreams() {
    logs.add('Initialize streams');
    logger.d('Initialize application');
    add(SystemEvent(message: "Initialize Streams"));

    peerStream = WifiP2p.wifiP2pEvents.peerChange.listen((res) => {
      print("Peer : " + res.toString())
    });

    connStream = WifiP2p.wifiP2pEvents.connChange.listen((res) async {
      print("Conn : " + res.toString());
      print("Conn : " + res.serverAddress);
      serverAddress = res.serverAddress;
      isConnected = res.isConnected;
      if(isConnected) {
        print('ISCONNECTED, SHOW BUTTONS');
        hasReply = true;
        print('hasreply');
        if (res.isHost) await openPortAndAccept(8888);
        else {
          //await Future.delayed(new Duration(seconds: 1));
          await connectToPort(8888);
        }

        logger.d('Wi-Fi Direct connection to ' + serverAddress);
        add(SystemEvent(message : "Connected to destination"));
      }
    });

    routingPacket = WifiP2p.openRoutePacket();
    packetStream = routingPacket.packetStream.listen((res) async => {
      //if()
      routePacket(res)
    });
  }

  @override
  Stream<OfflineTransferState> mapEventToState(
    OfflineTransferEvent event,
  ) async* {
    // TODO: implement mapEventToState
    if (event is ListenToBroadcast) {
      await WifiP2p.listenToBroadcasts();
      logger.d('Started listening for broadcasts');
      logs.add("Started listening to broadcasts");
      yield new OfflineTransfer(message : "Started listening to broadcasts");
    } else if (event is BroadcastAsSource) {
      yield* _mapBroadcastPacketToState(event);
    } else if (event is BroadcastAsPasser) {
      yield new OfflineTransfer(message : "Rebroadcasting packet");
    } else if (event is ReceivePacket) {
      yield new OfflineTransfer(message : "Received packet");
    } else if (event is SystemEvent) {
      yield new OfflineTransfer(message : event.message);
    } else if (event is StopService) {
      await WifiP2p.stopService();
      logs.add("Stopped Service");
      logger.d('Stopped Service');
      yield new OfflineTransfer(message : "Stopped Service");
    }
  }

  Stream<OfflineTransferState> _mapBroadcastPacketToState(BroadcastAsSource event) async* {
    RouteRequest _currReq;
    //RoutingTable _rt = OfflineServices.routingTable;
    hasReply = false;

    // Check routing table if any valid route has been found

    // If none, broadcast normally
    for(var i = 0; i < 3; i++) {
      if(hasReply) {
        print("Flutter - Reply received");
        break;
      }
      RoutingTable _rt = OfflineServices.routingTable;

      _currReq = new RouteRequest("rreq", _rt.deviceAddress, _rt.deviceAddress,
          null, _rt.seqNumber, null, _rt.broadcastId, 1);

      logs.add("Broadcasting packet : " + _currReq.toRequestString());
      logger.d("Broadcasting packet : " + _currReq.toRequestString());
      WifiP2p.sendRoutePacket(_currReq.toRequestString(), (i + 1) * 10);

      yield new OfflineTransfer(message : "Broadcasting packet : ");

      while(!await WifiP2p.checkBroadcastState()) {
        await new Future.delayed(new Duration(milliseconds: 1000));
      }

      if(!hasReply) {
        logs.add("Flutter - packet exceeded, retrying");
        logger.d("Packet exceeded, Retrying, Current Sequence number : " + _rt.seqNumber.toString());
        await WifiP2p.stopService();
        OfflineServices.routingTable.seqNumber++;
        //await WifiP2p.restartWifi();
        //await new Future.delayed(new Duration(milliseconds: 5000));
      }
    }

    RoutingTable _rt = OfflineServices.routingTable;

    if(!hasReply) {
      WifiP2p.listenToBroadcasts();
      print("Flutter - packet exceeded, no more retrying");
      logger.d("Timeout, No more retry, Current Sequence number : " + _rt.seqNumber.toString());
    }
  }

  // AODV Implementation
  void routePacket(String packet) {
    print("Testing : " + packet);

    if (packet.contains("rreq")) {
      RouteRequest _req = RouteRequest.fromRequestString(packet);
      // Change to something else
      if (!logs.contains(_req.toRequestString())) {
        logs.add(_req.toRequestString());
        add(ReceivePacket());
        rebroadcastRequest(_req);
      } else {
        // Check sequence number
        print("Duplicate request packet " + _req.toRequestString());
      }
    } else if (packet.contains("rrep")) {
      RouteReply _rep = RouteReply.fromReplyString(packet);
      // Change to something else
      if (!logs.contains(_rep.toReplyString())) {
        logs.add(_rep.toReplyString());
        logger.d('Received RREP : ' + _rep.toReplyString());
        add(ReceivePacket());
        rebroadcastReply(_rep);
      } else {
        // Check sequence number
        print("Duplicate reply packet " + _rep.toReplyString());
      }
    }
  }

  void rebroadcastRequest(RouteRequest req) {
    RoutingTable _rt = OfflineServices.routingTable;

    if (req.srcAddress == _rt.deviceAddress) {
      // Source receives its own RREQ
    } else {
      RoutingTableEntry _entry = new RoutingTableEntry(
          req.srcAddress, req.senderAddress,
          req.srcSequence, req.hopCount, false);

      List<String> addressList = _rt.routeTable.map((e) => e.destAddress).toList();

      if (addressList.contains(req.srcAddress)) {
        // If route is already registered
        int entryIndex = addressList.indexOf(req.srcAddress);
        print('Index : ' + entryIndex.toString());
        RoutingTableEntry _tableEntry = _rt.routeTable[entryIndex];

        if (_tableEntry.destSequence < _entry.destSequence) {
          _rt.routeTable[entryIndex] = _entry;
          _decideRebroadcast(req, _rt);
        } else if (_tableEntry.destSequence == _entry.destSequence &&
            _tableEntry.hopCount > _entry.hopCount) {
          _rt.routeTable[entryIndex] = _entry;
          _decideRebroadcast(req, _rt);
        } else {
          print("Duplicate packet");
        }
      } else {
        // If route is new
        _rt.routeTable.add(_entry);
        _decideRebroadcast(req, _rt);
      }
    }
  }

  void _decideRebroadcast(RouteRequest req, RoutingTable rt) {
    if (OfflineServices().hasConn) {
      // Send Reply because this is destination
      rt.seqNumber++;
      RouteReply _currRep = new RouteReply("rrep", rt.deviceAddress,
          rt.deviceAddress, req.srcAddress, rt.seqNumber, req.hopCount);

      // Change to something else
      logs.add("Replying : " + _currRep.toReplyString());
      logger.d('Sending RREP : ' + _currRep.toReplyString());
      WifiP2p.sendRoutePacket(_currRep.toReplyString(), 10);
      add(BroadcastAsPasser(message : _currRep.toReplyString()));
    } else {
      RouteRequest _currReq = new RouteRequest("rreq", req.srcAddress,
          rt.deviceAddress, req.destAddress, req.srcSequence,
          req.destSequence, req.reqId, req.hopCount + 1);

      // Change to something else
      logs.add("Rebroadcasting : " + _currReq.toRequestString());
      logger.d('Rebroadcasting RREQ : ' + _currReq.toRequestString());
      WifiP2p.sendRoutePacket(_currReq.toRequestString(), 10);
      add(BroadcastAsPasser(message : _currReq.toRequestString()));
    }
  }

  void rebroadcastReply(RouteReply rep) async {
    RoutingTable _rt = OfflineServices.routingTable;

    if (rep.srcAddress == OfflineServices.routingTable.deviceAddress) {
      // Source receives RREP
      print("Connecting to : " + rep.senderAddress);
      logs.add("Connecting to : " + rep.senderAddress);
      logger.d('Establishing Wi-Fi Direct Connection with ' + rep.senderAddress);
      await WifiP2p.connect(rep.senderAddress);
      add(SystemEvent(message : "Reached destination"));
    } else {
      // Rebroadcast as intermediate node
      RoutingTableEntry _entry = new RoutingTableEntry(
          rep.destAddress, rep.senderAddress,
          rep.destSequence, rep.hopCount, true);

      List<String> addressList = _rt.routeTable.map((e) => e.destAddress).toList();

      if (addressList.contains(rep.destAddress)) {
        // If route is already registered
        int entryIndex = addressList.indexOf(rep.destAddress);
        print('Index : ' + entryIndex.toString());
        RoutingTableEntry _tableEntry = _rt.routeTable[entryIndex];

        if (_tableEntry.destSequence < _entry.destSequence) {
          _rt.routeTable[entryIndex] = _entry;
          _decideRebroadcastRep(rep, _rt);
        } else if (_tableEntry.destSequence == _entry.destSequence &&
            _tableEntry.hopCount > _entry.hopCount) {
          _rt.routeTable[entryIndex] = _entry;
          _decideRebroadcastRep(rep, _rt);
        } else {
          print("Duplicate packet");
        }
      } else {
        // If route is new
        logger.d('Add to route table : ' + _entry.toString());
        _rt.routeTable.add(_entry);
        _decideRebroadcastRep(rep, _rt);
      }
    }
  }

  void _decideRebroadcastRep(RouteReply rep, RoutingTable rt) {
    RouteReply _currRep = new RouteReply("rrep", rep.destAddress,
        rt.deviceAddress, rep.srcAddress, rep.destSequence, rep.hopCount + 1);

    logs.add("Rebroadcasting : " + _currRep.toReplyString());
    logger.d('Rebroadcasting RREP : ' + _currRep.toReplyString());
    WifiP2p.sendRoutePacket(_currRep.toReplyString(), 10);
    add(BroadcastAsPasser(message : _currRep.toReplyString()));
  }

  // WifiP2p Functions

  Future<void> openPortAndAccept(int port) async {
    socket = await WifiP2p.openServerPort(port);
    socket.inStream.listen((event) async {
      logs.add("Received message: " + event.payload);
      logger.d('Received payload : ' + event.payload);

      await WifiP2p.disconnectFromServer(8888);
      WifiP2p.wifiP2pEvents.unregisterSocket(8888);
      await WifiP2p.disconnect();

      add(ReceivePacket());
    });

    await WifiP2p.acceptClient(port);
  }

  Future<void> connectToPort(int port) async {
    print('Address: ' + serverAddress);
    print('Port: ' + port.toString());
    socket = await WifiP2p.connectToServer(serverAddress, port);
    socket.inStream.listen((event) async {
      logs.add("Sent message: " + event.payload);
      logger.d('Sent payload : ' + event.payload);
      add(ReceivePacket());
    });

    if (socket == null) {
      print('hey');
      //connectToPort(port);
    }
    //await new Future.delayed(new Duration(milliseconds: 500));
    socket.write("Hello World");
  }

  @override
  Future<void> close() {
    peerStream.cancel();
    connStream.cancel();
    packetStream.cancel();
    super.close();
  }
}
