import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Exercise1 extends StatefulWidget {
  @override
  _Exercise1State createState() => _Exercise1State();
}

class _Exercise1State extends State<Exercise1> {
  Database? _database;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'exercise1.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER)',
        );
      },
    );
  }

  Future<void> _addUser() async {
    await _database?.insert('users', {'name': 'Juan', 'age': 25});
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final users = await _database?.query('users');
    setState(() {
      _users = users ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ejercicio 1: Configuración Básica')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _addUser,
            child: Text('Agregar Usuario'),
          ),
          ElevatedButton(
            onPressed: _fetchUsers,
            child: Text('Listar Usuarios'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  title: Text(user['name']),
                  subtitle: Text('Edad: ${user['age']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
