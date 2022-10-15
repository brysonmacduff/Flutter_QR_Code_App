import 'package:ceg4912_project/Support/queries.dart';
import 'package:ceg4912_project/Support/session.dart';
import 'package:ceg4912_project/merchant_receipt_qr_page.dart';
import 'package:flutter/material.dart';
import 'package:ceg4912_project/Support/utility.dart';
import 'package:ceg4912_project/Models/receipt_item.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:ceg4912_project/merchant_receipt_item_page.dart';
import 'package:ceg4912_project/Models/item.dart';
import 'package:ceg4912_project/Models/receipt.dart';
import 'dart:convert';

import 'package:mysql1/mysql1.dart';

class MerchantReceiptPage extends StatefulWidget {
  const MerchantReceiptPage({Key? key}) : super(key: key);
  // stores the list of receipt items inside the current receipt
  static List<ReceiptItem> receiptItems =
      List<ReceiptItem>.empty(growable: true);

  @override
  State<MerchantReceiptPage> createState() => _MerchantReceiptPageState();
}

class _MerchantReceiptPageState extends State<MerchantReceiptPage> {
  // Stores all of the items that belong to this merchant. This is used for rapidly adding items to a receipt during label scanning.
  // This list is populated on loading of this page. Data is passed from the merchant home page.
  List<Item> merchantItems = List.empty();

  Map<int, Widget> receiptItemWidgets = Map<int, Widget>();
  double receiptPriceSum = 0;

  // reset the current receipt item list and clear the UI
  void clearReceiptItems() {
    MerchantReceiptPage.receiptItems.clear();

    setState(() {
      receiptItemWidgets.clear();
      receiptPriceSum = 0;
    });
  }

  // Pushes the receipt item page to the page stack. The merchant can choose the items to add to the receipt in this page.
  void loadReceiptItemPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReceiptItemPage(),
      ),
    );

    // when the ReceiptItemPage is popped, this code will be reached due to the "await" before Navigator.Push
    setState(() {
      // generate the receipt item widgets in the UI
      receiptItemWidgets = getReceiptItemWidgets();
      updateReceiptPriceSum();
    });
  }

  // Opens a scan view that reads data from a 1D bar code label.
  Future<void> scanLabel() async {
    // starts the barcode scan and returns the barcode data
    String result = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    print("label data: " + result);

    // If the merchant cancels the scan then the result returns -1.
    if (result == "-1") {
      // update the receipt page to represent the current state of the in-progress receipt
      setState(() {
        // generate the receipt item widgets in the UI
        receiptItemWidgets = getReceiptItemWidgets();
        updateReceiptPriceSum();
      });

      // exit if label scanning is complete
      return;
    }

    // Add the scanned item to the receipt --------------------------------------------------------------------------------

    // This item map will only contain the item id. We only care about the id right now.
    Map itemMap = jsonDecode(result);
    int iId = int.parse(itemMap["iId"]);

    bool inReceipt = false;

    // Look to see if the item is already on the receipt. If there, increment the item quanity.
    for (int i = 0; i < MerchantReceiptPage.receiptItems.length; i++) {
      ReceiptItem ri = MerchantReceiptPage.receiptItems[i];
      if (ri.getItem().getItemId() == iId) {
        ri.incrementQuantity();
        MerchantReceiptPage.receiptItems[i] = ri;
        inReceipt = true;
        break;
      }
    }

    // if the item was not found in the receipt, then add it
    if (inReceipt == false) {
      // find the item in the merchant items list that was scanned
      for (int i = 0; i < merchantItems.length; i++) {
        Item item = merchantItems[i];
        if (iId == item.getItemId()) {
          // add the scanned item to the receipt
          ReceiptItem ri = ReceiptItem.create(item);
          MerchantReceiptPage.receiptItems.add(ri);
          break;
        }
      }
    }

    // if the label data is invalid then this function will not alter the receipt and will harmless return to the scan view

    // After the scan, the scan view opens itself again so the merchant can scan the next item.
    scanLabel();
  }

  // updates the receipt cost total in the UI
  void updateReceiptPriceSum() {
    // recaluclate the receipt price total
    receiptPriceSum = 0;
    for (int i = 0; i < MerchantReceiptPage.receiptItems.length; i++) {
      ReceiptItem ri = MerchantReceiptPage.receiptItems[i];
      receiptPriceSum += ri.getQuanity() * ri.getItem().getPrice();
    }
  }

  // Convert receipt data to JSON and generate a QR code. Pushes a new page that has a big receipt QR code.
  void finishReceipt() async {
    if (MerchantReceiptPage.receiptItems.isEmpty) {
      return;
    }
    /*
    String qrData = "{\"merchantId\":\"" +
        Session.getSessionUser().getId().toString() +
        "\",\"items\":";
    for (int i = 0; i < MerchantReceiptPage.receiptItems.length; i++) {
      ReceiptItem ri = MerchantReceiptPage.receiptItems[i];
      if (i == MerchantReceiptPage.receiptItems.length - 1) {
        qrData += ri.toJSON();
      } else {
        qrData += ri.toJSON() + ",";
      }
    }
    qrData += "}";
    print(qrData);*/
    MySqlConnection conn;

    // get the next available receipt id from the database
    int receiptId = -1;
    try {
      conn = await Queries.getConnection();
      var result = await Queries.getMaxReceiptId(conn);
      receiptId = result.first["maxId"] + 1;
    } catch (e) {
      print("Receipt ID SQL query failed.");
      return;
    }

    // create receipt object
    Receipt receipt = Receipt.all(
        receiptId,
        DateTime.now(),
        receiptPriceSum,
        Session.getSessionUser().getId(),
        -1, // NOTE: the customer id argument is set to -1 since this information will be set by the customer when they scan the receipt
        MerchantReceiptPage.receiptItems);

    // Write the receipt to the database. Upon success, display the QR code that contains the receipt id to the customer to scan.
    var insertionResult = false;
    try {
      conn = await Queries.getConnection();
      insertionResult = await Queries.insertReceipt(conn, receipt);
    } catch (e) {
      print("Failed to insert receipt to the database.");
      return;
    }

    if (insertionResult == false) {
      return;
    }

    // this is the JSON data that will appear in the QR code receipt that is presented to the customer
    String qrData = "{\"receiptId\":'" + receiptId.toString() + "'}";

    // push the page that contains the qrData
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MerchantReceiptQRPage(),
        settings: RouteSettings(
          arguments: {"qrData": qrData},
        ),
      ),
    );
  }

  // gets a complete list of UI widgets for each of the receipt items
  Map<int, Widget> getReceiptItemWidgets() {
    Map<int, Widget> pairs = Map<int, Widget>();
    for (int i = 0; i < MerchantReceiptPage.receiptItems.length; i++) {
      ReceiptItem ri = MerchantReceiptPage.receiptItems[i];
      int id = ri.getItem().getItemId();
      Widget widget = getReceiptItemWidget(ri);
      final pair = <int, Widget>{id: widget};
      pairs.addAll(pair);
    }
    print("receipt item widget count: " + pairs.length.toString());
    return pairs;
  }

  // returns a single receipt item widget
  Widget getReceiptItemWidget(ReceiptItem ri) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        color: Utility.getBackGroundColor(),
        height: 100,
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            IconButton(
              onPressed: (() =>
                  {incrementReceiptItem(ri.getItem().getItemId())}),
              icon: const Icon(Icons.add),
              color: Colors.blue,
            ),
            Text(ri.getQuanity().toString(),
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis),
            IconButton(
              onPressed: (() =>
                  {decrementReceiptItem(ri.getItem().getItemId())}),
              icon: const Icon(Icons.remove),
              color: Colors.blue,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text("\$" + ri.getItem().getPrice().toString(),
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(ri.getItem().getName(),
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis),
            ),
            IconButton(
              onPressed: (() => {removeReceiptItem(ri.getItem().getItemId())}),
              icon: const Icon(Icons.delete),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  // increment the quanitity value of a receipt item
  void incrementReceiptItem(int itemId) {
    ReceiptItem ri = MerchantReceiptPage.receiptItems[0];
    for (int i = 0; i < MerchantReceiptPage.receiptItems.length; i++) {
      ri = MerchantReceiptPage.receiptItems[i];
      if (ri.getItem().getItemId() == itemId) {
        ri.incrementQuantity();
        MerchantReceiptPage.receiptItems[i] = ri;
        break;
      }
    }

    setState(() {
      receiptItemWidgets[itemId] = getReceiptItemWidget(ri);
      updateReceiptPriceSum();
    });
  }

  // decrement the quanitity value of a receipt item
  void decrementReceiptItem(int itemId) {
    ReceiptItem ri = MerchantReceiptPage.receiptItems[0];
    for (int i = 0; i < MerchantReceiptPage.receiptItems.length; i++) {
      ri = MerchantReceiptPage.receiptItems[i];
      if (ri.getItem().getItemId() == itemId) {
        ri.decrementQuantity();
        MerchantReceiptPage.receiptItems[i] = ri;
        break;
      }
    }

    setState(() {
      receiptItemWidgets[itemId] = getReceiptItemWidget(ri);
      updateReceiptPriceSum();
    });
  }

  // remove a receipt item
  void removeReceiptItem(int itemId) {
    for (int i = 0; i < MerchantReceiptPage.receiptItems.length; i++) {
      ReceiptItem ri = MerchantReceiptPage.receiptItems[i];
      if (ri.getItem().getItemId() == itemId) {
        MerchantReceiptPage.receiptItems.removeAt(i);
        break;
      }
    }

    setState(() {
      receiptItemWidgets.remove(itemId);
      updateReceiptPriceSum();
    });
  }

  @override
  Widget build(BuildContext context) {
    // get the merchant items that belong to this merchant
    merchantItems =
        (ModalRoute.of(context)!.settings.arguments! as Map)["merchantItems"];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Receipt Page"),
        backgroundColor: Utility.getBackGroundColor(),
        // top-right option menu
      ),
      // main body of page
      body: Align(
        alignment: Alignment.topCenter,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Utility.getBackGroundColor(),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // button for scanning product labels and adding them to the receipt
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            color: Colors.blue,
                            child: TextButton(
                              onPressed: scanLabel,
                              child: const Text(
                                "Scan",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        // finalizes the receipt and generates a QR code
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            color: Colors.blue,
                            child: TextButton(
                              onPressed: finishReceipt,
                              child: const Text(
                                "Done",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            color: Colors.blue,
                            child: TextButton(
                              onPressed: clearReceiptItems,
                              child: const Text(
                                "Reset",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Total: \$" + receiptPriceSum.toStringAsFixed(2),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(children: receiptItemWidgets.values.toList()),
          ],
        ),
      ),
      // add-new-item button
      floatingActionButton: FloatingActionButton(
        onPressed: loadReceiptItemPage,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
