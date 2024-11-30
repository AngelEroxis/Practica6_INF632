import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Exercise4 extends StatefulWidget {
  @override
  _Exercise4State createState() => _Exercise4State();
}

class _Exercise4State extends State<Exercise4> {
  Database? _database;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _tasks = [];
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _taskTitleController = TextEditingController();
  TextEditingController _taskUserIdController = TextEditingController();

  int? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'exercise4.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER, email TEXT UNIQUE)',
        );
        db.execute(
          'CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, title TEXT, completed BOOLEAN, FOREIGN KEY (userId) REFERENCES users (id))',
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

  Future<void> _fetchTasks(int userId) async {
    final tasks = await _database?.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    setState(() {
      _tasks = tasks ?? [];
    });
  }

  Future<void> _addTask() async {
    if (_taskTitleController.text.isNotEmpty && _selectedUserId != null) {
      await _database?.insert('tasks', {
        'userId': _selectedUserId,
        'title': _taskTitleController.text,
        'completed': false,
      });
      _taskTitleController.clear();
      _fetchTasks(_selectedUserId!);
    }
  }

  Future<void> _toggleTaskCompletion(int taskId, bool currentStatus) async {
    await _database?.update(
      'tasks',
      {'completed': !currentStatus},
      where: 'id = ?',
      whereArgs: [taskId],
    );
    _fetchTasks(_selectedUserId!);
  }

  Future<void> _deleteTask(int taskId) async {
    await _database?.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [taskId],
    );
    _fetchTasks(_selectedUserId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ejercicio 4: Relación Uno a Muchos')),
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
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  title: Text(user['name']),
                  subtitle:
                      Text('Edad: ${user['age']}, Email: ${user['email']}'),
                  onTap: () {
                    setState(() {
                      _selectedUserId = user['id'];
                    });
                    _fetchTasks(user['id']);
                  },
                );
              },
            ),
          ),
          if (_selectedUserId != null) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _taskTitleController,
                decoration: InputDecoration(labelText: 'Título de Tarea'),
              ),
            ),
            ElevatedButton(
              onPressed: _addTask,
              child: Text('Agregar Tarea'),
            ),
            Text('Tareas del Usuario'),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return ListTile(
                    title: Text(task['title']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            task['completed'] == 1
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                          ),
                          onPressed: () {
                            _toggleTaskCompletion(
                                task['id'], task['completed'] == 1);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteTask(task['id']);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
