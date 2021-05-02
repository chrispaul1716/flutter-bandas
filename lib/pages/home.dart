import 'dart:io'; 
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  

  List<Banda> bandas = [
    /* new Banda(id: '1', nombre: 'Kiss', votos: 5),
    new Banda(id: '2', nombre: 'Rata Blanca', votos: 10),
    new Banda(id: '3', nombre: 'Bajo Sueños', votos: 15),
    new Banda(id: '4', nombre: 'Mago de Oz', votos: 8), */
  ];


  @override
  void initState() { 

    final socketService = Provider.of<SocketService>(context, listen: false);
      /* Escuchar bandas-activas desde servidor*/
    socketService.socket.on('bandas-activas',  _manejarBandaActiva);
    super.initState();
  }

  _manejarBandaActiva(dynamic payload) {

    this.bandas = (payload as List).map((banda) => Banda.fromMap(banda)).toList();
    setState(() {});

  }

  @override
  void dispose() {
    
    final socketService = Provider.of<SocketService>(context, listen: false);
      /* Escuchar bandas-activas desde servidor*/
      socketService.socket.off('bandas-activas');

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(

      appBar: AppBar(
        title: Text('Bandas', style: TextStyle(color: Colors.black),),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 3,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10.0),
            child: (socketService.serverStatus == ServerStatus.Online)
              ? Icon(Icons.check_circle, color: Colors.blue[300])
              : Icon(Icons.offline_bolt, color: Colors.red)
          )
        ],
      ),

      body: Column(
        children: [
          SizedBox(height: 10.0,),
          _crearGrafica(),
          Expanded(
              child: ListView.builder(
              itemCount: bandas.length,
              itemBuilder: (context, i) => _bandaTile(bandas[i]) /* ---Lista Bandas--- */
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: agregarBanda /* ---AlertDialog agregar banda--- */
      ),

    );

  }


  /* ---Lista Bandas--- */
  Widget _bandaTile(Banda band) {

    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      background:Container(
        color: Colors.red[200], 
        child: Row(
          children: [
            SizedBox(width: 24.0,),
            Icon(Icons.delete, color: Colors.red),
          ],
        ),
        alignment: AlignmentDirectional.centerStart,
      ),

      onDismissed: (direction) {
        /* print('direccion: $direction');
        print('direccion: ${band.id}'); */
         socketService.socket.emit('eliminar-banda', {'id': band.id});
      },

      child: ListTile(

        leading: CircleAvatar(
          child: Text(band.nombre.substring(0,2), style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blue[100]
        ),
        title: Text(band.nombre, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        trailing: Text('${band.votos}', style: TextStyle(fontSize: 20)),
        onTap: () {
          // print(band.id);
          socketService.socket.emit('voto-banda', {'id': band.id});
        },

      ),
    );
  }

  /* ---AlertDialog agregar banda--- */
  agregarBanda() {

    /* Para obtener la informacion que ese escribe en el input */
    final txtCtrlNombre = new TextEditingController();
    
    //print('Nueva banda');
    
    // Si es android
    if (Platform.isAndroid) {
      
      return showDialog(
        context: context, 
        builder: (builder) {

          return AlertDialog(
            title: Text('Nombre nueva banda'),
            content: TextField(
              controller: txtCtrlNombre,
            ),
            actions: [
              MaterialButton(
                child: Text('Agregar'),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () {
                  // print(ctrlNombre.text);
                  agrBandaLista(txtCtrlNombre.text);
                },
              )
            ],
          );

        }
      );
    
    } else {

      showCupertinoDialog(
        context: context, 
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text('Nombre nueva banda'),
            content: TextField(
              controller: txtCtrlNombre,
            ),
            actions: [

              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Agregar'),
                onPressed: () {
                  agrBandaLista(txtCtrlNombre.text);
                }, 
              ),

              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Descartar'),
                onPressed: () {
                  Navigator.pop(context);
                }, 
              )

            ],
          );
        }
      );
    }

  }

  /* ---Agregar banda a la lista--- */
  void agrBandaLista(String nombre) {

    //print(nombre);

    if (nombre.length > 1) {
      // this.bandas.add(new Banda(id: DateTime.now().toString(), nombre: nombre, votos: 0));
      /* setState(() {
      
      }); */
      final soketService = Provider.of<SocketService>(context, listen: false);
      soketService.socket.emit('crear-banda', {'nombre': nombre});
              
    }

    Navigator.pop(context);

  }

  /* -----Crear grafica----- */
  Widget _crearGrafica() {

    Map<String, double> dataMap = {};

    bandas.forEach((banda) { 
      dataMap.putIfAbsent(banda.nombre, () => banda.votos.toDouble());
    });

    return Container(
      width: double.infinity,
      height: 200.0,
      child: PieChart(
        dataMap: dataMap,
        chartType: ChartType.ring,
        animationDuration: Duration(seconds: 1)
      )
    );
  }

}