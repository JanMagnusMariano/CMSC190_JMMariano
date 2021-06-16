package com.wifi_p2p.file_transfer;

import android.util.Log;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class SocketHandler {
  Socket socket;
  Boolean isHost;
  //InputStream inStream;

  SocketHandler(Socket socket, Boolean isHost) {
    this.socket = socket;
    this.isHost = isHost;
  }

  // Might have to change design to send data over slowly vs. sending in one big chunk?
  // But does it matter when both won't work because we need the data whole?

  // Counter argument for sending data by chunk is that we can pick up where we left off incase of disconnection

  void handleInput(PublishEventHandler callback) throws IOException {
    char[] buffer = new char[1024];
    int charsRead = 0;
    InputStream inStream = socket.getInputStream();
    BufferedReader in = new BufferedReader(new InputStreamReader(inStream));

    Integer port = (isHost) ? socket.getLocalPort() : socket.getPort();
    Map<String, Object> map = new HashMap<>();

    while((charsRead = in.read(buffer)) != -1) {
      String message = new String(buffer).substring(0, charsRead);
      Log.d("WifiP2p", "Handle Input - Message " + message);

      map.put("port", port);
      map.put("available", inStream.available());
      map.put("payload", message);
      callback.handleCallback(map);
    }

    inStream.close();
    in.close();
    Log.d("WifiP2p", "Got out of handle input loop");
  }
}
