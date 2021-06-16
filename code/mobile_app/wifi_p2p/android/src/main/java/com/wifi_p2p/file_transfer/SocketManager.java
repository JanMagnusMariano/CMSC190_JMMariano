package com.wifi_p2p.file_transfer;

import android.util.Log;

import com.wifi_p2p.utils.EventChannelStream;

import java.io.IOException;
import java.net.ServerSocket;
import java.util.ArrayList;
import java.util.List;

public class SocketManager {
  EventChannelStream streamHandler;
  List<Client> clientList = new ArrayList<>();
  List<Server> serverList = new ArrayList<>();

  public SocketManager(EventChannelStream streamHandler) {
    this.streamHandler = streamHandler;
  }

  public Server openSocket(Integer port) {
    if(getServerByPort(port) != null) {
      Log.d("WifiP2p", "Server already exists");
      return null;
    }

    try {
      ServerSocket serverSocket = new ServerSocket(port);
      Server server = new Server(streamHandler, serverSocket);
      serverList.add(server);
      Log.d("WifiP2p", "Server socket opened");
      return server;
    } catch (IOException e) {
      e.printStackTrace();
      return null;
    }
  }

  public void acceptClientConnection(Integer port) {
    Server server = getServerByPort(port);
    if(server == null) {
      Log.d("WifiP2p", "A socket with this port does not exist");
      return;
    }

    server.execute();
  }

  public void closeSocket(Integer port) {
    Server server = getServerByPort(port);
    if(server == null) {
      Log.d("WifiP2p", "A socket with this port does not exist");
      return;
    }

    try {
      //server.socketHandler.inStream.close();
      server.serverSocket.close();
      serverList.remove(server);
    } catch (IOException e) {
      e.printStackTrace();
      if(serverList.contains(server)) serverList.remove(server);
    }
  }

  public Client connectToServer(String hostAddress, Integer port, Integer timeout) {
    Client client = new Client(streamHandler, hostAddress, port, timeout);
    clientList.add(client);
    client.execute();
    return client;
  }

  public void sendDataToServer(Integer port, byte[] data) {
    Client client = getClientByPort(port);
    if(client == null) {
      Log.d("WifiP2p", "A socket with this port is not connected");
      return;
    }

    try {
      String sample = String.valueOf(data);
      Log.d("WifiP2p", "Socket Manager - Client : " + sample);
      client.writeToOutput(data);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  public void sendDataToClient(Integer port, byte[] data) {
    Server server = getServerByPort(port);
    if(server == null) {
      Log.d("WifiP2p", "A socket with this port does not exist");
      return;
    }

    try {
      server.writeToOutput(data);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  public void disconnectFromServer(Integer port) {
    Client client = getClientByPort(port);
    if(client == null) {
      Log.d("WifiP2p", "A socket with this port is not connected");
      return;
    }

    try {
      if(client.socket.isConnected()) {
        //client.socketHandler.inStream.close();
        client.socket.close();
        clientList.remove(client);
      }
    } catch (IOException e) {
      e.printStackTrace();
      if(clientList.contains(client)) clientList.remove(client);
    }
  }

  public void disconnectFromClient(Integer port) {
    Server server = getServerByPort(port);
    if(server == null) {
      Log.d("WifiP2p", "A socket with this port is not connected");
      return;
    }

    try {
      if(!server.serverSocket.isClosed()) {
        //server.socketHandler.inStream.close();
        server.serverSocket.close();
        serverList.remove(server);
      }
    } catch (IOException e) {
      e.printStackTrace();
      if(serverList.contains(server)) serverList.remove(server);
    }
  }

  Server getServerByPort(Integer port) {
    for(Server server : serverList) {
      if(server.serverSocket.getLocalPort() == port)
        return server;
    }

    return null;
  }

  Client getClientByPort(Integer port) {
    for(Client client : clientList) {
      if(client.port == port)
        return client;
    }

    return null;
  }
}
