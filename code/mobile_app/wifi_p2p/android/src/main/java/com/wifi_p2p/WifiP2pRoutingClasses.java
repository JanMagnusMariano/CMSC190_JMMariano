package com.wifi_p2p;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

abstract class WifiP2pRoutingClasses {}

class WifiP2pRouteInformation {
  String deviceAddress;
  Integer seqNumber, reqId;
  boolean hasInternet;
  List<WifiP2pRouteEntry> routeTable;

  WifiP2pRouteInformation(String dev, Integer seq, Integer id, boolean hasNet, List<WifiP2pRouteEntry> table) {
    this.deviceAddress = dev;
    this.seqNumber = seq;
    this.reqId = id;
    this.hasInternet = hasNet;
    this.routeTable = table;
  }
}

class WifiP2pRouteEntry {
  String destAddress, nextHop;
  List<String> preNodes;
  Integer destSequence, hopCount;
  // Implement expiration
}

abstract class WifiP2pRoutePacket {
  String packetType;

  WifiP2pRoutePacket(String type) {
    this.packetType = type;
  }
}

class WifiP2pRouteRequest extends WifiP2pRoutePacket {
  String srcAddress, destAddress;
  Integer srcSequence, destSequence, reqId, hopCount;

  WifiP2pRouteRequest(String src, String dest, Integer srcNum, Integer destNum, Integer id, Integer hop) {
    super("RequestPacket");
    this.srcAddress = src;
    this.destAddress = dest;
    this.srcSequence = srcNum;
    this.destSequence = destNum;
    this.reqId = id;
    this.hopCount = hop;
  }

  Map<String, String> toStringMap() {
    Map<String, String> toReturn = new HashMap<>();
    String _destAddr = (destAddress == null) ? "" : destAddress;
    String _destSeq = (destSequence == null) ? "" : destSequence.toString();

    toReturn.put("packetType", packetType);
    toReturn.put("srcAddress", srcAddress);
    toReturn.put("destAddress", _destAddr);
    toReturn.put("srcSequence", srcSequence.toString());
    toReturn.put("destSequence", _destSeq);
    toReturn.put("reqId", reqId.toString());
    toReturn.put("hopCount", hopCount.toString());

    return toReturn;
  }
}

class WifiP2pRouteReply {
  String srcAddress, destAddress;
  Integer destSequence;
}
