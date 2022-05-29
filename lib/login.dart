// dependances
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

// other project files
import 'package:ceg4912_project/homepage.dart';
import 'package:ceg4912_project/signup.dart';

class LogInPageRoute extends StatelessWidget {
  const LogInPageRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LogInPagePage());
  }
}

// serves as a wrapper class for rendering the actual splash page
class LogInPagePage extends StatefulWidget {
  const LogInPagePage({Key? key}) : super(key: key);

  @override
  State<LogInPagePage> createState() => _LogInPagePageState();
}

class _LogInPagePageState extends State<LogInPagePage> {
  String email = "";
  String password = "";

  // try to log in using the email and password, then redirect to home page
  // needs to be async to work
  // TESTING for now - MySQL queries seem to work!
  void signIn() async {
    /* currently configured to connect to the test ClearDB database 
    that is integrated with Heroku */
    var settings = ConnectionSettings(
        host: 'us-cdbr-east-05.cleardb.net',
        port: 3306,
        user: 'b4c34f510a627f',
        password: '51fb516c',
        db: 'heroku_3eb2baaa59ea134');

    var conn = await MySqlConnection.connect(settings);

    var results = await conn.query("select * from user");

    for (var row in results) {
      print(row);
    }
  }

  // redirect to the sign up page
  void signUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SignUpPage(),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Log In"),
        backgroundColor: const Color.fromARGB(255, 46, 73, 107),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (value) => email = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Password'),
              onChanged: (value) => password = value,
            ),
            TextButton(
              onPressed: signIn,
              child: const Text("Sign In"),
            ),
            TextButton(
              onPressed: signUp,
              child: const Text("Sign Up"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomePage(),
                  ),
                );
              },
              child: const Text("Home Page (Dev Mode)"),
            ),
          ],
        ),
      ),
    );
  }
}
