package com.wifi_p2p.utils;

import io.flutter.plugin.common.EventChannel;

public class EventChannelStream implements EventChannel.StreamHandler {

  EventChannel channel;
  public EventChannel.EventSink sink;

  public static EventChannelStream createForChannel(EventChannel channel) {
    EventChannelStream streamHandler = new EventChannelStream();
    streamHandler.channel = channel;
    channel.setStreamHandler(streamHandler);
    return streamHandler;
  }

  @Override
  public void onListen(Object arg, EventChannel.EventSink eventSink) { this.sink = eventSink; }

  @Override
  public void onCancel(Object arg) {
    this.sink = null;
  }
}
