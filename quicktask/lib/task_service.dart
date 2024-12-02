import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class TaskService {
  Future<List<ParseObject>> getTasks() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Task'));
    final response = await query.query();
    if (response.success) {
      return response.results as List<ParseObject>;
    }
    return [];
  }

  Future<void> addTask(String title, DateTime dueDate) async {
    final task = ParseObject('Task')
      ..set('title', title)
      ..set('dueDate', dueDate)
      ..set('isCompleted', false);
    await task.save();
  }

  Future<void> toggleTaskStatus(ParseObject task, bool isCompleted) async {
    task.set('isCompleted', isCompleted);
    await task.save();
  }

  Future<void> deleteTask(ParseObject task) async {
    await task.delete();
  }
}
