package com.wifi_p2p;

import android.provider.Settings;
import android.util.Log;

import com.wifi_p2p.route_handler.RouteBroadcaster;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * The handler receives {@link MethodCall}s from the UIThread, gets the related information from
 * a @{@link WifiInfoFlutter}, and then send the result back to the UIThread through the {@link
 * MethodChannel.Result}.
 */
class WifiP2pMethodChannelHandler implements MethodChannel.MethodCallHandler {
  private WifiP2pPlugin plugin;
  private WifiP2pSocket socket;
  private RouteBroadcaster bcaster;
  /**
   * Construct the WifiInfoFlutterMethodChannelHandler with a {@code wifiInfoFlutter}. The {@code
   * wifiInfoFlutter} must not be null.
   */
  WifiP2pMethodChannelHandler(WifiP2pPlugin plugin, WifiP2pSocket socket, RouteBroadcaster bcaster) {
    this.plugin = plugin;
    this.socket = socket;
    this.bcaster = bcaster;
  }

  @Override
  public void onMethodCall(MethodCall call, MethodChannel.Result result) {
    switch (call.method) {
      case "discoverPeers":
        Log.d(WifiP2p.TAG, "Started discovering peers...");
        result.success(plugin.wifiP2p.discoverPeers());
        break;
      case "cancelDiscover":
        Log.d(WifiP2p.TAG, "Started cancelling discover...");
        result.success(plugin.wifiP2p.cancelDiscover());
        break;
      case "verifyPermissions":
        Log.d(WifiP2p.TAG, "Started requesting permissions...");
        result.success(plugin.wifiP2p.verifyPermissions());
        break;
      case "connect":
        boolean connectRes =  plugin.wifiP2p.connectDevice(call.argument("payload"));
        result.success(connectRes);
        break;
      case "disconnect":
        boolean disconnectRes =  plugin.wifiP2p.disconnectDevice();
        result.success(disconnectRes);
        break;
      case "register":
        String regRes =  plugin.register();
        //String devName = Settings.System.getString()
        result.success(regRes);
        break;
      case "unregister":
        boolean unregRes =  plugin.unregister();
        result.success(unregRes);
        break;
      case "restartWifi":
        result.success(plugin.wifiP2p.restartWifi());
        break;
      case "getLocalMacAddress":
        result.success(plugin.wifiP2p.getLocalMacAddress());
        break;

      // Broadcasting
//      case "startAndDiscoverServices":
//        plugin.wifiP2p.startAndDiscoverServices(call.argument("instanceName"), call.argument("count"));
//        result.success(true);
//        break;
//
//      // For testing only
//      case "modifyPayload":
//        plugin.wifiP2p.modifyPayload(call.argument("instanceName"), call.argument("count"));
//        result.success(true);
//        break;
//      case "stopBroadcasting":
//        plugin.wifiP2p.stopBroadcasting();
//        result.success(true);
//        break;

      // AODV
      case "listenToBroadcasts":
        bcaster.listenTest();
        //bcaster.listenToBroadcasts();
        result.success(true);
        break;
      case "sendRoutePacket":
        bcaster.sendRoutePacket(call.argument("payload"), call.argument("limit"));
        result.success(true);
        break;
      case "checkBroadcastState":
        result.success(bcaster.checkBroadcastState());
        break;
      case "stopBroadcasting":
        bcaster.stopBroadcasting();
        result.success(true);
        break;
      case "stopService":
        bcaster.stopService();
        result.success(true);
        break;

        // Legacy WiFi
      case "createGroup":
        result.success(plugin.wifiP2p.createGroup());
        break;
      case "removeGroup":
        result.success(plugin.wifiP2p.removeGroup());
        break;

        // Server
      case "openServerPort":
        result.success(socket.openServerPort(call));
        break;
      case "closeServerPort":
        result.success(socket.closeServerPort(call));
        break;
      case "acceptClient":
        result.success(socket.acceptClient(call));
        break;
      case "sendDataToClient":
        result.success(socket.sendDataToClient(call));
        break;

        // Client
      case "connectToServer":
        result.success(socket.connectToServer(call));
        break;
      case "disconnectFromServer":
        result.success(socket.disconnectFromServer(call));
        break;
      case "sendDataToServer":
        result.success(socket.sendDataToServer(call));
        break;
    }
  }
}