import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Exercise2 extends StatefulWidget {
  @override
  _Exercise2State createState() => _Exercise2State();
}

class _Exercise2State extends State<Exercise2> {
  Database? _database;
  List<Map<String, dynamic>> _users = [];
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _editIdController = TextEditingController();
  TextEditingController _editNameController = TextEditingController();
  TextEditingController _editAgeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'exercise2.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER)',
        );
      },
    );
    _fetchUsers();
  }

  Future<void> _addUser() async {
    if (_nameController.text.isNotEmpty && _ageController.text.isNotEmpty) {
      await _database?.insert('users', {
        'name': _nameController.text,
        'age': int.parse(_ageController.text),
      });
      _nameController.clear();
      _ageController.clear();
      _fetchUsers();
    }
  }

  Future<void> _fetchUsers() async {
    final users = await _database?.query('users');
    setState(() {
      _users = users ?? [];
    });
  }

  Future<void> _updateUser(int id) async {
    await _database?.update(
      'users',
      {
        'name': _editNameController.text,
        'age': int.parse(_editAgeController.text),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    _editIdController.clear();
    _editNameController.clear();
    _editAgeController.clear();
    _fetchUsers();
  }

  Future<void> _deleteUser(int id) async {
    await _database?.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ejercicio 2: CRUD Completo')),
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
          ElevatedButton(
            onPressed: _addUser,
            child: Text('Agregar Usuario'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  title: Text(user['name']),
                  subtitle: Text('Edad: ${user['age']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editIdController.text = user['id'].toString();
                          _editNameController.text = user['name'];
                          _editAgeController.text = user['age'].toString();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Editar Usuario'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: _editNameController,
                                      decoration:
                                          InputDecoration(labelText: 'Nombre'),
                                    ),
                                    TextField(
                                      controller: _editAgeController,
                                      keyboardType: TextInputType.number,
                                      decoration:
                                          InputDecoration(labelText: 'Edad'),
                                    ),
                                  ],
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      int id =
                                          int.parse(_editIdController.text);
                                      _updateUser(id);
                                      Navigator.pop(context);
                                    },
                                    child: Text('Guardar Cambios'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancelar'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteUser(user['id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
