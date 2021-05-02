import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  Online,
  Offline,
  Connecting
}

class SocketService with ChangeNotifier {
  
  ServerStatus _serverStatus = ServerStatus.Connecting;

  IO.Socket _socket;


  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;

  Function get emit => this._socket.emit;
  
  /* Constructor */
  SocketService() {
    this._initConfig();
  }

  void _initConfig() {

    // Dart client (tambien puede poner la IP del Pc o 10.0.2.2)
    this._socket = IO.io('http://192.168.1.3:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true
    });

    this._socket.on('connect', (_) {

      print('connect');
      
      this._serverStatus = ServerStatus.Online;
      notifyListeners();

    });

    this._socket.on('disconnect', (_) {

      print('disconnect');

      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
      
    });

    /* socket.on('nuevo-mensaje', (payload) {
      
      print('nuevo-mensaje: $payload');
      print('nombre:' + payload['nombre']);
      print('mensaje:' + payload['mensaje']);
      print(payload.containsKey('mensaje2') ? payload['mensaje2'] : 'No hay msj');

    }); */

  }

}