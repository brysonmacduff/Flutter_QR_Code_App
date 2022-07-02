enum Categories { none }

class Item {
  int _id = -1;
  int _merchantId = -1;
  String _name = "";
  String _code = "";
  String _details = "";
  Categories _category = Categories.none;
  double _price = 0;
  bool _taxable = true;

  Item.empty();
  Item.all(int id, int merchantId, String name, String code, String details,
      Categories category, double price, bool taxable) {
    _id = id;
    _merchantId = merchantId;
    _name = name;
    _code = code;
    _details = details;
    _category = category;
    _price = price;
    _taxable = taxable;
  }

  int getItemId() {
    return _id;
  }

  int getMerchantId() {
    return _merchantId;
  }

  String getName() {
    return _name;
  }

  String getCode() {
    return _code;
  }

  String getDetails() {
    return _details;
  }

  Categories getCategory() {
    return _category;
  }

  String getCategoryString() {
    return "None";
  }

  double getPrice() {
    return _price;
  }

  bool isTaxable() {
    return _taxable;
  }

  String isTaxableString() {
    if (_taxable) {
      return "Yes";
    } else {
      return "No";
    }
  }
}
