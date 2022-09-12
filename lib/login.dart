// dependencies
//import 'dart:html';

import 'package:flutter/material.dart';
//import 'package:mysql1/mysql1.dart';

// other project pages
import 'package:ceg4912_project/homepage.dart';
import 'package:ceg4912_project/signup.dart';

// support files
import 'package:ceg4912_project/Support/queries.dart';
import 'package:ceg4912_project/Support/session.dart';

// model files
import 'package:ceg4912_project/Models/user.dart';

import 'Models/item_page.dart';
import 'Models/merchant_receipt_history.dart';

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
      print("login as customer");
      // go to customer home page
    } else if (user.getRole() == Roles.merchant) {
      print("login as merchant");
      // go to merchant home page
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

  // redirect to the item page
  void itemPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ItemPage(),
      ),
    );
  }

  // redirect to the receipt history page
  void receiptHistoryPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MerchantReceiptHistoryPage(),
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
              onPressed: itemPage,
              child: const Text("Item Page (Dev Mode)"),
            ),
            TextButton(
              onPressed: receiptHistoryPage,
              child: const Text("Receipt History (Dev Mode)"),
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
