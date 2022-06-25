import 'package:flutter/material.dart';
import 'merchant_account.dart';

var merchantName = "Amazon";

class MerchantHomePageRoute extends StatelessWidget {
  const MerchantHomePageRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MerchantHomePage());
  }
}

class MerchantHomePage extends StatelessWidget {
  const MerchantHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Merchant Home"),
          backgroundColor: const Color.fromARGB(255, 46, 73, 107),
        ),
        body: Center(
          child: Column(children: [
            Text(
              merchantName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: (() {}),
              child: const Text('Products and Services'),
            ),
            TextButton(
              onPressed: (() {}),
              child: const Text('Create Receipt'),
            ),
            TextButton(
              onPressed: (() {}),
              child: const Text('Receipt History'),
            ),
            TextButton(
              onPressed: (() {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MerchantAccountPage()));
              }),
              child: const Text('Account'),
            ),
            TextButton(
              onPressed: (() {}),
              child: const Text('Log Out'),
            )
          ]),
        ));
  }
}
