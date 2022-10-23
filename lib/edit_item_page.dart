import 'package:ceg4912_project/Support/queries.dart';
import 'package:flutter/material.dart';
import 'package:ceg4912_project/Models/item.dart';
import 'package:ceg4912_project/Support/utility.dart';

class EditItemPage extends StatefulWidget {
  const EditItemPage({Key? key}) : super(key: key);

  static Item _currentItem = Item.empty();

  static void setCurrentItem(Item item) {
    _currentItem = item;
  }

  static Item getCurrentItem() {
    return _currentItem;
  }

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  // this is initialized on load of the page (probably)
  Item currentItem = EditItemPage.getCurrentItem();

  // the starting value of the input field variables
  String itemName = EditItemPage.getCurrentItem().getName();
  String details = EditItemPage.getCurrentItem().getDetails();
  String code = EditItemPage.getCurrentItem().getCode();
  String price = EditItemPage.getCurrentItem().getPrice().toString();

  // Used for setting the values of the input fields. They must be initially populated with the existing item data before editing.
  var nameTEC =
      TextEditingController(text: EditItemPage.getCurrentItem().getName());
  var detailsTEC =
      TextEditingController(text: EditItemPage.getCurrentItem().getDetails());
  var codeTEC =
      TextEditingController(text: EditItemPage.getCurrentItem().getCode());
  var priceTEC = TextEditingController(
      text: EditItemPage.getCurrentItem().getPrice().toString());

  // overwrites the current item's attributes in the database and here locally
  void editItem() async {
    if (!areItemFieldsValid()) {
      Utility.displayAlertMessage(
          context, "Invalid Item Data", "Please enter valid item data.");
      return;
    }

    currentItem = Item.all(
        currentItem.getItemId(),
        currentItem.getMerchantId(),
        itemName,
        code,
        details,
        currentItem.getCategory(),
        double.parse(price),
        currentItem.isTaxable());

    try {
      var conn = await Queries.getConnection();
      var result = await Queries.editItem(conn, currentItem);
      if (!result) {
        Utility.displayAlertMessage(context, "Item Edit Failed", "");
      } else {
        Utility.displayAlertMessage(context, "Item Edit Successful", "");
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
        title: const Text("Edit Item Page"),
        backgroundColor: Utility.getBackGroundColor(),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
                controller: nameTEC,
                decoration: const InputDecoration(labelText: "Item Name"),
                onChanged: (value) {
                  itemName = value;
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
                controller: detailsTEC,
                decoration: const InputDecoration(labelText: "Details"),
                onChanged: (value) {
                  details = value;
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: codeTEC,
              decoration: const InputDecoration(labelText: "Code"),
              onChanged: (value) {
                code = value;
              },
            ),
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
                    currentItem.setCategory(Categories.none);
                  }
                });
              },
              value: currentItem.getCategoryFormatted(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: true,
              ),
              controller: priceTEC,
              decoration: const InputDecoration(labelText: "Price"),
              onChanged: (value) {
                price = value;
              },
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
                    value: currentItem.isTaxable(),
                    side: const BorderSide(
                      color: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        currentItem.setTaxable(value!);
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
                onPressed: editItem,
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
