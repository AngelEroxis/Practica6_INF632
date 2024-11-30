import 'package:flutter/material.dart';
import 'exercise1.dart';
import 'exercise2.dart';
import 'exercise3.dart';
import 'exercise4.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite Exercises',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SQLite Exercises Menu')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Ejercicio 1: Configuración e Inserción Básica'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Exercise1()),
              );
            },
          ),
          ListTile(
            title: Text('Ejercicio 2: CRUD Completo'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Exercise2()),
              );
            },
          ),
          ListTile(
            title: Text('Ejercicio 3: Búsqueda y Filtros'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Exercise3()),
              );
            },
          ),
          ListTile(
            title: Text('Ejercicio 4: Relación Uno a Muchos'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Exercise4()),
              );
            },
          ),
        ],
      ),
    );
  }
}
