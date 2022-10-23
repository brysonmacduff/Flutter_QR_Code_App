import 'package:ceg4912_project/Models/item.dart';
import 'package:ceg4912_project/Support/session.dart';
import 'package:ceg4912_project/Support/utility.dart';
import 'package:flutter/material.dart';
import 'package:ceg4912_project/Support/queries.dart';

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

  // attempts to create a new item for this merchant
  void createItem() async {
    if (!areItemFieldsValid()) {
      Utility.displayAlertMessage(
          context, "Invalid Item Data", "Please enter valid item data.");
      return;
    }

    try {
      var conn = await Queries.getConnection();
      var result = await Queries.insertItem(
          conn,
          Session.getSessionUser().getId(),
          itemName,
          details,
          code,
          category,
          price,
          taxable);
      if (!result) {
        Utility.displayAlertMessage(context, "Item Creation Failed", "");
      } else {
        Utility.displayAlertMessage(context, "Item Creation Successful", "");
      }
    } catch (e) {
      Utility.displayAlertMessage(
          context, "Connection Error", "Please check your network connection.");
    }
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
        backgroundColor: Utility.getBackGroundColor(),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
                decoration: const InputDecoration(labelText: "Item Name"),
                onChanged: (value) => itemName = value),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
                decoration: const InputDecoration(labelText: "Details"),
                onChanged: (value) => details = value),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
                decoration: const InputDecoration(labelText: "Code"),
                onChanged: (value) => code = value),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              "Category",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
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
            padding: const EdgeInsets.all(8),
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
            padding: const EdgeInsets.all(8),
            child: Container(
              color: Utility.getBackGroundColor(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Taxable?",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Checkbox(
                    value: taxable,
                    side: const BorderSide(
                      color: Colors.white,
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
          Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              width: MediaQuery.of(context).size.width / 3,
              color: Utility.getBackGroundColor(),
              child: TextButton(
                onPressed: createItem,
                child: const Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
