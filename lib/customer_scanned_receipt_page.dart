import 'package:ceg4912_project/Support/utility.dart';
import 'package:ceg4912_project/Support/queries.dart';
import 'package:ceg4912_project/Support/session.dart';
import 'package:ceg4912_project/merchant_receipt_page.dart';
import 'package:flutter/material.dart';
import 'package:ceg4912_project/Models/item.dart';
import 'package:ceg4912_project/Models/receipt_item.dart';

class CustomerScannedReceiptPage extends StatefulWidget {
  final int receiptID;

  const CustomerScannedReceiptPage({Key? key,required this.receiptID}) : super(key: key);

  @override
  State<CustomerScannedReceiptPage> createState() => CustomerScannedReceiptPageState(receiptID);
}

class CustomerScannedReceiptPageState extends State<CustomerScannedReceiptPage> {
  // locally stores the customer's receipt items
  List<Item> receiptItems = List<Item>.empty(growable: true);
  // stores the widgets the represent the customer's receipt items in the UI
  List<Widget> receiptItemWidgets = <Widget>[];

  // used for alerting the user of errors, warnings, and other events
  String eventMessage = "";
  Color eventMessageColor = Colors.white;

  var receiptID;
  CustomerScannedReceiptPageState(this.receiptID);

  // fetches the recently scanned receipt items from the database on load of the page
  @override
  void initState() {
    super.initState();
    getReceiptItems();
  }

  void getReceiptItems() async {
    int cId = Session.getSessionUser().getId();
    var conn = await Queries.getConnection();
    receiptItems = await Queries.getCustomerScannedReceiptItems(conn, receiptID);

    // if the query went wrong then it would return null
    if (receiptItems == null) {
      setState(() {
        eventMessage = "Item Retrieval Failed.";
        eventMessageColor = Colors.red;
      });

      clearEventMessage(2000);
      return;
    }

    // update the UI to show the item widgets
    setState(() {
      receiptItemWidgets = getItemWidgets();
      print("widget count: " + receiptItemWidgets.length.toString());
    });
  }

  // displays all eligible business items to the UI that can be added to the merchant's receipt
  List<Widget> getItemWidgets() {
    List<Widget> widgets = <Widget>[];

    int k = 0;
    for (int i = 0; i < receiptItems.length; i++) {
      // check if the current item is already in the receipt list
      bool inReceiptList = false;
      for (int j = 0; j < MerchantReceiptPage.receiptItems.length; j++) {
        if (MerchantReceiptPage.receiptItems[j].getItem().getItemId() ==
            receiptItems[i].getItemId()) {
          inReceiptList = true;
          break;
        }
      }

      // skip this item (don't display it in the UI) if it's already in the receipt list
      if (inReceiptList) {
        continue;
      }

      widgets.add(getItemWidget(i,k));
      k++;
    }
    return widgets;
  }

  Widget getItemWidget(int itemIndex, int widgetIndex) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        color: Utility.getBackGroundColor(),
        height: 100,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                "\$" + receiptItems[itemIndex].getPrice().toString(),
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                receiptItems[itemIndex].getName(),
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // clears the event message after some time has passed
  void clearEventMessage(int delay) {
    Future.delayed(Duration(milliseconds: delay), () {
      setState(() {
        eventMessage = "";
        eventMessageColor = Colors.white;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scanned Receipt"),
        backgroundColor: Utility.getBackGroundColor(),
      ),
      body: ListView(
        children: [
          // contains the UI widgets that represent all of the merchant's business items
          Column(children: receiptItemWidgets),

          // displays event messages to the user
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              eventMessage,
              style: TextStyle(color: eventMessageColor),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
