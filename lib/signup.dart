//import 'dart:html';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ceg4912_project/Support/queries.dart';
import 'package:ceg4912_project/Models/user.dart';
import 'package:flutter/services.dart';
import 'package:date_field/date_field.dart';

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

  // used for storing the text color and message of a screen alert (like: invalid password for example)
  String signUpEventMessage = "";
  Color signUpEventColor = const Color.fromARGB(0, 0, 0, 1);

  // stores the role of the user that is signing up
  Roles? role = Roles.customer;

  //merchant input fields
  List<Widget> merchantWidgets = <Widget>[];

  String firstName = "";
  String lastName = "";
  String ssn = "";
  String businessWebsite = "";
  String businessName = "";
  String businessType = "Public Corporation";
  String businessPhone = "";
  String psCompletionDelay = "";
  String billingFrequency = "";
  String industry = "General Retail";
  String financialInstitution = "Scotiabank";
  String csEmail = "";
  String csPhone = "";
  String streetAddress = "";
  String postalCode = "";
  String psDescription = "";
  DateTime merchantBirthDate =
      DateTime.now(); // temporary. This will become a DateTime object

  void signUp() async {
    // passwords must match
    if (!isPasswordValid(password1, password2) || !isEmailValid(email)) {
      // display error message
      setEventMessage(
          "Email Or Password Is Invalid", const Color.fromARGB(255, 255, 0, 0));
      return;
    }

    bool result = false;

    // create new user in database
    if (role == Roles.customer) {
      var conn = await Queries.getConnection();
      result = await Queries.insertCustomer(conn, email, password1);

      //print("customer creation successful? = " + result.toString());
    } else if (role == Roles.merchant) {
      // WIP
      if (areMerchantFieldsValid() == false) {
        setEventMessage("Merchant Information is Invalid",
            const Color.fromARGB(255, 255, 0, 0));
        return;
      }

      var conn = await Queries.getConnection();
      result = await Queries.insertMerchant(
          conn,
          email,
          password1,
          firstName,
          lastName,
          ssn,
          businessWebsite,
          businessName,
          businessType,
          businessPhone,
          psCompletionDelay,
          billingFrequency,
          industry,
          financialInstitution,
          csEmail,
          csPhone,
          streetAddress,
          postalCode,
          psDescription,
          merchantBirthDate);
      print("merchant creation successful? = " + result.toString());
    }

    if (result == true) {
      // display sign up success message
      setEventMessage(
          "Sign Up Successful", const Color.fromARGB(255, 21, 255, 0));
    } else {
      // display error message
      setEventMessage("Sign Up Failed", const Color.fromARGB(255, 255, 0, 0));
    }
  }

  // sends a message to the setup page UI to inform the user of something
  void setEventMessage(String message, Color color) {
    setState(() {
      signUpEventMessage = message;
      signUpEventColor = color;
    });
  }

  // checks if the input fields belonging only to the merchant are valid
  bool areMerchantFieldsValid() {
    if (firstName == "") {
      return false;
    } else if (lastName == "") {
      return false;
    } else if (ssn.length != 9 || int.tryParse(ssn) == null) {
      return false;
    } else if (businessPhone.length != 10 ||
        int.tryParse(businessPhone) == null) {
      return false;
    } else if (businessWebsite == "") {
      return false;
    } else if (businessType == "") {
      return false;
    } else if (businessName == "") {
      return false;
    } else if (psCompletionDelay == "") {
      return false;
    } else if (billingFrequency == "") {
      return false;
    } else if (industry == "") {
      return false;
    } else if (financialInstitution == "") {
      return false;
    } else if (csEmail == "") {
      return false;
    } else if (csPhone.length != 10 || int.tryParse(businessPhone) == null) {
      return false;
    } else if (streetAddress == "") {
      return false;
    } else if (postalCode.length != 6) {
      return false;
    } else if (psDescription == "") {
      return false;
    } else if (DateTime.now().year - merchantBirthDate.year < 18) {
      return false;
    }
    return true;
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

  // resets input data variables
  void clearStoredInputData() {
    email = "";
    password1 = "";
    password2 = "";
    firstName = "";
    lastName = "";
    ssn = "";
    businessWebsite = "";
    businessName = "";
    businessType = "Public Corporation";
    businessPhone = "";
    psCompletionDelay = "";
    billingFrequency = "";
    industry = "General Retail";
    financialInstitution = "Scotiabank";
    csEmail = "";
    csPhone = "";
    streetAddress = "";
    postalCode = "";
    psDescription = "";
    merchantBirthDate = DateTime.now();
  }

  // adds the fields that are unique to the merchant
  void addMerchantFields(BuildContext context) async {
    merchantWidgets.addAll([
      TextField(
        decoration: const InputDecoration(labelText: 'First Name'),
        onChanged: (value) => firstName = value,
      ),
      TextField(
        decoration: const InputDecoration(labelText: 'Last Name'),
        onChanged: (value) => lastName = value,
      ),
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Date of Birth",
        ),
      ),
      DateTimeFormField(
        initialValue: merchantBirthDate,
        lastDate: DateTime.now(),
        mode: DateTimeFieldPickerMode.date,
        onDateSelected: (DateTime date) {
          setState(() {
            merchantBirthDate = date;
          });
        },
      ),
      TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        decoration: const InputDecoration(labelText: "SSN"),
        onChanged: (value) => ssn = value,
      ),
      TextField(
        decoration: const InputDecoration(
            labelText: "Description of Products/Services"),
        onChanged: (value) => psDescription = value,
      ),
      TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        decoration: const InputDecoration(
            labelText: "Product/Service Completion Delay #Days"),
        onChanged: (value) => psCompletionDelay = value,
      ),
      TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        decoration: const InputDecoration(
            labelText: "Customer Billing Frequency #Days"),
        onChanged: (value) => billingFrequency = value,
      ),
      TextField(
        decoration: const InputDecoration(labelText: "Business Name"),
        onChanged: (value) => businessName = value,
      ),
      TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        decoration: const InputDecoration(labelText: "Business Phone"),
        onChanged: (value) => businessPhone = value,
      ),
      TextField(
        decoration: const InputDecoration(labelText: "Business Website"),
        onChanged: (value) => businessWebsite = value,
      ),
      TextField(
        decoration: const InputDecoration(labelText: "Street Address"),
        onChanged: (value) => streetAddress = value,
      ),
      TextField(
        decoration: const InputDecoration(labelText: "Postal Code"),
        onChanged: (value) => postalCode = value,
      ),
      TextField(
        decoration: const InputDecoration(labelText: "Customer Support Email"),
        onChanged: (value) => csEmail = value,
      ),
      TextFormField(
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        decoration: const InputDecoration(labelText: "Customer Support Phone"),
        onChanged: (value) => csPhone = value,
      ),
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Industry",
        ),
      ),
      DropdownButtonFormField<String>(
        items: [
          DropdownMenuItem(
            value: "General Retail",
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text("General Retail"),
            ),
          ),
          DropdownMenuItem(
            value: "Fashion/Apparel",
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text("Fashion/Apparel"),
            ),
          ),
          DropdownMenuItem(
            value: "Food Service",
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text("Food Service"),
            ),
          ),
          DropdownMenuItem(
            value: "Transportation",
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text("Transportation"),
            ),
          ),
          DropdownMenuItem(
            value: "Grooming/Hygiene",
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text("Grooming/Hygiene"),
            ),
          ),
          DropdownMenuItem(
            value: "Entertainment",
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text("Entertainment"),
            ),
          ),
        ],
        onChanged: (String? newValue) {
          setState(() {
            industry = newValue!;
            print(industry);
          });
        },
        value: industry,
      ),
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Business Type",
        ),
      ),
      DropdownButtonFormField<String>(
        items: [
          DropdownMenuItem(
            value: "Public Corporation",
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text("Public Corporation"),
            ),
          ),
          DropdownMenuItem(
            value: "Proprietorship",
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text("Proprietorship"),
            ),
          ),
          DropdownMenuItem(
            value: "Private Partnership",
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text("Private Partnership"),
            ),
          ),
        ],
        onChanged: (String? newValue) {
          setState(() {
            businessType = newValue!;
          });
        },
        value: businessType,
      ),
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Financial Institution",
        ),
      ),
      DropdownButtonFormField<String>(
        items: [
          DropdownMenuItem(
            value: "Scotiabank",
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text("Scotiabank"),
            ),
          ),
          DropdownMenuItem(
            value: "TD Bank",
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text("TD Bank"),
            ),
          ),
          DropdownMenuItem(
            value: "Bank of Montreal",
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text("Bank of Montreal"),
            ),
          ),
          DropdownMenuItem(
            value: "Royal Bank of Canada",
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text("Royal Bank of Canada"),
            ),
          ),
          DropdownMenuItem(
            value: "CIBC",
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: const Text("CIBC"),
            ),
          ),
        ],
        onChanged: (String? newValue) {
          setState(() {
            financialInstitution = newValue!;
          });
        },
        value: financialInstitution,
      )
    ]);
  }

  // remove the fields that are unique to the merchant
  void removeMerchantFields() {
    setState(() {
      merchantWidgets.clear();
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
                    clearStoredInputData();
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
                    clearStoredInputData();
                    addMerchantFields(context);
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
            children: merchantWidgets,
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
