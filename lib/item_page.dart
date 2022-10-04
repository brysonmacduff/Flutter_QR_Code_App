import 'package:ceg4912_project/edit_item_page.dart';
import 'package:ceg4912_project/merchant_label_print_page.dart';
import 'package:ceg4912_project/new_item_page.dart';
import 'package:ceg4912_project/Support/queries.dart';
import 'package:ceg4912_project/Support/session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ceg4912_project/Models/item.dart';

// serves as a wrapper class for rendering the actual item page
class ItemPage extends StatefulWidget {
  const ItemPage({Key? key}) : super(key: key);

  @override
  State<ItemPage> createState() => _ItemPageState();
}

// contains the stateful widgets and variables
class _ItemPageState extends State<ItemPage> {
  // locally stores the merchant's business items
  List<Item> items = <Item>[];
  // stores the UI widgets that represent merchant's items
  List<Widget> itemWidgets = <Widget>[];
  // keeps track of which item widgets are expanded in the UI
  List<bool> itemExpandedStateSet = <bool>[];
  // keeps track of which items the user may be attempting to delete
  List<bool> itemDeletionStateSet = <bool>[];

  // the color of event messages that are displayed to the user
  Color eventMessageColor = Colors.white;
  // the message that is displayed to the user to inform them of events
  String eventMessage = "";

  // initially get the merchant's business items upon loading the item page
  @override
  void initState() {
    super.initState();
    getItems();
  }

  // generates widgets for all of the current merchant's business items
  void getItems() async {
    int mId = Session.getSessionUser().getId();
    var conn = await Queries.getConnection();
    var mItems = await Queries.getMerchantItems(conn, mId);

    // if the query went wrong then it would return null
    if (mItems == null) {
      setState(() {
        eventMessage = "Item Retrieval Failed.";
        eventMessageColor = Colors.red;
      });

      // clears the event message after 2 seconds have passed
      clearEventMessage(2000);
      return;
    }

    // upon refresh, reset the lists that keeps track of the items that are showing on the UI
    items.clear();
    itemWidgets.clear();
    itemExpandedStateSet.clear();
    itemDeletionStateSet.clear();

    for (int i = 0; i < mItems.length; i++) {
      items.add(mItems[i]);
      itemExpandedStateSet.add(false);
      itemDeletionStateSet.add(false);

      setState(() {
        itemWidgets.add(getItemWidget(i, false, false));
      });
    }
  }

  // redirect to the new_item_page to create a new business item
  void createItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NewItemPage(),
      ),
    ).then((value) => getItems());
  }

  // permanently deletes an item from the database
  void deleteItem(int itemIndex) async {
    var conn = await Queries.getConnection();
    int iId = items[itemIndex].getItemId();
    var result = await Queries.deleteItem(conn, iId);

    setState(() {
      if (!result) {
        eventMessage = "Item Deletion Failed";
        eventMessageColor = Colors.red;
        // clears the event message after 2 seconds have passed
        clearEventMessage(2000);
        return;
      }

      // remove the widget from the UI that represented the deleted item
      // refresh the items page after a deletion
      getItems();
    });
  }

  // toggles the prompt that the user uses to confirm their intention to delete an item
  void toggleItemDeletionPrompt(int itemIndex) {
    bool deletionState = !itemDeletionStateSet[itemIndex]; // invert the state
    bool expandedState = itemExpandedStateSet[itemIndex];
    itemDeletionStateSet[itemIndex] = deletionState;
    setState(() {
      itemWidgets[itemIndex] =
          getItemWidget(itemIndex, expandedState, deletionState);
    });
  }

  // expands the full details of an item to the UI
  void expandItem(int itemIndex) {
    bool expandedState = !itemExpandedStateSet[itemIndex]; // invert the state
    bool deletionState = itemDeletionStateSet[itemIndex];
    itemExpandedStateSet[itemIndex] = expandedState;
    setState(() {
      itemWidgets[itemIndex] =
          getItemWidget(itemIndex, expandedState, deletionState);
    });
  }

  // routes to the edit_item_page to edit the selected item
  void editItem(int itemIndex) {
    Item selectedItem = items[itemIndex];
    EditItemPage.setCurrentItem(selectedItem);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditItemPage(),
      ),
    ).then((value) => getItems());
  }

  // Navigates to a new page to find a printer and print a barcode label for it
  void printItemLabel(int itemIndex) {
    Item selectedItem = items[itemIndex];
    Map arguments = {"item": selectedItem};
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: ((context) => const MerchantLabelPrintPage()),
        settings: RouteSettings(arguments: arguments),
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

  // returns a widget that represents a business item
  Widget getItemWidget(int i, bool isExpanded, bool isDeleting) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        color: const Color.fromARGB(255, 46, 73, 107),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    items[i].getName(),
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 20,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => {expandItem(i)},
                  icon: const Icon(
                    Icons.description,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  onPressed: () => {editItem(i)},
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  onPressed: () => {printItemLabel(i)},
                  icon: const Icon(Icons.print, color: Colors.blue),
                ),
                if (!isDeleting)
                  IconButton(
                    onPressed: () => {toggleItemDeletionPrompt(i)},
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                if (isDeleting)
                  IconButton(
                    onPressed: () => {deleteItem(i)},
                    icon: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                if (isDeleting)
                  IconButton(
                    onPressed: () => {toggleItemDeletionPrompt(i)},
                    icon: const Icon(
                      Icons.cancel,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
            if (isExpanded)
              Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              "DETAILS: " + items[i].getDetails(),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              "CODE: " + items[i].getCode(),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              "CATEGORY: " + items[i].getCategoryFormatted(),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              "PRICE: \$" + items[i].getPrice().toString(),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              "TAXABLE: " + items[i].isTaxableFormatted(),
                              style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Business Item Page"),
        backgroundColor: const Color.fromARGB(255, 46, 73, 107),
      ),
      body: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: getItems,
                icon: const Icon(Icons.refresh),
                color: Colors.blue,
              ),
              /*IconButton(
                onPressed: createItem,
                icon: const Icon(Icons.add),
                color: const Color.fromARGB(255, 46, 73, 107),
              ),*/
            ],
          ),
          Column(
            children: itemWidgets,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              eventMessage,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: eventMessageColor,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createItem,
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
