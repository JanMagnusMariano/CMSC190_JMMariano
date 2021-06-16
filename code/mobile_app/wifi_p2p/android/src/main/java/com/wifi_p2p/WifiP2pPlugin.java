package com.wifi_p2p;

import com.wifi_p2p.file_transfer.SocketManager;
import com.wifi_p2p.route_handler.RecordListener;
import com.wifi_p2p.route_handler.RouteBroadcaster;
import com.wifi_p2p.route_handler.ServiceListener;
import com.wifi_p2p.utils.EventChannelListener;
import androidx.annotation.NonNull;

// Android imports

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import android.net.wifi.p2p.WifiP2pManager;
import android.os.Looper;
import android.app.Activity;
import android.provider.Settings;
import android.util.Log;

// Flutter imports

import java.net.Socket;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;

/** WifiP2pPlugin */
public class WifiP2pPlugin implements FlutterPlugin, ActivityAware {
  private MethodChannel methodChannel;
  private Activity mActivity;
  private Context mContext;
  private BinaryMessenger mMessenger;

  WifiP2pManager wifiP2pManager;
  WifiP2pManager.Channel wifiP2pChannel;
  WifiP2p wifiP2p;
  WifiP2pReceiver wifiP2pReceiver;
  WifiP2pSocket wifiP2pSocket;

  SocketManager socketManager;
  RouteBroadcaster routeBroadcaster;
  RecordListener recListener;
  ServiceListener servListener;
  String deviceName;

  private final IntentFilter intentFilter = new IntentFilter();
  private EventChannelListener eventListener;

  @SuppressWarnings("deprecation")
  public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {

    WifiP2pPlugin plugin = new WifiP2pPlugin();
    plugin.setupChannels(registrar.messenger(), registrar.context(), registrar.activity());
  }

  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {
    intentFilter.addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION);
    intentFilter.addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION);
    intentFilter.addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION);
    intentFilter.addAction(WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION);

    this.mContext = binding.getApplicationContext();
    this.mMessenger = binding.getBinaryMessenger();
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    unregister();
    teardownChannels();
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    Log.d(WifiP2p.TAG, "Attached to Activity");
    this.mActivity = binding.getActivity();
    setupChannels(mMessenger, mContext, mActivity);
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    Log.d(WifiP2p.TAG, "Detached from Activity for Config");
    this.mActivity = binding.getActivity();
    setupChannels(mMessenger, mContext, mActivity);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    Log.d(WifiP2p.TAG, "Detached from Activity for Config");
    unregister();
    teardownChannels();
  }

  @Override
  public void onDetachedFromActivity() {
    Log.d(WifiP2p.TAG, "Detached from Activity");
    unregister();
    teardownChannels();
  }

  // Channel Functions

  private void setupChannels(BinaryMessenger messenger, Context context, Activity activity) {
    methodChannel = new MethodChannel(messenger, "wifi_p2p");
    eventListener = new EventChannelListener(messenger);
    eventListener.registerStream("peers-change");
    eventListener.registerStream("conn-change");
    eventListener.registerStream("socket");
    eventListener.registerStream("route-packet");
    mContext = context;

    wifiP2pManager = (WifiP2pManager) context.getApplicationContext().getSystemService(Context.WIFI_P2P_SERVICE);
    wifiP2pChannel = wifiP2pManager.initialize(context, Looper.getMainLooper(), null);
    wifiP2p = new WifiP2p(wifiP2pManager, mContext, wifiP2pChannel, mActivity);

    socketManager = new SocketManager(eventListener.getStream("socket"));
    wifiP2pSocket = new WifiP2pSocket(socketManager);

    servListener = new ServiceListener();
    recListener = new RecordListener(eventListener.getStream("route-packet"));
    routeBroadcaster = new RouteBroadcaster(wifiP2pManager, mContext, wifiP2pChannel, recListener, servListener);

    final WifiP2pMethodChannelHandler methodChannelHandler = new WifiP2pMethodChannelHandler(this, wifiP2pSocket, routeBroadcaster);
    methodChannel.setMethodCallHandler(methodChannelHandler);
  }

  private void teardownChannels() {
    methodChannel.setMethodCallHandler(null);
    methodChannel = null;
  }

  // Receiver Functions

  public String register() {
    if(wifiP2pReceiver != null) { return null; }

    EventChannel.EventSink conn = eventListener.getStream("conn-change").sink;
    final WifiP2pPeerListener peerListener = new WifiP2pPeerListener(eventListener.getStream("peers-change").sink);
    wifiP2pReceiver = new WifiP2pReceiver(wifiP2pManager, wifiP2pChannel, wifiP2p,
      peerListener, conn, this);
    mContext.registerReceiver(wifiP2pReceiver, intentFilter);

    return Settings.System.getString(mContext.getContentResolver(), "device_name");
  }

  public boolean unregister() {
    if(wifiP2pReceiver == null) { return false; }
    mContext.unregisterReceiver(wifiP2pReceiver);
    return true;
  }
}
