import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? paymentIntent;
  final client = http.Client();
  static Map<String, String> headers = {
    'Authorization':
        'Bearer sk_test_51LTCRODkzVSkvB16MkkVIZ1UZl5ewJzmaB9Qgm9yQrE8jTWX8UjrM1L8cu4ty6BI2SSyLKgvxqXGK1UVANlUQyc500J8r4XRY1',
    'Content-Type': 'application/x-www-form-urlencoded'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stripe Payment'),
      ),
      body: Center(
        child: TextButton(
          child: const Text('Make Payment'),
          onPressed: () async {
            await makePayment();
          },
        ),
      ),
    );
  }

//new
  Future<Map<String, dynamic>> createCustomer() async {
    var response = await client.post(
      Uri.parse('https://api.stripe.com/v1/customers'),
      headers: headers,
      body: {'description': 'new customer'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to register as a customer.';
    }
  }

//new method
  Future<Map<String, dynamic>> createPaymentMethod(
      {required String number,
      required String expMonth,
      required String expYear,
      required String cvc}) async {
    var response = await client.post(
      Uri.parse('https://api.stripe.com/v1/payment_methods'),
      headers: headers,
      body: {
        'type': 'card',
        'card[number]': number,
        'card[exp_month]': expMonth,
        'card[exp_year]': expYear,
        'card[cvc]': cvc,
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to create PaymentMethod.';
    }
  }

//new method
  Future<Map<String, dynamic>> attachPaymentMethod(
      String paymentMethodId, String customerId) async {
    var response = await client.post(
      Uri.parse(
          'https://api.stripe.com/v1/payment_methods/$paymentMethodId/attach'),
      headers: headers,
      body: {
        'customer': customerId,
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to attach PaymentMethod.';
    }
  }

//new method
  Future<Map<String, dynamic>> updateCustomer(
      String paymentMethodId, String customerId) async {
    var response = await client.post(
      Uri.parse('https://api.stripe.com/v1/customers/$customerId'),
      headers: headers,
      body: {
        'invoice_settings[default_payment_method]': paymentMethodId,
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print(json.decode(response.body));
      throw 'Failed to update Customer.';
    }
  }

  Future<void> makePayment() async {
    try {
      final customer = await createCustomer();
      paymentIntent = await createPaymentIntent('15', 'CAD');
      //Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  customerId: customer['id'],
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Merchant'))
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet();
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          Text("Payment Successfull"),
                        ],
                      ),
                    ],
                  ),
                ));
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("paid successfully")));

        paymentIntent = null;
      }).onError((error, stackTrace) {
        print('Error is:--->$error $stackTrace');
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      print('$e');
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer sk_test_51LTCRODkzVSkvB16MkkVIZ1UZl5ewJzmaB9Qgm9yQrE8jTWX8UjrM1L8cu4ty6BI2SSyLKgvxqXGK1UVANlUQyc500J8r4XRY1',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      // ignore: avoid_print
      print('Payment Intent Body->>> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      // ignore: avoid_print
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    return calculatedAmout.toString();
  }
}
