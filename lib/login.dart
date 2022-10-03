// dependencies
//import 'dart:html';

import 'package:ceg4912_project/merchant_home.dart';
import 'package:flutter/material.dart';
//import 'package:mysql1/mysql1.dart';

// other project pages
import 'package:ceg4912_project/signup.dart';

// support files
import 'package:ceg4912_project/Support/queries.dart';
import 'package:ceg4912_project/Support/session.dart';

// model files
import 'package:ceg4912_project/Models/user.dart';

//import 'item_page.dart';

class LogInPageRoute extends StatelessWidget {
  const LogInPageRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LogInPage());
  }
}

// serves as a wrapper class for rendering the actual splash page
class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  String email = "";
  String password = "";

  // try to log in using the email and password, then redirect to home page
  // needs to be async to work
  // TESTING for now - MySQL queries seem to work!
  void signIn() async {
    /* currently configured to connect to the test ClearDB database 
    that is integrated with Heroku */

    var conn = await Queries.getConnection();
    var user = await Queries.getUser(conn, email, password);

    if (user == null) {
      // login failed
      print("login failed");
      return;
    }

    // set this user as the current session user
    Session.setSessionUser(user);

    if (user.getRole() == Roles.customer) {
      // go to customer home page
      print("login as customer");
    } else if (user.getRole() == Roles.merchant) {
      // go to merchant home page
      print("login as merchant");
      loadMerchantHomePage();
    }
  }

  // redirect to the sign up page
  void loadSignUpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SignUpPage(),
      ),
    );
  }

  // appends the merchant home page to the page stack
  void loadMerchantHomePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MerchantHomePage(),
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
              onPressed: loadSignUpPage,
              child: const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
