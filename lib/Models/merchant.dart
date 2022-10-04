import 'user.dart';
import 'stripe_data.dart';

class Merchant extends User {
  StripeData _stripeData = StripeData.empty();

  Merchant.credentials(int _id, String _email, String _password)
      : super.user(_id, _email, _password, Roles.merchant);

  Merchant.all(int _id, String _email, String _password, StripeData stripeData)
      : super.user(_id, _email, _password, Roles.merchant) {
    _stripeData = stripeData;
  }

  StripeData getStripeData() {
    return _stripeData;
  }

  void setStripeData(StripeData sd) {
    _stripeData = sd;
  }
}
