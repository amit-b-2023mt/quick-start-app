import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  Future<void> loginUser() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final ParseUser user = ParseUser(username, password, email);
    var response = await user.login();

    if (response.success) {
      // Navigate to the task list page
      Navigator.pushReplacementNamed(context, '/tasks');
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error!.message)));
    }
  }

 Future<void> signUpUser() async {
  final username = usernameController.text.trim();
  final email = emailController.text.trim();
  final password = passwordController.text.trim();

  final ParseUser user = ParseUser(username, password, email);
  var response = await user.signUp();

  if (response.success) {
    Navigator.pushReplacementNamed(context, '/tasks');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response.error!.message)));
  }
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Quick Task App')),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(controller: usernameController, decoration: const InputDecoration(labelText: 'Username')),
          TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 16.0),
          ElevatedButton(onPressed: signUpUser, child: const Text('Sign Up')),
          const SizedBox(height: 16.0),
          ElevatedButton(onPressed: loginUser, child: const Text('Login')),
        ],
      ),
    ),
  );
}
}
