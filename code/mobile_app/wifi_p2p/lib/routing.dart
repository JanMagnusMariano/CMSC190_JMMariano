
import 'package:equatable/equatable.dart';

class RoutingTable {
  String deviceAddress;
  int seqNumber, broadcastId;
  bool hasInternet;
  List<RoutingTableEntry> routeTable;

  RoutingTable(String device, bool hasNet) {
    this.deviceAddress = device;
    this.hasInternet = hasNet;
    this.seqNumber = 0;
    this.broadcastId = 0;
    this.routeTable = new List<RoutingTableEntry>();
  }
}

// ignore: must_be_immutable
class RoutingTableEntry extends Equatable {
  String destAddress, nextHop;
  List<String> prevNodes;
  int destSequence, hopCount;
  bool hasConn;

  RoutingTableEntry(String dest, next, int destSeq, hop, bool hasConn) {
    this.destAddress = dest;
    this.nextHop = next;
    this.destSequence = destSeq;
    this.hopCount = hop;
    this.hasConn = hasConn;
  }

  @override
  // TODO: implement props
  List<Object> get props => [destAddress, nextHop, destSequence, hopCount];
}

// ignore: must_be_immutable
abstract class RoutePacket extends Equatable {
  String packetType;

  RoutePacket(String type) {
    this.packetType = type;
  }
}

// ignore: must_be_immutable
class RouteRequest extends RoutePacket {
  String srcAddress, senderAddress, destAddress;
  int srcSequence, destSequence, reqId, hopCount;

  RouteRequest(String type, src, sender, dest, int srcNum, destNum, id, hop) : super(type) {
    this.srcAddress = src;
    this.senderAddress = sender;
    this.destAddress = dest;
    this.srcSequence = srcNum;
    this.destSequence = destNum;
    this.reqId = id;
    this.hopCount = hop;
  }

  factory RouteRequest.fromRequestString(String req) {
    RouteRequest _toReturn;
    List<String> _split = req.split(',');

    for(var i = 0; i < _split.length; i++) {
      _split[i] = _split[i].replaceAll(',', '');
      _split[i] = _split[i].replaceAll('}', '');
      _split[i] = _split[i].replaceAll('{pl=', '');
    }

    print(_split.toString());
    int destSeq = (_split[5] == "") ? null : int.parse(_split[5]);

    _toReturn = new RouteRequest(_split[0], _split[1], _split[2],  _split[3],
        int.parse(_split[4]),  destSeq,  int.parse(_split[6]), int.parse(_split[7]));
    // type, srcAdd, senderAdd, destAdd, srcSeq, destSeq, broadcast_id, hopcount
    //rreq,6a:5a:cf:19:02:6a,6a:5a:cf:19:02:6a,6a:5a:cf:19:02:6a,0,0,0,0
    return _toReturn;
  }

  String toRequestString() {
    String _toReturn;
    String _handleNull = (destAddress == null) ? "" : destAddress;
    String _handleNullNum = (destSequence == null) ? "" : destSequence.toString();

    _toReturn = '$packetType,$srcAddress,$senderAddress,$_handleNull,$srcSequence,$_handleNullNum,$reqId,$hopCount';
    return _toReturn;
  }

  @override
  // TODO: implement props
  List<Object> get props => [packetType, srcAddress, senderAddress, destAddress, destSequence, reqId, hopCount];
}

// ignore: must_be_immutable
class RouteReply extends RoutePacket {
  String destAddress, senderAddress, srcAddress;
  int destSequence, hopCount;

  RouteReply(String type, dest, sender, src, int destNum, hop) : super(type) {
    this.srcAddress = src;
    this.senderAddress = sender;
    this.destAddress = dest;
    this.destSequence = destNum;
    this.hopCount = hop;
  }

  factory RouteReply.fromReplyString(String req) {
    RouteReply _toReturn;
    List<String> _split = req.split(',');

    for(var i = 0; i < _split.length; i++) {
      _split[i] = _split[i].replaceAll(',', '');
      _split[i] = _split[i].replaceAll('}', '');
      _split[i] = _split[i].replaceAll('{pl=', '');
    }

    // print(_split.toString());

    _toReturn = new RouteReply(_split[0], _split[1], _split[2],  _split[3],
        int.parse(_split[4]),  int.parse(_split[5]));
    // type, destAdd, senderAdd, srcAdd, destSeq, hopcount
    //rreq,6a:5a:cf:19:02:6a,6a:5a:cf:19:02:6a,6a:5a:cf:19:02:6a,0,0
    return _toReturn;
  }

  String toReplyString() {
    String _toReturn;

    _toReturn = packetType + ',' + destAddress + ','  + senderAddress + ',' + srcAddress + ',' +
        destSequence.toString() + ','  + hopCount.toString();
    return _toReturn;
  }

  @override
  // TODO: implement props
  List<Object> get props => [packetType, destAddress, senderAddress, srcAddress, hopCount];
}