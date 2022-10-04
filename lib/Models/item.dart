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

  void setName(String name) {
    _name = name;
  }

  String getCode() {
    return _code;
  }

  void setCode(String code) {
    _code = code;
  }

  String getDetails() {
    return _details;
  }

  void setDetails(String details) {
    _details = details;
  }

  Categories getCategory() {
    return _category;
  }

  void setCategory(Categories cat) {
    _category = cat;
  }

  String getCategoryFormatted() {
    if (_category == Categories.none) {
      return "None";
    } else {
      return "N/A";
    }
  }

  static String getFormattedCategoryByParameter(Categories c) {
    if (c == Categories.none) {
      return "None";
    } else {
      return "N/A";
    }
  }

  double getPrice() {
    return _price;
  }

  void setPrice(double p) {
    _price = p;
  }

  bool isTaxable() {
    return _taxable;
  }

  void setTaxable(bool t) {
    _taxable = t;
  }

  String isTaxableFormatted() {
    if (_taxable) {
      return "Yes";
    } else {
      return "No";
    }
  }

  // converts customer-relevant data to JSON
  String toJSON() {
    String json = "{" +
        "'itemId':'" +
        _id.toString() +
        "','name':'" +
        _name +
        "','price':'" +
        _price.toString() +
        "'}";
    return json;
  }
}
