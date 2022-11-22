import 'dart:convert';
import 'dart:ffi';

import 'package:ceg4912_project/Support/queries.dart';
import 'package:ceg4912_project/customer_payment.dart';
import 'package:ceg4912_project/customer_receipt_history_page.dart';
import 'package:ceg4912_project/customer_scanned_receipt_page.dart';
import 'package:ceg4912_project/item_page.dart';
import 'package:ceg4912_project/Support/session.dart';
import 'package:ceg4912_project/Support/utility.dart';
import 'package:ceg4912_project/login.dart';
//import 'package:ceg4912_project/merchant_receipt_page.dart';
import 'package:flutter/material.dart';
import 'package:ceg4912_project/Models/user.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mysql1/mysql1.dart';
import 'package:http/http.dart' as http;


class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({Key? key}) : super(key: key);

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  int receiptId=-1;
  Map<String, dynamic>? paymentIntent;
  final client = http.Client();
  static Map<String, String> headers = {
    'Authorization':
    'Bearer sk_test_51LTCRODkzVSkvB16MkkVIZ1UZl5ewJzmaB9Qgm9yQrE8jTWX8UjrM1L8cu4ty6BI2SSyLKgvxqXGK1UVANlUQyc500J8r4XRY1',
    'Content-Type': 'application/x-www-form-urlencoded'
  };
  User user = Session.getSessionUser();

  // loads the item page
  void loadItemPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ItemPage(),
      ),
    );
  }

  makePayment(int receiptId) async {
    try {
      //final customer = await createCustomer();
      MySqlConnection connection = await Queries.getConnection();
      int userId = Session.getSessionUser().getId();
      //Queries.editStripeId(connection, customer['id'], userId);
      String cStripId = await Queries.getStripeId(connection, userId);
      var response = await client.get(
          Uri.parse('https://api.stripe.com/v1/customers/$cStripId'),
          headers: headers);

      Map responseMap = jsonDecode(response.body);
      String pId = responseMap['invoice_settings']['default_payment_method'];

      Map<String, dynamic> body = {
        'payment_method': pId,
        'setup_future_usage': 'off_session',
      };

      var paymentAmount =
      //make payment intent
      paymentIntent = await CustomerPayment.createPaymentIntent(client,double.parse(await Queries.getReceiptAmount(connection, receiptId)).toStringAsFixed(0), 'CAD', pId, cStripId);

      var pi = paymentIntent!['id'];
      //confirm payment intent
      var response2 = await client.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents/$pi/confirm'),
          headers: headers,
          body: body);

      print('Payment intent confirm->>> ${response2.body.toString()}');
      Navigator.push(
          context, MaterialPageRoute(
          builder: (_) => CustomerScannedReceiptPage(receiptID: receiptId)));
    } catch (e, s) {
      print('exception:$e$s');
    }
  }


  Future<void> loadScanReceiptPage() async {
    //loads scanning page
    String result = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.QR);
    print("label data: " + result);

    //extracts the receipt Id from the JSON result
    Map extractID = jsonDecode(result);
    print(extractID["receiptId"]);
    receiptId = int.parse(extractID["receiptId"]);

    //Assign userId with current customer Id
    int userId = Session.getSessionUser().getId();

    //Continue to Payment using stored Stripe Customer's Payment Method
    try {
      //show an alert dialog box to confirm proceed with payment
      showAlertDialog(context);
    }
    catch (e) {
      print("PAYMENT FAILED ==> makePayment() threw Exception");
    }
    //establish connection with database and overwrite receipt customer Id column with with the current customer Id.
    try {
      MySqlConnection connection = await Queries.getConnection();
      bool success = false;
      Queries.editReceiptCid(connection, receiptId, userId);
      success = true;
      print("############################## RECEIPT SUCCESS? $success");
    } catch (e) {
      print("############################## EXCEPTION : Scan failed");
    }

  }

  void loadCustomerAccountPage() {}

  void loadReceiptHistoryPage() {
    Navigator.push(
        context, MaterialPageRoute(
        builder: (_) => const CustomerReceiptHistoryPageRoute()));
  }

  void loadSettings() {
    // Does nothing right now. WIP.
    // The pop is needed since this function's button is inside another BuildContext. This closes the PopupMenu.
    Navigator.pop(context);
  }

  // clears the session user and returns to the sign in page
  void signOut() {
    Session.clearSessionUser();
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const LogInPage()));
  }


  showAlertDialog(BuildContext context) {
    // set up the button
    Widget yesButton = TextButton(
      style: TextButton.styleFrom(backgroundColor: Colors.greenAccent,
          textStyle: const TextStyle(color: Colors.black)),
      onPressed: () async {
        await makePayment(receiptId);
      },
      child: const Text("Pay"),
    );
    // set up the button
    Widget cancelButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Checkout"),
      content: const Text("Proceed with payment?"),
      actions: [
        yesButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Home Page"),
        backgroundColor: Utility.getBackGroundColor(),
        actions: <Widget>[
          PopupMenuButton(
            offset: Offset.zero,
            color: Utility.getBackGroundColor(),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: InkWell(
                    splashColor: Colors.grey,
                    child: IconButton(
                      icon: const Icon(Icons.settings),
                      color: Colors.white,
                      onPressed: loadSettings,
                    ),
                  ),
                ),
                PopupMenuItem(
                  child: InkWell(
                    splashColor: Colors.grey, // splash color
                    child: IconButton(
                      icon: const Icon(Icons.logout_rounded),
                      color: Colors.red,
                      onPressed: signOut,
                    ),
                  ),
                ),
              ];
            },
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.blue,
            width: MediaQuery
                .of(context)
                .size
                .width,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                Session.getSessionUser().getEmail(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height / 4.5,
                  color: Utility.getBackGroundColor(),
                  child: TextButton(
                    onPressed: loadCustomerAccountPage,
                    child: const Text(
                      "Account",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height / 4.5,
                  color: Utility.getBackGroundColor(),
                  child: TextButton(
                    onPressed: loadScanReceiptPage,
                    child: const Text(
                      "Scan Receipt",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8),
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: MediaQuery
                      .of(context)
                      .size
                      .height / 4.5,
                  color: Utility.getBackGroundColor(),
                  child: TextButton(
                    onPressed: loadReceiptHistoryPage,
                    child: const Text(
                      "Receipt History",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
