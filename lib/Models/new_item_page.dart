import 'package:ceg4912_project/Models/item.dart';
import 'package:ceg4912_project/Support/session.dart';
import 'package:flutter/material.dart';
import 'package:ceg4912_project/Support/queries.dart';
import 'package:flutter/services.dart';

class NewItemPage extends StatefulWidget {
  const NewItemPage({Key? key}) : super(key: key);

  @override
  State<NewItemPage> createState() => _NewItemPageState();
}

class _NewItemPageState extends State<NewItemPage> {
  String itemName = "";
  Categories category = Categories.none;
  String details = "";
  String code = "";
  String price = "";
  bool taxable = true;

  String createItemEventMessage = "";
  Color createItemEventColor = Colors.white;

  // attempts to create a new item for this merchant
  void createItem() async {
    var conn = await Queries.getConnection();

    if (!areItemFieldsValid()) {
      setState(() {
        createItemEventMessage = "Item Data is Invalid";
        createItemEventColor = Colors.red;
      });
      return;
    }

    var result = await Queries.insertItem(
        conn,
        Session.getSessionUser().getId(),
        itemName,
        details,
        code,
        category,
        price,
        taxable);

    setState(() {
      if (!result) {
        createItemEventMessage = "Failed to Create Item";
        createItemEventColor = Colors.red;
      } else {
        createItemEventMessage = "Item Has Been Created";
        createItemEventColor = Colors.green;
      }
    });
  }

  // checks if all of the user's input data for the item is valid
  bool areItemFieldsValid() {
    if (itemName.isEmpty) {
      return false;
    } else if (!priceIsValid()) {
      return false;
    } else {
      return true;
    }
  }

  // checks if the entered price is a valid number
  bool priceIsValid() {
    if (double.tryParse(price) == null) {
      return false;
    }
    double dPrice = double.parse(price);
    if (dPrice < 0) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Item Page"),
        backgroundColor: const Color.fromARGB(255, 46, 73, 107),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
                decoration: const InputDecoration(labelText: "Item Name"),
                onChanged: (value) => itemName = value),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
                decoration: const InputDecoration(labelText: "Details"),
                onChanged: (value) => details = value),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
                decoration: const InputDecoration(labelText: "Code"),
                onChanged: (value) => code = value),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              items: const [
                DropdownMenuItem(
                  value: "None",
                  child: SizedBox(
                    child: Text("None"),
                  ),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  if (newValue == "None") {
                    category = Categories.none;
                  }
                });
              },
              value: Item.getFormattedCategoryByParameter(category),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: "Price"),
              onChanged: (value) => price = value,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              color: const Color.fromARGB(255, 46, 73, 107),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Taxable?",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),
                  Checkbox(
                    value: taxable,
                    side: const BorderSide(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    onChanged: (value) {
                      setState(() {
                        taxable = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: createItem,
            color: const Color.fromARGB(255, 0, 150, 10),
            iconSize: 50,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              createItemEventMessage,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: createItemEventColor,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
