import 'package:ceg4912_project/Models/user.dart';

class Session {
  static User _user = User.empty();

  static void clearSessionUser() {
    _user = User.empty();
  }

  static void setSessionUser(User user) {
    _user = user;
  }

  static User getSessionUser() {
    return _user;
  }
}
