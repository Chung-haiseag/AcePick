import 'dart:convert';

class Todo {
  final String id;
  final String text;
  final bool completed;

  Todo({required this.id, required this.text, this.completed = false});

  Todo copyWith({String? id, String? text, bool? completed}) {
    return Todo(
      id: id ?? this.id,
      text: text ?? this.text,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'completed': completed};
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      text: json['text'],
      completed: json['completed'],
    );
  }
}
