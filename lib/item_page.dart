import 'package:ceg4912_project/Support/utility.dart';
import 'package:ceg4912_project/edit_item_page.dart';
import 'package:ceg4912_project/merchant_label_print_page.dart';
import 'package:ceg4912_project/new_item_page.dart';
import 'package:ceg4912_project/Support/queries.dart';
import 'package:ceg4912_project/Support/session.dart';
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

  // initially get the merchant's business items upon loading the item page
  @override
  void initState() {
    super.initState();
    getItems();
  }

  // generates widgets for all of the current merchant's business items
  void getItems() async {
    int mId = Session.getSessionUser().getId();
    var conn;
    var mItems;

    try {
      conn = await Queries.getConnection();
      mItems = await Queries.getMerchantItems(conn, mId);
      // if the query went wrong then it would return null
      if (mItems == null) {
        Utility.displayAlertMessage(context, "Failed to Retrieve Items",
            "Something went wrong. Please check your network connection.");
        return;
      }
    } catch (e) {
      Utility.displayAlertMessage(context, "Failed to Retrieve Data",
          "Please check your network connection.");
      return;
    }

    // upon refresh, reset the lists that keeps track of the items that are showing on the UI
    items.clear();
    itemWidgets.clear();
    itemExpandedStateSet.clear();

    for (int i = 0; i < mItems.length; i++) {
      items.add(mItems[i]);
      itemExpandedStateSet.add(false);

      setState(() {
        itemWidgets.add(getItemWidget(i, false));
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

  // expands the full details of an item to the UI
  void expandItem(int itemIndex) {
    bool expandedState = !itemExpandedStateSet[itemIndex]; // invert the state
    itemExpandedStateSet[itemIndex] = expandedState;
    setState(() {
      itemWidgets[itemIndex] = getItemWidget(itemIndex, expandedState);
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

  // returns a widget that represents a business item
  Widget getItemWidget(int i, bool isExpanded) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        color: Utility.getBackGroundColor(),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        items[i].getName(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    color: Colors.blue,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => {expandItem(i)},
                          icon: const Icon(
                            Icons.description,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () => {editItem(i)},
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () => {printItemLabel(i)},
                          icon: const Icon(Icons.print, color: Colors.white),
                        ),
                      ],
                    ),
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
          IconButton(
            onPressed: getItems,
            icon: const Icon(Icons.refresh),
            color: Colors.blue,
          ),
          Column(
            children: itemWidgets,
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
