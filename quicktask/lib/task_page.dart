import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'task_service.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TaskService taskService = TaskService();
  List<ParseObject> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    tasks = await taskService.getTasks();
    setState(() {});
  }

  Future<void> addTask() async {
    final titleController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: dateController, decoration: const InputDecoration(labelText: 'Due Date (YYYY-MM-DD)')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                taskService.addTask(titleController.text, DateTime.parse(dateController.text));
                fetchTasks();
                Navigator.pop(context);
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
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final title = task.get<String>('title')!;
          final isCompleted = task.get<bool>('isCompleted')!;
          return ListTile(
            title: Text(title, style: TextStyle(decoration: isCompleted ? TextDecoration.lineThrough : null)),
            trailing: IconButton(
              icon: Icon(isCompleted ? Icons.check_circle : Icons.radio_button_unchecked),
              onPressed: () {
                taskService.toggleTaskStatus(task, !isCompleted);
                fetchTasks();
              },
            ),
            onLongPress: () {
              taskService.deleteTask(task);
              fetchTasks();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: addTask, child: const Icon(Icons.add)),
    );
  }
}
