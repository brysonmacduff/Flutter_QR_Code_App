import 'package:ceg4912_project/Models/item.dart';

class ReceiptItem {
  Item _item = Item.empty();
  int _quanity = 1;

  ReceiptItem.empty();
  ReceiptItem.create(Item item) {
    _item = item;
  }

  Item getItem() {
    return _item;
  }

  int getQuanity() {
    return _quanity;
  }

  void incrementQuantity() {
    _quanity++;
  }

  bool decrementQuantity() {
    if (_quanity < 2) {
      return false;
    }

    _quanity--;
    return true;
  }

  // Converts this object to a JSON string. Only converts information the customer view would need.
  String toJSON() {
    String json = "{" +
        "'itemId':'" +
        _item.getItemId().toString() +
        "','quantity':'" +
        _quanity.toString() +
        "','name':'" +
        _item.getName() +
        "','price':'" +
        _item.getPrice().toString() +
        "'}";
    return json;
  }

  // converts from JSON to an item object
  //static Item toItem(String json) {}
}
