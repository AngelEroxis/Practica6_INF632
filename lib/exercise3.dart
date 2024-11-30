import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Exercise3 extends StatefulWidget {
  @override
  _Exercise3State createState() => _Exercise3State();
}

class _Exercise3State extends State<Exercise3> {
  Database? _database;
  List<Map<String, dynamic>> _users = [];
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  TextEditingController _ageRangeStartController = TextEditingController();
  TextEditingController _ageRangeEndController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'exercise3.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, email TEXT UNIQUE)',
        );
      },
    );
    _fetchUsers();
  }

  Future<void> _addUser() async {
    if (_nameController.text.isNotEmpty &&
        _ageController.text.isNotEmpty &&
        _emailController.text.isNotEmpty) {
      await _database?.insert('users', {
        'name': _nameController.text,
        'age': int.parse(_ageController.text),
        'email': _emailController.text,
      });
      _nameController.clear();
      _ageController.clear();
      _emailController.clear();
      _fetchUsers();
    }
  }

  Future<void> _fetchUsers() async {
    final users = await _database?.query('users');
    setState(() {
      _users = users ?? [];
    });
  }

  Future<void> _searchUsers() async {
    final searchQuery = _searchController.text;
    final users = await _database?.query(
      'users',
      where: 'name LIKE ?',
      whereArgs: ['%$searchQuery%'],
    );
    setState(() {
      _users = users ?? [];
    });
  }

  Future<void> _filterUsersByAgeRange() async {
    final startAge = int.tryParse(_ageRangeStartController.text) ?? 0;
    final endAge = int.tryParse(_ageRangeEndController.text) ?? 100;

    final users = await _database?.query(
      'users',
      where: 'age BETWEEN ? AND ?',
      whereArgs: [startAge, endAge],
    );
    setState(() {
      _users = users ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ejercicio 3: Búsqueda y Filtros')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Edad'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
          ),
          ElevatedButton(
            onPressed: _addUser,
            child: Text('Agregar Usuario'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: 'Buscar por Nombre'),
            ),
          ),
          ElevatedButton(
            onPressed: _searchUsers,
            child: Text('Buscar'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ageRangeStartController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Edad Desde'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _ageRangeEndController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Edad Hasta'),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _filterUsersByAgeRange,
            child: Text('Filtrar por Rango de Edad'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  title: Text(user['name']),
                  subtitle:
                      Text('Edad: ${user['age']}, Email: ${user['email']}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
