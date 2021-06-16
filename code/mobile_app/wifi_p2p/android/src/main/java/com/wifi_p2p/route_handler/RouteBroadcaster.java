package com.wifi_p2p.route_handler;

import android.content.Context;
import android.net.wifi.p2p.WifiP2pDevice;
import android.net.wifi.p2p.WifiP2pDeviceList;
import android.net.wifi.p2p.WifiP2pManager;
import android.net.wifi.p2p.nsd.WifiP2pDnsSdServiceInfo;
import android.net.wifi.p2p.nsd.WifiP2pDnsSdServiceRequest;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class RouteBroadcaster {
  private final Handler discoverHandler = new Handler(Looper.getMainLooper());
  private WifiP2pManager manager;
  private WifiP2pManager.Channel channel;
  private Context context;

  static final String TAG = "WifiP2p";
  static String SERVICE_TYPE = "_presence._tcp";
  static String instanceString = "_" + Build.MODEL;

  private boolean broadcastFlag = true;
  private final RecordListener recListener;
  private final ServiceListener servListener;

  private String currPayload;
  private Integer currLimit;
  private Integer currCount;

  public RouteBroadcaster(WifiP2pManager manager, Context context, WifiP2pManager.Channel channel,
                          RecordListener rListener, ServiceListener sListener) {
    this.manager = manager;
    this.context = context;
    this.channel = channel;
    this.recListener = rListener;
    this.servListener = sListener;
  }

  public void stopService() {
    Log.d("WifiP2p", "Android - stopped service");
    broadcastFlag = false;
//    manager.discoverPeers(channel, new WifiP2pManager.ActionListener() {
//      @Override
//      public void onSuccess() {}
//      @Override
//      public void onFailure(int reason) {}
//    });
  }

  public void stopBroadcasting() {
    recListener.isListener = true;
  }

  public void modifyPayload(String instanceName, Integer count) {
    instanceString = instanceName;
  }

  public boolean checkBroadcastState() {
    return recListener.isListener;
  }
  //
//  void toggleInternet() {
//    Log.d("WifiP2p", "Android - toggled internet");
//    //this.routeInfo.hasInternet = true;
//  }
//
  public void sendRoutePacket(String payload, Integer limit) {
    recListener.isListener = false;
    currPayload = payload;
    currLimit = limit;
    currCount = 0;
    if(!broadcastFlag) {
      broadcastFlag = true;
      startAndDiscoverServices();
    }
  }

  // Service Discovery Methods

  private final Runnable startDiscoverLoop = new Runnable() {
    @Override
    public void run() {
      Log.d("WifiP2p", "Android - Threads : " + Thread.activeCount());

      if(broadcastFlag) {
        if(recListener.isListener) {
          listenToBroadcasts();
        } else {
          //startAndDiscoverServices();
          if(currCount < currLimit) {
            currCount++;
            startAndDiscoverServices();
          } else {
            recListener.isListener = true;
            listenToBroadcasts();
          }
        }
      } else {
        manager.clearLocalServices(channel, new WifiP2pManager.ActionListener() {
          @Override
          public void onSuccess() {
            manager.clearServiceRequests(channel, new WifiP2pManager.ActionListener() {
              @Override
              public void onSuccess() {
                Log.d("WifiP2p", "Broadcast loop exited");
              }
              @Override
              public void onFailure(int reason) {}
            });
          }
          @Override
          public void onFailure(int reason) {}
        });
      }
    }
  };

  public void listenTest() {
    manager.discoverPeers(channel, new WifiP2pManager.ActionListener() {
      @Override
      public void onSuccess() {
        listenToBroadcasts();
      }

      @Override
      public void onFailure(int reason) {

      }
    });
  }

  public void listenToBroadcasts() {
    Log.d("WifiP2p", "Android - started listening...");
    recListener.isListener = true;
    broadcastFlag = true;

    manager.clearLocalServices(channel, new WifiP2pManager.ActionListener() {
      @Override
      public void onSuccess() {
        manager.setDnsSdResponseListeners(channel, servListener, recListener);
        manager.clearServiceRequests(channel, new WifiP2pManager.ActionListener() {
          @Override
          public void onSuccess() {
            manager.addServiceRequest(channel, WifiP2pDnsSdServiceRequest.newInstance(), new WifiP2pManager.ActionListener() {
              @Override
              public void onSuccess() {
                manager.discoverServices(channel, new WifiP2pManager.ActionListener() {
                  @Override
                  public void onSuccess() {
                    discoverHandler.postDelayed(startDiscoverLoop, 10000);
                  }
                  @Override
                  public void onFailure(int reason) {}
                });
              }
              @Override
              public void onFailure(int reason) {}
            });
          }
          @Override
          public void onFailure(int reason) {}
        });
      }
      @Override
      public void onFailure(int reason) {}
    });
  }

  private void startAndDiscoverServices() {
    Log.d("WifiP2p", "Android - started broadcasting : " + currPayload);

    manager.clearLocalServices(channel, new WifiP2pManager.ActionListener() {
      @Override
      public void onSuccess() {
        Map<String, String> record = new HashMap<>();
        // Check first in route table if there is chenes
        record.put("pl", currPayload);

        WifiP2pDnsSdServiceInfo serviceInfo = WifiP2pDnsSdServiceInfo.newInstance(instanceString, SERVICE_TYPE, record);
        manager.addLocalService(channel, serviceInfo, new WifiP2pManager.ActionListener() {
          @Override
          public void onSuccess() {
            manager.setDnsSdResponseListeners(channel, servListener, recListener);
            manager.clearServiceRequests(channel, new WifiP2pManager.ActionListener() {
              @Override
              public void onSuccess() {
                manager.addServiceRequest(channel, WifiP2pDnsSdServiceRequest.newInstance(), new WifiP2pManager.ActionListener() {
                  @Override
                  public void onSuccess() {
                    manager.discoverServices(channel, new WifiP2pManager.ActionListener() {
                      @Override
                      public void onSuccess() {
                        discoverHandler.postDelayed(startDiscoverLoop, 5000);
                      }
                      @Override
                      public void onFailure(int reason) {}
                    });
                  }
                  @Override
                  public void onFailure(int reason) {}
                });
              }
              @Override
              public void onFailure(int reason) {}
            });
          }
          @Override
          public void onFailure(int reason) {}
        });
      }
      @Override
      public void onFailure(int reason) {}
    });
  }
}
