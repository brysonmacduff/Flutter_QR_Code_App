class Merchant {
  int _id = -1;
  String _name = "";
  String _email = "";
  String _password = "";

  Merchant.empty();
  Merchant.merchant(this._id, this._name, this._email, this._password);

  int getId() {
    return _id;
  }

  void setId(id) {
    this._id = id;
  }

  String getEmail() {
    return _email;
  }

  void setEmail(email) {
    this._email = email;
  }

  String getPassword() {
    return _password;
  }

  void setPassword(password) {
    this._password = password;
  }

  String getName() {
    return this._name;
  }

  void setName(name) {
    this._name = name;
  }

  void submitChanges() {
    //TODO: Create statement to insert the new data into SQL table
  }
}
