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

  // generates widgets for all of the current merchant's business items
  void getItems() async {
    int mId = Session.getSessionUser().getId();
    var conn = await Queries.getConnection();
    var mItems = await Queries.getMerchantItems(conn, mId);

    // if the query went wrong then it would return null
    if (mItems == null) {
      return;
    }

    items.clear();
    itemWidgets.clear();

    for (int i = 0; i < mItems.length; i++) {
      print(mItems[i].getName());
      items.add(mItems[i]);

      setState(() {
        itemWidgets.add(
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              color: const Color.fromARGB(255, 46, 73, 107),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    mItems[i].getName(),
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  TextButton(
                    onPressed: () => {expandItem(i)},
                    child: const Text("..."),
                  ),
                  TextButton(
                    onPressed: () => {deleteItem(i)},
                    child: const Text(
                      "X",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 0, 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    }
    print("items length = " + itemWidgets.length.toString());
  }

  // creates a new business item for the current merchant
  void createItem() {}
  // permanently deletes an item
  void deleteItem(int itemIndex) {}
  // reveals the full details of an item to the UI
  void expandItem(int itemIndex) {}

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
              TextButton(
                onPressed: getItems,
                child: const Text("Refresh"),
              ),
              TextButton(
                onPressed: createItem,
                child: const Text("Create Item"),
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
