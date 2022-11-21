//import 'dart:html';

import 'dart:async';
import 'dart:convert';


import 'package:ceg4912_project/customer_payment.dart';
import 'package:flutter/material.dart';
import 'package:ceg4912_project/Support/queries.dart';
import 'package:ceg4912_project/Models/user.dart';
import 'package:flutter/services.dart';
import 'package:date_field/date_field.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mysql1/mysql1.dart';


class CustomerPayment{

  //payment variables
  Map<String, dynamic>? paymentIntent;
  final client = http.Client();
  static Map<String, String> headers = {
    'Authorization':
    'Bearer sk_test_51LTCRODkzVSkvB16MkkVIZ1UZl5ewJzmaB9Qgm9yQrE8jTWX8UjrM1L8cu4ty6BI2SSyLKgvxqXGK1UVANlUQyc500J8r4XRY1',
    'Content-Type': 'application/x-www-form-urlencoded'
  };


  static createCustomer(http.Client client,MySqlConnection conn, int cId,String cEmail) async {
    var response = await client.post(
      Uri.parse('https://api.stripe.com/v1/customers'),
      headers: headers,
      body: {'description': 'new customer', 'name': 'test','email':cEmail},
    );
    if (response.statusCode == 200) {
      //save the stripe Customer Object
      var customer_stripe_obj = json.decode(response.body);
      print("Strip Object:" + customer_stripe_obj.toString());
      //fetch the new customer's stripe Id
      final new_customer_stripeId = customer_stripe_obj['id'];
      print("Stripe Id: " + new_customer_stripeId);
      //attach the customer's stripe Id to our SQL database
      Queries.editStripeId(conn, new_customer_stripeId, cId);
      final paymentMethod = await CustomerPayment.createPaymentMethod(client,
          number: '4242424242424242',
          expMonth: '03',
          expYear: '23',
          cvc: '123');
      await CustomerPayment.attachPaymentMethod(
          client, paymentMethod['id'], customer_stripe_obj['id']);
      await CustomerPayment.updateCustomer(
          client, paymentMethod['id'], customer_stripe_obj['id']);
    } else {
      print(json.decode(response.body));
      throw 'Failed to register as a customer.';
    }
  }

  static Future<Map<String, dynamic>> createPaymentMethod(http.Client client,
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

  static Future<Map<String, dynamic>> attachPaymentMethod(http.Client client,String paymentMethodId, String customerId) async {
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

  static Future<Map<String, dynamic>> updateCustomer(http.Client client,String paymentMethodId, String customerId) async {
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

  static createPaymentIntent(http.Client client,String amount, String currency, String pId, String cId) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method': pId,
        'customer': cId,
        'setup_future_usage': 'off_session',
        'payment_method_types[]': 'card',
      };

      var response = await client.post(
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

  static calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }

  // displayPaymentSheet() async {
  //   try {
  //     await Stripe.instance.presentPaymentSheet().then((value) {
  //       showDialog(
  //           context: context,
  //           builder: (_) => AlertDialog(
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Row(
  //                   children: const [
  //                     Icon(
  //                       Icons.check_circle,
  //                       color: Colors.green,
  //                     ),
  //                     Text("Payment Successfull"),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ));
  //       // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("paid successfully")));
  //
  //       paymentIntent = null;
  //     }).onError((error, stackTrace) {
  //       print('Error is:--->$error $stackTrace');
  //     });
  //   } on StripeException catch (e) {
  //     print('Error is:---> $e');
  //     showDialog(
  //         context: context,
  //         builder: (_) => const AlertDialog(
  //           content: Text("Cancelled "),
  //         ));
  //   } catch (e) {
  //     print('$e');
  //   }
  // }
}