import 'user.dart';

class Customer extends User {
  Customer.credentials(int _id, String _email, String _password)
      : super.user(_id, _email, _password, Roles.customer);
}
