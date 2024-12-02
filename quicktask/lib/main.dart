import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:quicktask/Login/Sign-up/login_page.dart';
import 'package:quicktask/task_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const String appId = 'Your_Back4App_Application_ID';
  const String clientKey = 'Your_Back4App_Client_Key';
  const String serverUrl = 'https://parseapi.back4app.com/';

  await Parse().initialize(appId, serverUrl, clientKey: clientKey, autoSendSessionId: true);

  runApp(const QuickTaskApp());
}

class QuickTaskApp extends StatelessWidget {
  const QuickTaskApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickTask',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
      routes: {
  '/tasks': (context) => const TaskPage(),
},

    );
  }
}


