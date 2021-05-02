import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:band_names/services/socket.dart';


class StatusPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
                                /* busca  SocketService */
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ServerStatus: ${socketService.serverStatus}')
          ],
        ),
     ),
     floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          socketService.emit('emitir-mensaje', {
            'nombre': 'Flutter', 
            'mensaje': 'Hola desde Flutter'
          });
        },
     ),
   );
  }
}