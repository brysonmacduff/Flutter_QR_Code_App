


import 'dart:async';
import 'dart:convert';


import 'package:ceg4912_project/customer_payment.dart';

import 'package:ceg4912_project/Support/utility.dart';

import 'package:flutter/material.dart';
import 'package:ceg4912_project/Support/queries.dart';
import 'package:ceg4912_project/Models/user.dart';
import 'package:flutter/services.dart';
import 'package:date_field/date_field.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mysql1/mysql1.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  //some stripe variables
  Map<String, dynamic>? paymentIntent;
  final client = http.Client();
  static Map<String, String> headers = {
    'Authorization':
    'Bearer sk_test_51LTCRODkzVSkvB16MkkVIZ1UZl5ewJzmaB9Qgm9yQrE8jTWX8UjrM1L8cu4ty6BI2SSyLKgvxqXGK1UVANlUQyc500J8r4XRY1',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  int cId=-1;
  // basic information
  String email = "";
  String password1 = "";
  String password2 = "";

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


  void makeInitialPayment(MySqlConnection conn, int cId) async{
    try { //fetch the new customer's SQL Id

      //Creates the Stripe Customer Object
      await CustomerPayment.createCustomer(client, conn, cId,email);

      //Retrieve the customer's stripe ID
      String cStripeId = await Queries.getStripeId(conn, cId);

      //Stripe API Call to access Customer Object
      var response1 = await client.get(
          Uri.parse('https://api.stripe.com/v1/customers/$cStripeId'),
          headers: headers);
      Map responseMap = jsonDecode(response1.body);
      print(responseMap.toString());

      //Extracts the Payment Method Id from the API Response
      String pId = responseMap['invoice_settings']['default_payment_method'];

      Map<String, dynamic> body = {
        'payment_method': pId,
        'setup_future_usage': 'off_session',
      };
      //Create a Payment Intent
      paymentIntent = await CustomerPayment.createPaymentIntent(
          client, '1', 'CAD', pId, cStripeId);
      print("This is the Payment Intent Object: " + paymentIntent.toString());

      //Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntent!['client_secret'],
              customerId: cStripeId,
              style: ThemeMode.system,
              merchantDisplayName: 'Merchant'))
          .then((value) {});

      //now finally display payment sheet
      displayPaymentSheet();

      //Confirm the Payment Intent
      var pi = paymentIntent!['id'];
      //Stripe API call
      var response2 = await client.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents/$pi/confirm'),
          headers: headers,
          body: body);
      print('Payment intent confirm->>> ${response2.body.toString()}');
    }catch(e,s){
      print('Exception: $e$s');
    }
  }

  //Displays the stripe Credit Card Payment Sheet
  void displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                      Text("Payment Successfull"),
                    ],
                  ),
                ],
              ),
            ));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("paid successfully")));

        paymentIntent = null;
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Text("Cancelled "),
          ));
    } catch (e) {
      print('$e');
    }
  }

  //Handles Customer/Merchant Sign-up procedure
  void signUp() async {
    // passwords must match
    if (!isPasswordValid(password1, password2) || !isEmailValid(email)) {
      // display error message
      Utility.displayAlertMessage(context, "Invalid Credentials",
          "Your email or password are not valid.");
      return;
    }

    bool result = false;
    var conn;

    try {
      conn = await Queries.getConnection();
    } catch (e) {
      Utility.displayAlertMessage(
          context, "Connection Error", "Please check your network connection.");
      return;
    }

    // create new user in database
    if (role == Roles.customer) {

      var conn = await Queries.getConnection();

      // insert a new customer into the SQL table
      try {
        result = await Queries.insertCustomer(conn, email, password1);
      } catch (e) {
        Utility.displayAlertMessage(context, "Account Creation Failed",
            "Something went wrong. Please check your network connection.");
        return;
      }


      //get Customer SQL ID
      cId= await Queries.getCustomerId(conn, email);

      //makes initial payment intent and displays payment sheet
      makeInitialPayment(conn,cId);

      //print("customer creation successful? = " + result.toString());
    } else if (role == Roles.merchant) {
      // WIP
      if (areMerchantFieldsValid() == false) {
        Utility.displayAlertMessage(
            context, "Invalid Credentials", "Merchant Information is Invalid");
        return;
      }

      try {
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
      } catch (e) {
        Utility.displayAlertMessage(context, "Account Creation Failed",
            "Something went wrong. Please check your network connection.");
        return;
      }
    }

    if (result == true) {
      // display sign up success message
      Utility.displayAlertMessage(context, "Sign Up Successful", "");
    } else {
      // display error message
      Utility.displayAlertMessage(
          context, "Sign Up Failed", "Something went wrong.");
    }
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
      Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          decoration: const InputDecoration(labelText: 'First Name'),
          onChanged: (value) => firstName = value,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          decoration: const InputDecoration(labelText: 'Last Name'),
          onChanged: (value) => lastName = value,
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Date of Birth",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: DateTimeFormField(
          initialValue: merchantBirthDate,
          lastDate: DateTime.now(),
          mode: DateTimeFieldPickerMode.date,
          onDateSelected: (DateTime date) {
            setState(() {
              merchantBirthDate = date;
            });
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          decoration: const InputDecoration(labelText: "SSN"),
          onChanged: (value) => ssn = value,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          decoration: const InputDecoration(
              labelText: "Description of Products/Services"),
          onChanged: (value) => psDescription = value,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          decoration: const InputDecoration(
              labelText: "Product/Service Completion Delay #Days"),
          onChanged: (value) => psCompletionDelay = value,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          decoration: const InputDecoration(
              labelText: "Customer Billing Frequency #Days"),
          onChanged: (value) => billingFrequency = value,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          decoration: const InputDecoration(labelText: "Business Name"),
          onChanged: (value) => businessName = value,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          decoration: const InputDecoration(labelText: "Business Phone"),
          onChanged: (value) => businessPhone = value,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          decoration: const InputDecoration(labelText: "Business Website"),
          onChanged: (value) => businessWebsite = value,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          decoration: const InputDecoration(labelText: "Street Address"),
          onChanged: (value) => streetAddress = value,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          decoration: const InputDecoration(labelText: "Postal Code"),
          onChanged: (value) => postalCode = value,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          decoration:
              const InputDecoration(labelText: "Customer Support Email"),
          onChanged: (value) => csEmail = value,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          ],
          decoration:
              const InputDecoration(labelText: "Customer Support Phone"),
          onChanged: (value) => csPhone = value,
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Industry",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: DropdownButtonFormField<String>(
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
            });
          },
          value: industry,
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Business Type",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: DropdownButtonFormField<String>(
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
      ),
      const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Financial Institution",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: DropdownButtonFormField<String>(
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
        ),
      ),
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
        backgroundColor: Utility.getBackGroundColor(),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              color: Utility.getBackGroundColor(),
              child: Row(
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
                  const Text("Customer", style: TextStyle(color: Colors.white)),
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
                  const Text(
                    "Merchant",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (value) => email = value,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              onChanged: (value) => password1 = value,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              onChanged: (value) => password2 = value,
            ),
          ),
          Column(
            children: merchantWidgets,
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              width: MediaQuery.of(context).size.width / 3,
              color: Utility.getBackGroundColor(),
              child: TextButton(
                onPressed: signUp,
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
