import 'package:ceg4912_project/Support/queries.dart';
import 'package:ceg4912_project/Support/session.dart';
import 'package:flutter/material.dart';
import 'package:ceg4912_project/Models/user.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // basic information
  String email = "";
  String password1 = "";
  String password2 = "";

  String signUpEventMessage = "";
  Color signUpEventColor = const Color.fromARGB(0, 0, 0, 1);

  // stores the role of the user that is signing up
  Roles? role = Roles.customer;

  List<Widget> widgets = <Widget>[];

  void signUp() async {
    // passwords must match
    if (!isPasswordValid(password1, password2) || !isEmailValid(email)) {
      // display error message
      setState(() {
        signUpEventMessage = "Email Or Password Is Invalid";
        signUpEventColor = const Color.fromARGB(255, 255, 0, 0);
      });

      return;
    }

    bool result = false;

    // create new user in database
    if (role == Roles.customer) {
      var conn = await Queries.getConnection();
      result = await Queries.insertCustomer(conn, email, password1);

      print("customer creation successful? = " + result.toString());
    } else if (role == Roles.merchant) {
      // WIP
      print("create a merchant account");
    }

    setState(() {
      if (result == true) {
        // display sign up success message
        signUpEventMessage = "Sign Up Successful";
        signUpEventColor = const Color.fromARGB(255, 21, 255, 0);
      } else {
        // display error message
        signUpEventMessage = "Sign Up Failed";
        signUpEventColor = const Color.fromARGB(255, 255, 0, 0);
      }
    });
  }

  // checks if the provided email is of a valid form
  bool isEmailValid(String email) {
    if (email.isEmpty) {
      return false;
    }
    return true;
  }

  // checks if the password is valid
  bool isPasswordValid(String p1, String p2) {
    if (p1.isEmpty || p2.isEmpty) {
      return false;
    } else if (p1 != p2) {
      return false;
    }
    return true;
  }

  // adds the fields that are unique to the merchant
  void addMerchantFields() {
    setState(() {
      for (int i = 0; i < 10; i++) {
        widgets.add(
          TextField(
            decoration:
                InputDecoration(labelText: 'Merchant Field ' + i.toString()),
          ),
        );
      }
    });
    print("adding merchant fields");
  }

  // remove the fields that are unique to the merchant
  void removeMerchantFields() {
    setState(() {
      widgets.clear();
      print("clearing merchant fields");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: const Color.fromARGB(255, 46, 73, 107),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio(
                value: Roles.customer,
                groupValue: role,
                onChanged: (Roles? value) {
                  setState(() {
                    role = value;
                    removeMerchantFields();
                  });
                },
              ),
              const Text("Customer"),
              Radio(
                value: Roles.merchant,
                groupValue: role,
                onChanged: (Roles? value) {
                  setState(() {
                    role = value;
                    // add more widgets for merchant financial info
                    addMerchantFields();
                  });
                },
              ),
              const Text("Merchant"),
            ],
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Email'),
            onChanged: (value) => email = value,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Password'),
            onChanged: (value) => password1 = value,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Confirm Password'),
            onChanged: (value) => password2 = value,
          ),
          Column(
            children: widgets,
          ),
          TextButton(
            onPressed: signUp,
            child: const Text("Sign Up"),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              signUpEventMessage,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: signUpEventColor,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
