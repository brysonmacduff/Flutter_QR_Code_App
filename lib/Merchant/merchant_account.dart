import 'package:ceg4912_project/Models/merchant.dart';
import 'package:flutter/material.dart';
import 'merchant_homepage.dart';

var Merchantinfo =
    new Merchant.merchant(1, 'Amazon', 'Amazon@gmail.com', 'verysecure');

class MerchantAccountPageRoute extends StatelessWidget {
  const MerchantAccountPageRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MerchantHomePage());
  }
}

class MerchantAccountPage extends StatelessWidget {
  const MerchantAccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Merchant Account Page"),
        backgroundColor: const Color.fromARGB(255, 46, 73, 107),
      ),
      body: Center(
          child: Column(
        children: [
          Text('Account Information'),
          Text('Account ID'),
          TextField(
            textAlign: TextAlign.center,
            controller:
                TextEditingController(text: Merchantinfo.getId().toString()),
          ),
          Text('Account Name'),
          TextField(
            textAlign: TextAlign.center,
            controller: TextEditingController(text: Merchantinfo.getName()),
          ),
          Text('Email'),
          TextField(
            textAlign: TextAlign.center,
            controller: TextEditingController(text: Merchantinfo.getEmail()),
          ),
          Text('Password'),
          TextField(
            textAlign: TextAlign.center,
            controller: TextEditingController(text: Merchantinfo.getPassword()),
          ),
          ElevatedButton(
              onPressed: Merchantinfo.submitChanges,
              child: const Text('Submit'))
        ],
      )),
    );
  }
}
