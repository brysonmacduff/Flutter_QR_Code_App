import 'package:flutter/material.dart';
import 'package:ceg4912_project/login.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      "pk_test_51LTCRODkzVSkvB16csikvssY9E1AVG5JXBSQYcpYEKcJuxHBumW0UZvNDn60fPIYMBEni8EtCmA9BVVfT5rUr3n800qu2KQAso";
  runApp(const LogInPageRoute());
}
