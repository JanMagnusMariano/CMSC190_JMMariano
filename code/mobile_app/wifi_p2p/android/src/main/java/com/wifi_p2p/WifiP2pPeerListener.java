package com.wifi_p2p;

import android.net.wifi.p2p.WifiP2pManager.PeerListListener;
import android.net.wifi.p2p.WifiP2pDevice;
import android.net.wifi.p2p.WifiP2pDeviceList;

import android.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import io.flutter.plugin.common.EventChannel;

public class WifiP2pPeerListener implements PeerListListener {

  private EventChannel.EventSink peerChangeSink;
  private List<WifiP2pDevice> peers = new ArrayList<WifiP2pDevice>();

  WifiP2pPeerListener(EventChannel.EventSink sink) {
    this.peerChangeSink = sink;
  }

  @Override
  public void onPeersAvailable(WifiP2pDeviceList peerList) {
    if(!peerList.equals(peers)) {
      List<String> devices = new ArrayList<>();

      for(WifiP2pDevice device : peerList.getDeviceList()) {
        devices.add(device.deviceAddress);
      }

      peers.clear();
      peers.addAll(peerList.getDeviceList());

//      if (peers.size() == 0) {
//        Log.d(WifiP2p.TAG, "No devices found");
//        peerChangeSink.success(devices);
//      } else {
//        Log.d(WifiP2p.TAG, "Devices are found!");
//        peerChangeSink.success(devices);
//      }
    }
  }
}
