import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  late Future<List<ParseObject>> futureTasks;

  @override
  void initState() {
    super.initState();
    futureTasks = getTasks();
  }

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

    final ParseResponse response = await task.save();
    if (!response.success) {
      throw Exception(response.error!.message);
    }
  }

  /// Fetch tasks for the current user
  Future<List<ParseObject>> getTasks() async {
    final ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;

    if (currentUser == null) {
      throw Exception('No user logged in');
    }

    final QueryBuilder<ParseObject> queryTasks =
        QueryBuilder<ParseObject>(ParseObject('Task'))
          ..whereEqualTo('createdBy', currentUser)
          ..orderByDescending('dueDate'); // Sort by due date (optional)

    final ParseResponse response = await queryTasks.query();

    if (response.success && response.results != null) {
      return response.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  /// Refresh the task list
  Future<void> refreshTasks() async {
    setState(() {
      futureTasks = getTasks();
    });
  }

  /// Show a dialog to add a task
  Future<void> showAddTaskDialog() async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController dueDateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              TextField(
                controller: dueDateController,
                decoration: const InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final dueDate = DateTime.tryParse(dueDateController.text.trim());

                if (title.isEmpty || dueDate == null) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide valid inputs')),
                  );
                  return;
                }

                try {
                  await addTask(title, dueDate);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task added successfully!')),
                  );
                  await refreshTasks();
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: FutureBuilder<List<ParseObject>>(
        future: futureTasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks found.'));
          } else {
            final tasks = snapshot.data!;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final title = task.get<String>('title') ?? 'Untitled';
                final dueDate = task.get<DateTime>('dueDate')?.toLocal();
                final isCompleted = task.get<bool>('isCompleted') ?? false;

                return ListTile(
                  title: Text(title),
                  subtitle: Text(dueDate != null
                      ? 'Due: ${dueDate.toString().substring(0, 10)}'
                      : 'No due date'),
                  trailing: Icon(
                    isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                  onTap: () {
                    // Optionally handle task status toggle or edit here
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
