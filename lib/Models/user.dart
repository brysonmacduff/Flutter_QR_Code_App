enum Roles { merchant, customer, none }

class User {
  int _id = -1;
  String _email = "";
  String _password = "";
  Roles _role = Roles.none;

  User.empty();
  User.user(this._id, this._email, this._password, this._role);

  int getId() {
    return _id;
  }

  String getEmail() {
    return _email;
  }

  String getPassword() {
    return _password;
  }

  Roles getRole() {
    return _role;
  }

  String toString() {
    return _id.toString() +
        ", " +
        _email +
        ", " +
        _password +
        ", " +
        _role.toString();
  }
}
