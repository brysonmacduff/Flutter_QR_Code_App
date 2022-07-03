import 'package:ceg4912_project/Models/new_item_page.dart';
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

  // generates widgets for all of the current merchant's business items
  void getItems() async {
    int mId = Session.getSessionUser().getId();
    var conn = await Queries.getConnection();
    var mItems = await Queries.getMerchantItems(conn, mId);

    // if the query went wrong then it would return null
    if (mItems == null) {
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
    print("items length = " + itemWidgets.length.toString());
  }

  // redirect to the new_item_page to create a new business item
  void createItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NewItemPage(),
      ),
    );
  }

  // permanently deletes an item
  void deleteItem(int itemIndex) {}

  // expands the full details of an item to the UI
  void expandItem(int itemIndex) {
    bool expandedState = !itemExpandedStateSet[itemIndex];
    itemExpandedStateSet[itemIndex] = expandedState;
    setState(() {
      itemWidgets[itemIndex] = getItemWidget(itemIndex, expandedState);
    });
  }

  // returns a widget that represents a business item
  Widget getItemWidget(int i, bool isExpanded) {
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
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                IconButton(
                  onPressed: () => {deleteItem(i)},
                  icon: const Icon(
                    Icons.delete,
                    color: Color.fromARGB(255, 255, 0, 0),
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
                              "Details: " + items[i].getDetails(),
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
                              "Code: " + items[i].getCode(),
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
                              "Category: " + items[i].getCategoryFormatted(),
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
                              "Price: \$" + items[i].getPrice().toString(),
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
                              "Taxable: " + items[i].isTaxableFormatted(),
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
                color: const Color.fromARGB(255, 46, 73, 107),
              ),
              IconButton(
                onPressed: createItem,
                icon: const Icon(Icons.add),
                color: const Color.fromARGB(255, 46, 73, 107),
              ),
            ],
          ),
          Column(
            children: itemWidgets,
          ),
        ],
      ),
    );
  }
}
