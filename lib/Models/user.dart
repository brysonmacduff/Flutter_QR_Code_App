class User {
  int _id;
  String _email;
  String _password;
  String _role;

  User(this._id, this._email, this._password, this._role);

  int getId() {
    return _id;
  }

  String getEmail() {
    return _email;
  }

  String getPassword() {
    return _password;
  }

  String getRole() {
    return _role;
  }

  String toString() {
    return _id.toString() + ", " + _email + ", " + _password + ", " + _role;
  }
}
