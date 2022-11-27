

import 'package:ceg4912_project/Support/utility.dart';
import 'package:ceg4912_project/Support/queries.dart';
import 'package:ceg4912_project/Support/session.dart';
import 'package:ceg4912_project/customer_home.dart';
import 'package:ceg4912_project/merchant_receipt_history.dart';
import 'package:ceg4912_project/merchant_receipt_page.dart';
import 'package:flutter/material.dart';
import 'package:ceg4912_project/Models/item.dart';
import 'package:ceg4912_project/Models/receipt_item.dart';

class ReceiptItemListPage extends StatefulWidget {
  final List<Item> items;

  const ReceiptItemListPage({Key? key,required this.items}) : super(key: key);

  @override
  State<ReceiptItemListPage> createState() => ReceiptItemListPageState(items);
}

class ReceiptItemListPageState extends State<ReceiptItemListPage> {
  // locally stores the customer's receipt items
  List<Item> receiptItems = List<Item>.empty(growable: true);
  List<int> ItemsQuantity = List<int>.empty(growable: true);

  // stores the widgets the represent the customer's receipt items in the UI
  List<Widget> receiptItemWidgets = <Widget>[];

  // used for alerting the user of errors, warnings, and other events
  String eventMessage = "";
  Color eventMessageColor = Colors.white;

  var items;
  ReceiptItemListPageState(this.items);

  // fetches the recently scanned receipt items from the database on load of the page
  @override
  void initState() {
    super.initState();
    getItemWidgets();
  }

  // displays all eligible business items to the UI that can be added to the merchant's receipt
  void getItemWidgets() {
    List<Widget> wItems = [];
    for (Item item in this.items) {
      //check if the current item is already in the receipt list
      wItems.add(getItemWidget(item));
    }

    setState(() {

      receiptItemWidgets = wItems;
    });
  }

  Widget getItemWidget(Item item) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        color: Utility.getBackGroundColor(),
        height: 100,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                "\$" + item.getPrice().toString(),
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                item.getName() ,
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
        title: const Text("List Of Items"),
        backgroundColor: Utility.getBackGroundColor(),
        leading: BackButton(onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(
              builder: (_) => MerchantReceiptHistoryPage()
          ));},
        ),
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
