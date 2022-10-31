import 'dart:convert';
import 'dart:ffi';

import 'package:ceg4912_project/Models/customer_receipt_list.dart';
import 'package:ceg4912_project/Support/queries.dart';
import 'package:ceg4912_project/item_page.dart';
import 'package:ceg4912_project/Support/session.dart';
import 'package:ceg4912_project/Support/utility.dart';
//import 'package:ceg4912_project/merchant_receipt_page.dart';
import 'package:flutter/material.dart';
import 'package:ceg4912_project/Models/user.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mysql1/mysql1.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({Key? key}) : super(key: key);

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
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

/*
  void loadReceiptPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomerReceiptPage(),
      ),
    );

    // clear the static receipt item list upon returning from the receipt page
    CustomerReceiptPage.receiptItems.clear();
  }
**/

  Future<void> loadScanReceiptPage() async {
    //loads scanning page
    String result = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.QR);
    print("label data: " + result);

    //extracts the receipt Id from the JSON result
    Map extractID = jsonDecode(result);
    print(extractID["receiptId"]);
    int receiptId = int.parse(extractID["receiptId"]);
    //Assign userId with current customer Id
    int userId = Session.getSessionUser().getId();
    //establish connection with database and overwrite receipt customer Id column with with the current customer Id.
    try{
      MySqlConnection connection = await Queries.getConnection();
      bool success = false;
      Queries.editReceiptCid(connection, receiptId, userId);
      success = true;
      print("############################## RECEIPT SUCCESS? " + success.toString());
    }catch(e){
      print("############################## EXCEPTION : Scan failed");

    }
    showAlertDialog(context);



  }

  void loadCustomerAccountPage() {}

  void loadReceiptHistoryPage() {}

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
  }

  //
  showAlertDialog(BuildContext context) {

    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
      Navigator.push(
          context, MaterialPageRoute(
          builder: (_) => const CustomerReceiptList())); },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Scan Success"),
      content: const Text("Receipt Added"),
      actions: [
        okButton,
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
            width: MediaQuery.of(context).size.width,
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
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 4.5,
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
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 4.5,
                  color: Utility.getBackGroundColor(),
                  child: TextButton(
                    onPressed: loadScanReceiptPage,
                    child: const Text(
                      "Scan Receipt",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                /*
                Container(
                  margin: const EdgeInsets.all(8),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 4.5,
                  color: Utility.getBackGroundColor(),
                  child: TextButton(
                    onPressed: loadReceiptHistoryPage,
                    child: const Text(
                      "Create Receipt",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
           **/
                Container(
                  margin: const EdgeInsets.all(8),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 4.5,
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
