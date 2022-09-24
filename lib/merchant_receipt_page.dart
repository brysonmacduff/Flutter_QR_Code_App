import 'package:ceg4912_project/Support/session.dart';
import 'package:ceg4912_project/merchant_home.dart';
import 'package:ceg4912_project/merchant_receipt_qr_page.dart';
import 'package:flutter/material.dart';
import 'package:ceg4912_project/Support/utility.dart';
import 'package:ceg4912_project/Models/receipt_item.dart';
import 'package:ceg4912_project/Models/item.dart';
import 'package:ceg4912_project/merchant_receipt_item_page.dart';

class MerchantReceiptPage extends StatefulWidget {
  const MerchantReceiptPage({Key? key}) : super(key: key);
  // stores the list of receipt items inside the current receipt
  static List<ReceiptItem> receiptItems =
      List<ReceiptItem>.empty(growable: true);

  @override
  State<MerchantReceiptPage> createState() => _MerchantReceiptPageState();
}

class _MerchantReceiptPageState extends State<MerchantReceiptPage> {
  Map<int, Widget> receiptItemWidgets = Map<int, Widget>();

  // reset the current receipt item list and clear the UI
  void clearReceiptItems() {
    MerchantReceiptPage.receiptItems.clear();
    setState(() {
      receiptItemWidgets.clear();
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
      receiptItemWidgets = getReceiptItemWidgets();
    });
  }

  void scanLabel() {}

  // Convert receipt data to JSON and generate a QR code. Pushes a new page that has a big receipt QR code.
  void finishReceipt() {
    String qrData = "{'merchantId':'" +
        Session.getSessionUser().getId().toString() +
        "','items':";

    for (int i = 0; i < MerchantReceiptPage.receiptItems.length; i++) {
      ReceiptItem ri = MerchantReceiptPage.receiptItems[i];
      if (i == MerchantReceiptPage.receiptItems.length - 1) {
        qrData += ri.toJSON();
      } else {
        qrData += ri.toJSON() + ",";
      }
    }
    qrData += "}";
    print(qrData);

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
    });
  }

  @override
  Widget build(BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // button for scanning product labels and adding them to the receipt
                TextButton(
                  onPressed: scanLabel,
                  child: const Text("Scan"),
                ),
                // finalizes the receipt and generates a QR code
                TextButton(
                  onPressed: finishReceipt,
                  child: const Text("Submit"),
                ),
                TextButton(
                  onPressed: clearReceiptItems,
                  child: const Text("Clear"),
                ),
              ],
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
