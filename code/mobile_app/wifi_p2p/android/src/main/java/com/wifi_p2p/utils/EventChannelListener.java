package com.wifi_p2p.utils;

import java.util.HashMap;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;

public class EventChannelListener {
  private BinaryMessenger messenger;

  private String basename = "wifi_p2p";
  private HashMap<String, EventChannelStream> eventChannels = new HashMap<String, EventChannelStream>();

  public EventChannelListener(BinaryMessenger messenger) {
    this.messenger = messenger;
  }

  public EventChannelStream registerStream(String name) {
    if(isRegistered(name)) { return null; }
    EventChannel channel = new EventChannel(messenger, "wifi_p2p/" + name);
    eventChannels.put(name, EventChannelStream.createForChannel(channel));
    return eventChannels.get(name);
  }

  public EventChannelStream getStream(String name) {
    return eventChannels.get(name);
  }

  private boolean isRegistered(String name) {
    return eventChannels.containsKey(name);
  }
}
