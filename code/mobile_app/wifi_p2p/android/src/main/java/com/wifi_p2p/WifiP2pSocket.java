package com.wifi_p2p;

import android.util.Log;

import com.wifi_p2p.file_transfer.SocketManager;

import io.flutter.plugin.common.MethodCall;

import java.nio.charset.StandardCharsets;

public class WifiP2pSocket {
  SocketManager socketManager;

  WifiP2pSocket(SocketManager socketManager) {
    this.socketManager = socketManager;
  }

  // Server Method Calls

  boolean openServerPort(MethodCall call) {
    Integer port = (Integer) call.argument("port");
    if(port == null) return false;
    socketManager.openSocket(port);
    return true;
  }

  boolean closeServerPort(MethodCall call) {
    Integer port = (Integer) call.argument("port");
    if(port == null) return false;
    socketManager.closeSocket(port);
    return true;
  }

  boolean acceptClient(MethodCall call) {
    Integer port = (Integer) call.argument("port");
    if(port == null) return false;
    socketManager.acceptClientConnection(port);
    return true;
  }

  boolean sendDataToClient(MethodCall call) {
    String payload = (String) call.argument("payload");
    Integer port = (Integer) call.argument("port");

    socketManager.sendDataToClient(port, payload.getBytes());
    return true;
  }

  // Client Method Calls

  boolean connectToServer(MethodCall call) {
    String serverAddress = (String) call.argument("serverAddress");
    Integer port = (Integer) call.argument("port");

    if(serverAddress == null || port == null) return false;
    Log.d("WifiP2p", "No missing parameters");
    socketManager.connectToServer(serverAddress, port, 100000);
    return true;
  }

  boolean disconnectFromServer(MethodCall call) {
    Integer port = (Integer) call.argument("port");

    if(port == null) return false;
    socketManager.disconnectFromServer(port);
    return true;
  }

  boolean sendDataToServer(MethodCall call) {
    String payload = (String) call.argument("payload");
    Log.d("WifiP2p", "WifiP2pSocket - Client: " + payload);
    Integer port = (Integer) call.argument("port");

    socketManager.sendDataToServer(port, payload.getBytes());
    return true;
  }
}
