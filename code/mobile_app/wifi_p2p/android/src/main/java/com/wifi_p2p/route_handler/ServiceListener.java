package com.wifi_p2p.route_handler;

import android.net.wifi.p2p.WifiP2pDevice;
import android.net.wifi.p2p.WifiP2pManager;
import android.util.Log;

public class ServiceListener implements WifiP2pManager.DnsSdServiceResponseListener {
  @Override
  public void onDnsSdServiceAvailable(String instanceName, String registrationType, WifiP2pDevice srcDevice) {
//    Log.d("WifiP2p", "Service Listener : " + instanceName);
//    Log.d("WifiP2p", "Device Address : " + srcDevice.deviceAddress);
  }
}


