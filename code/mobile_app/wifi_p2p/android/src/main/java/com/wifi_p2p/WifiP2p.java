package com.wifi_p2p;

import androidx.core.content.ContextCompat;
import androidx.core.app.ActivityCompat;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.provider.Settings;
import android.util.Log;

import android.net.wifi.p2p.WifiP2pManager;
import android.net.wifi.p2p.WifiP2pConfig;

import java.net.NetworkInterface;
import java.util.Collections;
import java.util.List;

import static android.content.Context.WIFI_SERVICE;

/** Reports wifi information. */
class WifiP2p extends Activity {
  private WifiP2pManager manager;
  private WifiP2pManager.Channel channel;
  private Activity activity;

  private Context context;
  private boolean _isSettings = false;

  public static final String TAG = "WifiP2p";

  WifiP2p(WifiP2pManager manager, Context context, WifiP2pManager.Channel channel, Activity activity) {
    this.manager = manager;
    this.context = context;
    this.channel = channel;
    this.activity = activity;
  }

  String getLocalMacAddress() {
    try {
      List<NetworkInterface> all = Collections.list(NetworkInterface.getNetworkInterfaces());
      for (NetworkInterface nif : all) {
        if (!nif.getName().equalsIgnoreCase("p2p0")) continue;

        byte[] macBytes = nif.getHardwareAddress();
        if (macBytes == null) {
          return "";
        }

        StringBuilder res1 = new StringBuilder();
        for (byte b : macBytes) {
          //res1.append(Integer.toHexString(b & 0xFF) + ":");
          res1.append(String.format("%02X:",b));
        }

        if (res1.length() > 0) {
          res1.deleteCharAt(res1.length() - 1);
        }
        return res1.toString().toLowerCase();
      }
    } catch (Exception ex) {
    }
    return "02:00:00:00:00:00";
  }

  boolean createGroup() {
    final boolean[] _discovered = new boolean[1];

    manager.createGroup(channel, new WifiP2pManager.ActionListener() {
      @Override
      public void onSuccess() {
        Log.d(TAG, "Create group is success");
        _discovered[0] = true;
      }

      @Override
      public void onFailure(int reason) {
        Log.d(TAG, "Create group is failure");
        _discovered[0] = false;
      }
    });

    return _discovered[0];
  }

  boolean removeGroup() {
    final boolean[] _discovered = new boolean[1];

    manager.removeGroup(channel, new WifiP2pManager.ActionListener() {
      @Override
      public void onSuccess() {
        Log.d(TAG, "Remove group is success");
        _discovered[0] = true;
      }

      @Override
      public void onFailure(int reason) {
        Log.d(TAG, "Remove group is failure");
        _discovered[0] = false;
      }
    });

    return _discovered[0];
  }

  // WiFi Direct Functions
  
  boolean connectDevice(String deviceAddress) {
    final boolean[] _discovered = new boolean[1];

    WifiP2pConfig config = new WifiP2pConfig();
    config.deviceAddress = deviceAddress;
    config.groupOwnerIntent = 15;
    manager.connect(channel, config, new WifiP2pManager.ActionListener() {
      @Override
      public void onSuccess() {
        Log.d(TAG, "Connect to device is success");
        _discovered[0] = true;
      }

      @Override
      public void onFailure(int reason) {
        Log.d(TAG, "Connect to device is failure " + reason);
        _discovered[0] = false;
      }
    });

    return _discovered[0];
  }

  boolean disconnectDevice() {
    final boolean[] _discovered = new boolean[1];

    manager.requestGroupInfo(channel, info -> {
      if(info != null) manager.removeGroup(channel, new WifiP2pManager.ActionListener() {
        @Override
        public void onSuccess() {
          Log.d(TAG, "Disconnect to device is success");
          _discovered[0] = true;
        }

        @Override
        public void onFailure(int reason) {
          Log.d(TAG, "Disconnect to device is failure");
          _discovered[0] = false;
        }
      });
      else _discovered[0] = true;
    });

    return _discovered[0];
  }

  boolean discoverPeers() {
    if (!checkPermissions()) return false;
    final boolean[] _discovered = new boolean[1];

    manager.discoverPeers(channel, new WifiP2pManager.ActionListener() {

      @Override
      public void onSuccess() {
        Log.d(TAG, "Discover peers is success");
        _discovered[0] = true;
      }

      @Override
      public void onFailure(int reason) {
        Log.d(TAG, "Discover peers is failure");
        _discovered[0] = false;
      }
    });

    return _discovered[0];
  }

  boolean cancelDiscover() {
    final boolean[] _discovered = new boolean[1];

    manager.stopPeerDiscovery(channel, new WifiP2pManager.ActionListener() {

      @Override
      public void onSuccess() {
        Log.d(TAG, "Stop discover peers is success");
        _discovered[0] = true;
      }

      @Override
      public void onFailure(int reason) {
        Log.d(TAG, "Stop discover peers is failure");
        _discovered[0] = false;
      }
    });

    return _discovered[0];
  }

//  @Override
//  protected void onActivityResult(int requestCode, int resultCode, Intent data) {
//    if(requestCode == 100) {
//      _isSettings = false;
//    }
//  }

  boolean restartWifi() {
    Log.d("WifiP2p", "Android - restarting wifi...");

    if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      _isSettings = true;
      Intent panelIntent = new Intent(Settings.Panel.ACTION_INTERNET_CONNECTIVITY);
      activity.startActivityForResult(panelIntent, 100);
      Log.d("WifiP2p", "Android - exited from settings");
      return true;
    } else {
      WifiManager wifiManager = (WifiManager) context.getApplicationContext().getSystemService(WIFI_SERVICE);
      assert wifiManager != null;

      if (wifiManager.isWifiEnabled()) {
        wifiManager.setWifiEnabled(false);
        while (wifiManager.isWifiEnabled()) {}
      }
      wifiManager.setWifiEnabled(true);
      while(!wifiManager.isWifiEnabled()) {}
      return wifiManager.isWifiEnabled();
    }
  }

  boolean verifyPermissions() {
    return requestPermissions();
  }

  private boolean requestPermissions() {
    String[] permissions = {Manifest.permission.ACCESS_FINE_LOCATION};

    ActivityCompat.requestPermissions(this.activity, permissions, 420);

    while(ActivityCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION)
      != PackageManager.PERMISSION_GRANTED) {
//      try {
////        Thread.sleep(1000);
////        Log.d("WifiP2p", "Delaying...");
//      } catch (InterruptedException e) {
//        e.printStackTrace();
//      }
    }

    if(!checkPermissions()) {
      Log.w(TAG, "Request permissions is failure");
      return false;
    } else {
      Log.d(TAG, "Request permissions is success");
      return true;
    }
  }

  private Boolean checkPermissions() {
//    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
//      return true;
//    }

//    boolean grantedChangeWifiState =
//      ContextCompat.checkSelfPermission(context, Manifest.permission.CHANGE_WIFI_STATE)
//        == PackageManager.PERMISSION_GRANTED;

    boolean grantedAccessFine =
      ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION)
        == PackageManager.PERMISSION_GRANTED;

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
      && (!grantedAccessFine)) {
      Log.w(
        TAG,
        "Attempted to get Wi-Fi data that requires additional permission(s).\n"
          + "To successfully get WiFi Name or Wi-Fi BSSID starting with Android Q, please ensure your app has the CHANGE_WIFI_STATE and ACCESS_FINE_LOCATION permission.\n"
          + "For more information about Wi-Fi Restrictions in Android 10.0 and above, please consult the following link:\n"
          + "https://developer.android.com/guide/topics/connectivity/wifi-scan");
      return false;
      //ActivityCompat.requestPermissions(activity, new String[] {Manifest.permission.ACCESS_FINE_LOCATION}, 100);
    }

//    boolean grantedAccessCoarse =
//      ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION)
//        == PackageManager.PERMISSION_GRANTED;

//    Log.d("WifiP2p", "Change wifi : " + grantedChangeWifiState);
//    Log.d("WifiP2p", "Access fine : " + grantedAccessFine);
//    Log.d("WifiP2p", "Access coarse : " + grantedAccessCoarse);
//
//    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P
//      && !grantedChangeWifiState
//      && !grantedAccessFine
//      && !grantedAccessCoarse) {
//      Log.w(
//        TAG,
//        "Attempted to get Wi-Fi data that requires additional permission(s).\n"
//          + "To successfully get WiFi Name or Wi-Fi BSSID starting with Android O, please ensure your app has one of the following permissions:\n"
//          + "- CHANGE_WIFI_STATE\n"
//          + "- ACCESS_FINE_LOCATION\n"
//          + "- ACCESS_COARSE_LOCATION\n"
//          + "For more information about Wi-Fi Restrictions in Android 8.0 and above, please consult the following link:\n"
//          + "https://developer.android.com/guide/topics/connectivity/wifi-scan");
//
//      //return false;
//    }
//
//    if (Build.VERSION.SDK_INT == Build.VERSION_CODES.P && !grantedChangeWifiState) {
//      Log.w(
//        TAG,
//        "Attempted to get Wi-Fi data that requires additional permission(s).\n"
//          + "To successfully get WiFi Name or Wi-Fi BSSID starting with Android P, please ensure your app has the CHANGE_WIFI_STATE permission.\n"
//          + "For more information about Wi-Fi Restrictions in Android 9.0 and above, please consult the following link:\n"
//          + "https://developer.android.com/guide/topics/connectivity/wifi-scan");
//      return false;
//    }
//
//    if (Build.VERSION.SDK_INT == Build.VERSION_CODES.P
//      && !grantedAccessFine
//      && !grantedAccessCoarse) {
//      Log.w(
//        TAG,
//        "Attempted to get Wi-Fi data that requires additional permission(s).\n"
//          + "To successfully get WiFi Name or Wi-Fi BSSID starting with Android P, additional to CHANGE_WIFI_STATE please ensure your app has one of the following permissions too:\n"
//          + "- ACCESS_FINE_LOCATION\n"
//          + "- ACCESS_COARSE_LOCATION\n"
//          + "For more information about Wi-Fi Restrictions in Android 9.0 and above, please consult the following link:\n"
//          + "https://developer.android.com/guide/topics/connectivity/wifi-scan");
//      return false;
//    }
//
//    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
//      && (!grantedAccessFine || !grantedChangeWifiState)) {
//      Log.w(
//        TAG,
//        "Attempted to get Wi-Fi data that requires additional permission(s).\n"
//          + "To successfully get WiFi Name or Wi-Fi BSSID starting with Android Q, please ensure your app has the CHANGE_WIFI_STATE and ACCESS_FINE_LOCATION permission.\n"
//          + "For more information about Wi-Fi Restrictions in Android 10.0 and above, please consult the following link:\n"
//          + "https://developer.android.com/guide/topics/connectivity/wifi-scan");
//      return false;
//      //ActivityCompat.requestPermissions(activity, new String[] {Manifest.permission.ACCESS_FINE_LOCATION}, 100);
//    }

    // Trap app here until permission given, will remove later
//    while(!grantedAccessFine) {
//      try {
//        Thread.sleep(1000);
//      } catch (InterruptedException e) {
//        e.printStackTrace();
//      }
//    }
//    Log.d("WifiP2p", "Access fine : " + grantedAccessFine);
//    while(ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION)
//      != PackageManager.PERMISSION_GRANTED) {
////      try {
//////        Thread.sleep(1000);
//////        Log.d("WifiP2p", "Delaying...");
////      } catch (InterruptedException e) {
////        e.printStackTrace();
////      }
//    }

    LocationManager locationManager =
      (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);

    boolean gpsEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !gpsEnabled) {
      Log.w(
        TAG,
        "Attempted to get Wi-Fi data that requires additional permission(s).\n"
          + "To successfully get WiFi Name or Wi-Fi BSSID starting with Android P, please ensure Location services are enabled on the device (under Settings > Location).\n"
          + "For more information about Wi-Fi Restrictions in Android 9.0 and above, please consult the following link:\n"
          + "https://developer.android.com/guide/topics/connectivity/wifi-scan");
      return false;
    }

    //Log.d("WifiP2p", "Android - Verified permissions");
    return true;
  }
}
