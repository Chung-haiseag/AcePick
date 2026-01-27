import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/storage_service.dart';

class TodoProvider with ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  TodoProvider() {
    _init();
  }

  Future<void> _init() async {
    _todos = await _storageService.loadTodos();
    notifyListeners();
  }

  Future<void> addTodo(String text) async {
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
    );
    _todos.insert(0, newTodo);
    notifyListeners();
    await _storageService.saveTodos(_todos);
  }

  Future<void> toggleTodo(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        completed: !_todos[index].completed,
      );
      notifyListeners();
      await _storageService.saveTodos(_todos);
    }
  }

  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
    await _storageService.saveTodos(_todos);
  }
}
