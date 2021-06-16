package com.wifi_p2p.route_handler;

import android.net.wifi.p2p.WifiP2pDevice;
import android.net.wifi.p2p.WifiP2pManager;
import android.util.Log;

import com.wifi_p2p.utils.EventChannelStream;

import java.util.Map;

public class RecordListener implements WifiP2pManager.DnsSdTxtRecordListener {
  static final String TAG = "WifiP2p";

  EventChannelStream packetSink;
  boolean isListener;

  public RecordListener(EventChannelStream sink) {
    this.packetSink = sink;
    this.isListener = true;
  }

  @Override
  public void onDnsSdTxtRecordAvailable(String fullDomainName, Map<String, String> txtRecordMap, WifiP2pDevice srcDevice) {
    Log.d(TAG, "onDnsSd: " + srcDevice.deviceAddress);
    packetSink.sink.success(txtRecordMap.toString());
    //if(isListener) isListener = false;
  }
}
