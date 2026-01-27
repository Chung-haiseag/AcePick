import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class StorageService {
  static const String _key = 'todos';

  Future<void> saveTodos(List<Todo> todos) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      todos.map((todo) => todo.toJson()).toList(),
    );
    await prefs.setString(_key, encodedData);
  }

  Future<List<Todo>> loadTodos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_key);

    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      return decodedData.map((item) => Todo.fromJson(item)).toList();
    }

    // 초기 더미 데이터 (React 앱 소스 기반)
    return [
      Todo(id: '1', text: 'React 투두 리스트 만들기', completed: true),
      Todo(id: '2', text: '디자인 예쁘게 꾸미기', completed: false),
    ];
  }
}
