import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/models/modelAddTarefa.dart';

class TodoController extends ChangeNotifier {
  List<TodoModel> todos = [];

  TodoController() {
    loadTodos();
  }

  void addTodo(TodoModel todo) {
    todos.add(todo);
    saveTodos();
    notifyListeners();
  }

  void removeTodo(int index) {
    todos.removeAt(index);
    saveTodos();
    notifyListeners();
  }

  Future<void> saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList =
    todos.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('todos', jsonList);
  }

  Future<void> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('todos');

    if (list != null) {
      todos = list
          .map((e) => TodoModel.fromJson(jsonDecode(e)))
          .toList();
      notifyListeners();
    }
  }
}
