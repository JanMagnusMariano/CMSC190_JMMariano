package com.wifi_p2p.file_transfer;

import android.os.AsyncTask;
import android.util.Log;

import com.wifi_p2p.utils.EventChannelStream;

import java.io.IOException;
import java.io.OutputStream;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.Map;

abstract class SocketInstances extends AsyncTask<Void, Map<String, Object>, Boolean> {
  EventChannelStream streamHandler;
  Socket socket;

  SocketInstances(EventChannelStream streamHandler) {
    this.streamHandler = streamHandler;
  }

  @SafeVarargs
  @Override
  protected final void onProgressUpdate(Map<String, Object>... jsonObject) {
    streamHandler.sink.success(jsonObject[0]);
  }

  void writeToOutput(byte[] bytes) {
    try {
      StreamWrite writeTask = new StreamWrite(socket.getOutputStream(), bytes);
      writeTask.executeOnExecutor(THREAD_POOL_EXECUTOR);
    } catch(Exception e) {
      e.printStackTrace();
    }
  }
}

class Client extends SocketInstances {
  String hostAddress;
  int port, timeout;
  SocketHandler socketHandler;

  Client(EventChannelStream streamHandler, String hostAddress,
         Integer port, Integer timeout) {
    super(streamHandler);
    this.hostAddress = hostAddress;
    this.port = port;
    this.timeout = timeout;

    try {
      socket = new Socket();
      socket.bind(null);
    } catch (IOException e) {
      e.printStackTrace();
    }
  }

  @Override
  protected Boolean doInBackground(Void... voids) {
    try {
      InetAddress ipAddress = InetAddress.getByName("192.168.49.1");
      InetSocketAddress socketAddress = new InetSocketAddress(ipAddress, port);
      socket.connect(socketAddress, timeout);
      socketHandler = new SocketHandler(socket, false);
      socketHandler.handleInput(bytes -> publishProgress(bytes));
    } catch(Exception e) {
      Log.d("WifiP2p", "Socket Instance - Client: Input stream closed");
      e.printStackTrace();
      return false;
    }

    Log.d("WifiP2p", "Got out of doInBackground");
    return true;
  }
}

class Server extends SocketInstances {
  ServerSocket serverSocket;
  SocketHandler socketHandler;

  Server(EventChannelStream streamHandler, ServerSocket serverSocket) {
    super(streamHandler);
    this.serverSocket = serverSocket;
  }

  @Override
  protected Boolean doInBackground(Void... voids) {
    try {
      socket = serverSocket.accept();
      socketHandler = new SocketHandler(socket, true);
      socketHandler.handleInput(bytes -> publishProgress(bytes));
    } catch(Exception e) {
      Log.d("WifiP2p", "Socket Instance - Server: Input stream closed");
      e.printStackTrace();
      return false;
    }

    return true;
  }
}

// Supporting classes

class StreamWrite extends AsyncTask<Void, Void, Boolean> {
  OutputStream outStream;
  byte[] bytes;

  StreamWrite(OutputStream outStream, byte[] bytes) {
    this.outStream = outStream;
    this.bytes = bytes;
  }

  @Override
  protected Boolean doInBackground(Void... voids) {
    try {
      outStream.write(bytes);
      outStream.flush();
    } catch (IOException e) {
      e.printStackTrace();
    }

    return true;
  }
}

interface PublishEventHandler {
  void handleCallback(Map<String, Object> bytes);
}