package com.wifi_p2p;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.NetworkInfo;
import android.net.wifi.p2p.WifiP2pDevice;
import android.net.wifi.p2p.WifiP2pGroup;
import android.net.wifi.p2p.WifiP2pInfo;
import android.net.wifi.p2p.WifiP2pManager;
import android.net.wifi.p2p.WifiP2pManager.Channel;
import android.net.wifi.p2p.WifiP2pManager.PeerListListener;
import android.util.Log;

//import com.wifi_p2p.file_transfer.Client;
//import com.wifi_p2p.file_transfer.Server;

import io.flutter.plugin.common.EventChannel;

import java.net.InetAddress;
import java.util.HashMap;
import java.util.Map;

import static com.wifi_p2p.WifiP2p.TAG;

/**
 * A BroadcastReceiver that notifies of important wifi p2p events.
 */
public class WifiP2pReceiver extends BroadcastReceiver {
  private WifiP2pManager manager;
  private Channel channel;
  private WifiP2p activity;
  private WifiP2pPeerListener listener;

  EventChannel.EventSink conn;
  WifiP2pPlugin plugin;
  /**
   * @param manager WifiP2pManager system service
   * @param channel Wifi p2p channel
   * @param activity activity associated with the receiver
   */
  public WifiP2pReceiver(WifiP2pManager manager, Channel channel,
                         WifiP2p activity, WifiP2pPeerListener listener,
                         EventChannel.EventSink conn, WifiP2pPlugin plugin) {
    super();
    this.manager = manager;
    this.channel = channel;
    this.activity = activity;
    this.listener = listener;

    this.conn = conn;
    this.plugin = plugin;
  }
  /*
   * (non-Javadoc)
   * @see android.content.BroadcastReceiver#onReceive(android.content.Context,
   * android.content.Intent)
   */

  @Override
  public void onReceive(Context context, Intent intent) {
    String action = intent.getAction();
    //Log.d("WifiP2p", action);
    if (WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION.equals(action)) {

    }
    else if (WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION.equals(action)) {
      //Log.d("WifiP2p", "Entered in Wifi Peers changed action");
      if(manager != null) {
        manager.requestPeers(channel, listener);
      }
    }
    else if (WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION.equals(action)) {
      if(manager == null) {
        Log.d("WifiP2p", "Manager is null?");
        return;
      }

      Log.d("WifiP2p", "Connection changed on Java");
      //WifiP2pDevice deviceInfo = intent.getParcelableExtra(WifiP2pManager.EXTRA_WIFI_P2P_DEVICE);
      WifiP2pInfo wifiP2pInfo = intent.getParcelableExtra(WifiP2pManager.EXTRA_WIFI_P2P_INFO);
      NetworkInfo networkInfo = intent.getParcelableExtra(WifiP2pManager.EXTRA_NETWORK_INFO);
      Map<String, Object> payload = new HashMap<>();

      Log.d("WifiP2p", "Is Conn");

      if(networkInfo.isConnected()) {
        payload.put("isHost", wifiP2pInfo.isGroupOwner);
        payload.put("serverAddress", wifiP2pInfo.groupOwnerAddress.getHostAddress());

//        if(wifiP2pInfo.isGroupOwner) {
//          manager.requestGroupInfo(channel, group -> {
//            if(group != null) {
//              //Log.d("WifiP2p", "Host Address1 : " + deviceInfo.deviceAddress);
//              payload.put("deviceAddress", group.getOwner().deviceAddress);
//              Log.d("WifiP2p", "Host SSID : " + group.getNetworkName());
//              Log.d("WifiP2p", "Host Password : " + group.getPassphrase());
//              Log.d("WifiP2p", "Host Address : " + group.getOwner().deviceAddress);
//            }
//          });
//        }
      } else {
        // Change code to just ignore when device is not yet connected

        Log.d("WifiP2p", "This device is not connected");
        payload.put("isHost", false);
        payload.put("serverAddress", "");
      }

      payload.put("isConnected", networkInfo.isConnected());
      conn.success(payload);
    } else if (WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION.equals(action)) {
//      WifiP2pDevice device = intent.getParcelableExtra(WifiP2pManager.EXTRA_WIFI_P2P_DEVICE);
//      assert device != null;
//      String myMac = device.deviceAddress;
//      Log.d("WifiP2p", "Device WiFi P2p MAC Address: " + myMac);

    }
  }
}
