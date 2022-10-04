import 'package:ceg4912_project/Support/utility.dart';
import 'package:ceg4912_project/Support/queries.dart';
import 'package:ceg4912_project/Support/session.dart';
import 'package:ceg4912_project/merchant_receipt_page.dart';
import 'package:flutter/material.dart';
import 'package:ceg4912_project/Models/item.dart';
import 'package:ceg4912_project/Models/receipt_item.dart';

class ReceiptItemPage extends StatefulWidget {
  const ReceiptItemPage({Key? key}) : super(key: key);

  @override
  State<ReceiptItemPage> createState() => ReceiptItemPageState();
}

class ReceiptItemPageState extends State<ReceiptItemPage> {
  // locally stores the merchant's business items
  List<Item> items = List<Item>.empty(growable: true);
  // stores the widgets the represnet the merchant's business items in the UI
  List<Widget> itemWidgets = <Widget>[];
  // stores the checked business items that will be added to the receipt
  List<Item> selectedItems = List<Item>.empty(growable: true);
  // stores the checked state of each item widget checkbox
  List<bool> checkboxValues = List<bool>.empty(growable: true);

  // used for altering the user of errors, warnings, and other events
  String eventMessage = "";
  Color eventMessageColor = Colors.white;

  // fetches the merchant's business items from the database on load of the page
  @override
  void initState() {
    super.initState();
    getBusinessItems();
  }

  void getBusinessItems() async {
    int mId = Session.getSessionUser().getId();
    var conn = await Queries.getConnection();
    var mItems = await Queries.getMerchantItems(conn, mId);

    // if the query went wrong then it would return null
    if (mItems == null) {
      setState(() {
        eventMessage = "Item Retrieval Failed.";
        eventMessageColor = Colors.red;
      });

      clearEventMessage(2000);
      return;
    }

    for (int i = 0; i < mItems.length; i++) {
      items.add(mItems[i]);
      checkboxValues.add(false);
    }

    // update the UI to show the item widgets
    setState(() {
      itemWidgets = getItemWidgets();
      print("widget count: " + itemWidgets.length.toString());
    });
  }

  // displays all eligible business items to the UI that can be added to the merchant's receipt
  List<Widget> getItemWidgets() {
    List<Widget> widgets = <Widget>[];

    int k = 0;
    for (int i = 0; i < items.length; i++) {
      // check if the current item is already in the receipt list
      bool inReceiptList = false;
      for (int j = 0; j < MerchantReceiptPage.receiptItems.length; j++) {
        if (MerchantReceiptPage.receiptItems[j].getItem().getItemId() ==
            items[i].getItemId()) {
          inReceiptList = true;
          break;
        }
      }

      // skip this item (don't display it in the UI) if it's already in the receipt list
      if (inReceiptList) {
        continue;
      }

      widgets.add(getItemWidget(i, checkboxValues[i], k));
      k++;
    }
    return widgets;
  }

  Widget getItemWidget(int itemIndex, bool isChecked, int widgetIndex) {
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
              child: Checkbox(
                checkColor: Colors.white,
                value: isChecked,
                onChanged: (bool? value) {
                  // update the checkbox flag state
                  checkboxValues[itemIndex] = !isChecked;
                  // add/remove the item from the selected item list
                  onItemWidgetCheck(checkboxValues[itemIndex], items[itemIndex],
                      itemIndex, widgetIndex);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                "\$" + items[itemIndex].getPrice().toString(),
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                items[itemIndex].getName(),
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Called when an item widget's checkbox is checked. This indicates whether it has been selected for addition to the receipt.
  void onItemWidgetCheck(bool flag, Item item, int itemIndex, int widgetIndex) {
    print("checkbox id: " + widgetIndex.toString());

    toggleItemCheckbox(itemIndex, widgetIndex, flag);
    if (flag) {
      // if the flag is set to true, then add the item to the selected item list
      selectedItems.add(item);
    } else {
      // if the flag is set to false, remove the item from the selected item list
      for (int i = 0; i < selectedItems.length; i++) {
        if (selectedItems[i].getItemId() == item.getItemId()) {
          selectedItems.removeAt(i);
          return;
        }
      }
    }
  }

  // overwrites one of the item widgets to change the flag state of its checkbox
  void toggleItemCheckbox(int itemIndex, int widgetIndex, bool flag) {
    setState(() {
      itemWidgets[widgetIndex] = getItemWidget(itemIndex, flag, widgetIndex);
    });
  }

  // adds the selected items to the receipt list from the merchant receipt page
  void submitReceiptItems() {
    for (int i = 0; i < selectedItems.length; i++) {
      MerchantReceiptPage.receiptItems
          .add(ReceiptItem.create(selectedItems[i]));
    }
    Navigator.pop(context);
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
        title: const Text("Business Items Page"),
        backgroundColor: Utility.getBackGroundColor(),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextButton(
              child: const Text("Submit"),
              onPressed: submitReceiptItems,
            ),
          ),

          // contains the UI widgets that represent all of the merchant's business items
          Column(children: itemWidgets),

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
