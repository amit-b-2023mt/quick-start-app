import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class TaskService {
  /// Add a task for the current user
  Future<void> addTask(String title, DateTime dueDate) async {
    // Get the current logged-in user
    final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;

    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    // Create the task object
    final ParseObject task = ParseObject('Task')
      ..set('title', title)
      ..set('dueDate', dueDate)
      ..set('isCompleted', false)
      ..set('createdBy', currentUser); // Associate with the user

    // Save the task
    final ParseResponse response = await task.save();

    if (!response.success) {
      throw Exception(response.error!.message);
    }
  }

  /// Fetch tasks for the current user
  Future<List<ParseObject>> getTasks() async {
    // Get the current logged-in user
    final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;

    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    // Query tasks where 'createdBy' matches the current user
    final QueryBuilder<ParseObject> queryTasks =
        QueryBuilder<ParseObject>(ParseObject('Task'))
          ..whereEqualTo('createdBy', currentUser)
          ..orderByDescending('dueDate'); // Sort by due date (optional)

    // Execute the query
    final ParseResponse response = await queryTasks.query();

    if (response.success && response.results != null) {
      return response.results as List<ParseObject>;
    } else {
      return [];
    }
  }
  
}
